require "./fileio"
require "./themes"
require "./tokenizer"

class Editor
  def initialize(filename)
    @theme = load_theme("theme.json")

    raw_lines = load_file_lines(filename)
    @lines = raw_lines.map { |l|
      tokenize(l, @theme.token_defs)
    }
  end

  def print_file_lines
    # write_str(@theme.name, Curses::COLOR_CYAN)

    y = 15
    i = 0
    @lines.each { |l|
      move_cursor(0, y)
      # Curses.addstr(l)
      l.each { |t|
        if t[:type].eql?("text")
          i = 1
        elsif t[:type].eql?("number")
          i = 2
        else
          i = 0
        end
        write_str(t[:image], i)
        # i += 1
        # i = i % 15
      }
      y += 1
    }
  end
end