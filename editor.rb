require "./fileio"
require "./themes"
require "./syntax"
require "./input"
require "./cursor"

class Editor
  @@cursor
  @@scroll_y = 0

  def initialize(filename)
    ext = filename.split(".")[-1]
    @theme = load_theme("config/theme.json")
    @syntax_def = load_syntax_def("config/syntax/#{ext}.json")

    raw_lines = load_file_lines(filename)
    @lines = raw_lines.map { |l|
      tokenize(l, @syntax_def)
    }

    @@cursor = Cursor.new

    register_input_listener(method(:handle_input))
  end

  def print_file_lines
    y = 0
    for i in @@scroll_y..(@@scroll_y+20)
      move_cursor(0, y)
      @lines[i].each { |t|
        write_str(t.image, @theme.token_colors[t.type])
      }
      y += 1
    end

    # reset cursor pos
    @@cursor.set_physical_cursor
  end

  def handle_input(c)
    # write_str(c, 0)
  end
end