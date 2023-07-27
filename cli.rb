require "./screen"

class Cli
  def initialize
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
      write_str("acrid", 5) # TODO: don't hardcode colors
    else
      write_str("cli focused", 0)
    end
  end
end