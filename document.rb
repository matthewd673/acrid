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

  def handle_getch(data)
    if not @focused then return end

    case data["char"]
    # move through document with arrow keys
    when Curses::Key::UP
      Acrid.trigger_event(Acrid::Event::CURSOR_MOVE, { "direction" => "up" })
    when Curses::Key::DOWN
      Acrid.trigger_event(Acrid::Event::CURSOR_MOVE, { "direction" => "down" })
    when Curses::Key::LEFT
      Acrid.trigger_event(Acrid::Event::CURSOR_MOVE, { "direction" => "left" })
    when Curses::Key::RIGHT
      Acrid.trigger_event(Acrid::Event::CURSOR_MOVE, { "direction" => "right" })
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

  def handle_focus(data)
    if data["target"] == "document" then @focused = true end
  end

  def handle_unfocus(data)
    if data["target"] == "document" then @focused = false end
  end
end