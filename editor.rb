require "./fileio"
require "./themes"
require "./syntax"

class Editor
  def initialize(filename)
    ext = filename.split(".")[-1]
    @theme = load_theme("config/theme.json")
    @syntax_def = load_syntax_def("config/syntax/#{ext}.json")

    raw_lines = load_file_lines(filename)
    @lines = raw_lines.map { |l|
      tokenize(l, @syntax_def)
    }
  end

  def print_file_lines
    # write_str(@theme.name, Curses::COLOR_CYAN)

    y = 0
    @lines.each { |l|
      move_cursor(0, y)
      l.each { |t|
        color = @theme.token_colors[t[:type]]
        # useful for debug:
        # write_str("<#{t[:type]} #{color}>#{t[:image]}</#{t[:type]}>", color)
        write_str(t[:image], color)
      }
      y += 1
    }
  end
end