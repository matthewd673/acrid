require "curses"
require "./screen"
require "./cursor"

class Document
  attr_accessor :focused

  def initialize(filename, theme, syntax)
    @@theme = theme
    @@syntax = syntax
    @@scroll_y = 0

    @@raw_lines = load_file_lines(filename)
    @@lines = @@raw_lines.map { |l|
      tokenize(l, @@syntax)
    }

    @@cursor = Cursor.new
    @focused = true

    Acrid.register_handler(Acrid::Event::PRINT, method(:handle_print))
    Acrid.register_handler(
      Acrid::Event::FINISH_PRINT,
      method(:handle_finish_print)
    )

    Acrid.register_handler(Acrid::Event::GETCH, method(:handle_getch))
    Acrid.register_handler(
      Acrid::Event::CURSOR_MOVE,
      method(:handle_cursor_move)
    )
    Acrid.register_handler(Acrid::Event::EDITOR_TYPE, method(:handle_editor_type))
    Acrid.register_handler(Acrid::Event::EDITOR_BACKSPACE, method(:handle_editor_backspace))
    Acrid.register_handler(Acrid::Event::EDITOR_RETURN, method(:handle_editor_return))

    Acrid.register_handler(Acrid::Event::EDIT_LINE, method(:handle_edit_line))

    Acrid.register_handler(Acrid::Event::FOCUS, method(:handle_focus))
    Acrid.register_handler(Acrid::Event::UNFOCUS, method(:handle_unfocus))
  end

  def handle_print(data)
    if data["target"] != "document" then return end

    max_x = get_max_x
    max_y = get_max_y

    # print lines from file until screen is full
    y = 0
    for i in @@scroll_y..(@@scroll_y + max_y)
      if i >= @@lines.length then break end

      x = 0
      move_cursor(x, y)

      @@lines[i].each { |t|
        dist_to_edge = max_x - x
        write_str(t.image[..dist_to_edge], @@theme.token_colors[t.type])

        x += t.image.length
        if x >= max_x then break end
      }

      clear_to_eol

      y += 1
    end

    # clear bottom if doc lines don't fill screen
    for i in y..max_y
      move_cursor(0, i)
      clear_to_eol
    end
  end

  def handle_finish_print(data)
    if @focused then @@cursor.apply_physical_cursor end
  end

  def max_line
    @@lines.length - 1
  end

  def current_line
    @@raw_lines[@@cursor.vy]
  end

  def handle_getch(data)
    if not @focused then return end

    # @@raw_lines[0] = data["char"].class.to_s
    # @@lines[0] = tokenize(@@raw_lines[0], @@syntax)

    key_events = {
      Curses::Key::UP => {
        :event => Acrid::Event::CURSOR_MOVE,
        :data => { "direction" => "up" }
      },
      Curses::Key::DOWN => {
        :event => Acrid::Event::CURSOR_MOVE,
        :data => { "direction" => "down" }
      },
      Curses::Key::LEFT => {
        :event => Acrid::Event::CURSOR_MOVE,
        :data => { "direction" => "left" }
      },
      Curses::Key::RIGHT => {
        :event => Acrid::Event::CURSOR_MOVE,
        :data => { "direction" => "right" }
      },
      127 => { # macOS delete key
        :event => Acrid::Event::EDITOR_BACKSPACE,
        :data => {}
      },
      13 => { # macOS enter key
        :event => Acrid::Event::EDITOR_RETURN,
        :data => {}
      }
    }

    # @@raw_lines[0] = data["char"].to_s
    # @@lines[0] = tokenize(@@raw_lines[0], @@syntax)

    # handle special keys
    if data["char"].is_a?(Integer)
      if key_events[data["char"]] != nil

        event = key_events[data["char"]]
        Acrid.trigger_event(event[:event], event[:data])
      end
    # handle typing
    elsif data["char"].is_a?(String)
      Acrid.trigger_event(Acrid::Event::EDITOR_TYPE, { "char" => data["char"] })
    end

    # update physical cursor according to virtual
    @@cursor.px = @@cursor.vx
    @@cursor.py = @@cursor.vy - @@scroll_y

    # if physical cursor hit top line, scroll up
    if @@cursor.py == 0 && @@scroll_y > 0
      @@scroll_y -= 1
    # if phyiscal cursor hit last line, scroll down
    elsif @@cursor.py == get_max_y - 1
      @@scroll_y += 1
      @@cursor.py -= 1 # and move it off the cli area
    end
  end

  def handle_cursor_move(data)
    if not @focused then return end

    def lock_to_line_len
      if @@cursor.vx > current_line.length
        @@cursor.vx = current_line.length
      end
    end

    def move_up
      if @@cursor.vy > 0
        @@cursor.vy -= 1
        return true
      else
        return false
      end
    end

    def move_down
      if @@cursor.vy < max_line
        @@cursor.vy += 1
        return true
      else
        return false
      end
    end

    def move_left
      if @@cursor.vx > 0
        @@cursor.vx -= 1
        return true
      elsif move_up
        @@cursor.vx = current_line.length
        return true
      else
        return false
      end
    end

    def move_right
      if @@cursor.vx < current_line.length
        @@cursor.vx += 1
        return true
      elsif move_down
        @@cursor.vx = 0
        return true
      else
        return false
      end
    end

    funcs = {
      "up" => method(:move_up),
      "down" => method(:move_down),
      "left" => method(:move_left),
      "right" => method(:move_right),
    }

    funcs[data["direction"]].call()
    lock_to_line_len
  end

  def handle_editor_type(data)
    @@raw_lines[@@cursor.vy].insert(@@cursor.vx, data["char"])
    @@cursor.vx += 1
    Acrid.trigger_event(Acrid::Event::EDIT_LINE, { "line" => @@cursor.vy })
  end

  def handle_editor_backspace(data)
    # delete at line beginning, effectively joining the two
    if @@cursor.vx == 0 && @@cursor.vy > 0
      # append line text to end of above line
      line_text = @@raw_lines[@@cursor.vy]
      @@cursor.vy -= 1
      @@cursor.vx = @@raw_lines[@@cursor.vy].length
      @@raw_lines[@@cursor.vy] += line_text

      Acrid.trigger_event(Acrid::Event::EDIT_LINE, { "line" => @@cursor.vy })

      # remove old line
      @@raw_lines.delete_at(@@cursor.vy + 1)
      @@lines.delete_at(@@cursor.vy + 1)

      Acrid.trigger_event(
        Acrid::Event::REMOVE_LINE,
        { "line" => @@cursor.vy + 1}
      )
    # delete character from line
    elsif @@cursor.vx > 0
      first = (
        if @@cursor.vx > 1
          @@raw_lines[@@cursor.vy][..@@cursor.vx - 2]
        else
          ""
        end
      )
      second = @@raw_lines[@@cursor.vy][@@cursor.vx..]
      @@raw_lines[@@cursor.vy] = first + second
      @@cursor.vx -= 1
      Acrid.trigger_event(Acrid::Event::EDIT_LINE, { "line" => @@cursor.vy })
    end
  end

  def handle_editor_return(data)
    first = (
      if @@cursor.vx > 1
        @@raw_lines[@@cursor.vy][..@@cursor.vx - 1]
      else
        ""
      end
    )

    second = @@raw_lines[@@cursor.vy][@@cursor.vx..]

    @@raw_lines[@@cursor.vy] = first
    @@raw_lines.insert(@@cursor.vy + 1, second)
    @@lines.insert(@@cursor.vy + 1, [])

    Acrid.trigger_event(Acrid::Event::EDIT_LINE, { "line" => @@cursor.vy })
    @@cursor.vy += 1
    @@cursor.vx = 0
    Acrid.trigger_event(Acrid::Event::ADD_LINE, { "line" => @@cursor.vy })
    Acrid.trigger_event(Acrid::Event::EDIT_LINE, { "line" => @@cursor.vy })
  end

  def handle_edit_line(data)
    l_num = data["line"]
    @@lines[l_num] = tokenize(@@raw_lines[l_num], @@syntax)
  end

  def handle_focus(data)
    if data["target"] == "document" then @focused = true end
  end

  def handle_unfocus(data)
    if data["target"] == "document" then @focused = false end
  end
end