require "./acrid"
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
    @@cli = Cli.new

    @@document.focused = true
    @@cli.focused = false

    # register_input_listener(method(:handle_input))
    Acrid.register_event_listener(Acrid::Event::GETCH, method(:handle_input))
  end

  def print
    @@document.print_lines(@@scroll_y)
    @@cli.print_cli

    @@document.post_print
    @@cli.post_print
  end

  def flip_focus
    @@document.focused = @@cli.focused
    @@cli.focused = !@@cli.focused
  end

  def handle_input(data)
    if data["char"] == 'p' then flip_focus end # TODO: temp
    if data["char"] == 'q' then exit end # TODO: temp

    # TODO: theres probably a better place for this
    print
  end
end