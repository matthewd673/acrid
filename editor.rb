require "./fileio"
require "./themes"
require "./syntax"
require "./input"
require "./cursor"
require "./document"
require "./cli"

class Editor
  @@scroll_y = 0

  def initialize(filename)
    ext = filename.split(".")[-1]
    theme = load_theme("config/theme.json")
    syntax = load_syntax_def("config/syntax/#{ext}.json")

    @@document = Document.new(filename, theme, syntax)
    @@cursor = Cursor.new

    @@cli = Cli.new

    register_input_listener(method(:handle_input))
  end

  def print
    @@document.print_lines(@@scroll_y)

    @@cli.print_cli

    @@cursor.set_physical_cursor # reset cursor pos
  end

  def handle_input(c)
    if c == 'p' then @@cli.toggle_focus end # TODO: temp
    if c == 'q' then exit end # TODO: temp

    # TODO: theres probably a better place for this
    print
  end
end