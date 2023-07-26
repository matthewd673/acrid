require "./fileio"

class Editor
  def initialize(filename)
    @lines = load_file(filename)
  end

  def print_file_lines
    y = 0
    for l in @lines
      move_cursor(0, y)
      # Curses.addstr(l)
      if l.include?("require")
        write_str(l, Curses::COLOR_GREEN)
      else
        write_str(l, Curses::COLOR_RED)
      end
      y += 1
    end
  end
end