require "./screen"
require "./fileio"

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
      write_str("cli focused", 0)
      clear_to_eol
    end
  end

  def handle_finish_print(data)
    if focused then @@cursor.apply_physical_cursor end
  end

  def handle_focus(data)
    if data["target"] == "cli" then @focused = true end
  end

  def handle_unfocus(data)
    if data["target"] == "cli" then @focused = false end
  end
end