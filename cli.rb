require "./screen"
require "./fileio"

class Cli
  def initialize
    # load footer print "formula"
    footer_rb = load_file("config/footer.rb")
    # default behavior
    def get_footer
      return "acrid"
    end

    eval(footer_rb)
    @@footer_script = method(:get_footer)

    @@focus = false
    @@cursor = Cursor.new
  end

  def toggle_focus
    @@focus = !@@focus
  end

  def print_cli
    bot = get_max_y - 1
    move_cursor(0, bot)
    if not @@focus
      footer_str = @@footer_script.call
      write_str(footer_str[..get_max_x], 5) # TODO: don't hardcode colors
      clear_to_eol
    else
      write_str("cli focused", 0)
      clear_to_eol
    end
  end
end