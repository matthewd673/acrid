require "./screen"
require "./cursor"

class Document
  attr_accessor :focused

  def initialize(filename, theme, syntax)
    @@theme = theme
    @@syntax = syntax

    raw_lines = load_file_lines(filename)
    @@lines = raw_lines.map { |l|
      tokenize(l, @@syntax)
    }

    @@cursor = Cursor.new
  end

  def print_lines(scroll_y)
    max_x = get_max_x
    max_y = get_max_y

    # print lines from file until screen is full
    y = 0
    for i in scroll_y..(scroll_y + max_y)
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

    def post_print
      if focused then @@cursor.apply_physical_cursor end
    end

    # clear bottom if doc lines don't fill screen
    for i in y..max_y
      move_cursor(0, i)
      clear_to_eol
    end
  end
end