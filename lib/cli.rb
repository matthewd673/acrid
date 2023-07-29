require_relative "screen"
require_relative "fileio"

# default footer
class Footer
  def to_s
    "acrid"
  end
end

class Cli
  attr_accessor :focused

  def initialize
    @@cursor = Cursor.new

    @@input = ""

    # load footer "formula" class
    footer_rb = load_file("config/footer.rb")
    eval(footer_rb)
    @@footer = Footer.new # this will be the loaded footer or default

    @focused = false

    Acrid.register_handler(Acrid::Event::PRINT, method(:handle_print))
    Acrid.register_handler(
      Acrid::Event::FINISH_PRINT,
      method(:handle_finish_print)
    )

    Acrid.register_handler(
      Acrid::Event::CURSOR_MOVE,
      method(:handle_cursor_move)
    )
    Acrid.register_handler(
      Acrid::Event::EDITOR_TYPE,
      method(:handle_editor_type)
    )
    Acrid.register_handler(
      Acrid::Event::EDITOR_BACKSPACE,
      method(:handle_editor_backspace)
    )
    Acrid.register_handler(
      Acrid::Event::EDITOR_RETURN,
      method(:handle_editor_return)
    )

    Acrid.register_handler(Acrid::Event::FOCUS, method(:handle_focus))
    Acrid.register_handler(Acrid::Event::UNFOCUS, method(:handle_unfocus))
  end

  def handle_print(data)
    if data["target"] != "cli" then return end

    bot = get_max_y - 1
    move_cursor(0, bot)
    if not @focused
      write_str(@@footer.to_s[..get_max_x], 5) # TODO: don't hardcode colors
      clear_to_eol
    else
      write_str(@@input, 0)
      clear_to_eol
    end

    Acrid.send_event(Acrid::Event::FINISH_PRINT, {})
  end

  def handle_finish_print(data)
    if not @focused then return end

    move_cursor(@@cursor.px, @@cursor.py)
  end

  # update physical cursor according to the virtual
  def move_physical_cursor
    @@cursor.px = @@cursor.vx
    @@cursor.py = get_max_y - 1 # always bottom line
  end

  def handle_cursor_move(data)
    if not @focused then return end

    def move_left
      if @@cursor.vx > 0 then @@cursor.vx -= 1 end
    end
    def move_right
      if @@cursor.vx < @@input.length then @@cursor.vx += 1 end
    end

    if data["direction"] == "left" then move_left
    elsif data["direction"] == "right" then move_right
    end

    move_physical_cursor
    move_cursor(@@cursor.px, @@cursor.py)
  end

  def handle_editor_type(data)
    if not @focused then return end

    @@input.insert(@@cursor.vx, data["char"])

    @@cursor.vx += 1
    move_physical_cursor

    # tell self to print updated state
    Acrid.send_event(Acrid::Event::PRINT, { "target" => "cli" })
  end

  def handle_editor_backspace(data)
    if not @focused then return end

    if @@cursor.vx == 0 then return end

    first = (
      if @@cursor.vx > 1
        @@input[..@@cursor.vx - 2]
      else
        ""
      end
    )
    second = @@input[@@cursor.vx..]
    @@input = first + second
    @@cursor.vx -= 1

    move_physical_cursor

    # tell self to print updated state
    Acrid.send_event(Acrid::Event::PRINT, { "target" => "cli" })
  end

  def handle_editor_return(data)
    if not @focused then return end

    Acrid.send_event(
      Acrid::Event::SUBMIT_COMMAND,
      { "command" => @@input }
    )

    # reset input to default
    @@input = ""
    @@cursor.vx = 0
    move_physical_cursor

    # tell self to print updated state
    Acrid.send_event(Acrid::Event::PRINT, { "target" => "cli" })
  end

  def handle_focus(data)
    if data["target"] == "cli" then @focused = true end
  end

  def handle_unfocus(data)
    if data["target"] == "cli" then @focused = false end
  end
end