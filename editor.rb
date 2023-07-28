require "./acrid"
require "./fileio"
require "./themes"
require "./syntax"
require "./input"
require "./cursor"
require "./document"
require "./cli"

class Editor
  def initialize(filename)
    ext = filename.split(".")[-1]
    theme = load_theme("config/theme.json")
    syntax = load_syntax_def("config/syntax/#{ext}.json")

    @@document = Document.new(filename, theme, syntax)
    @@cli = Cli.new

    @@document.focused = true
    @@cli.focused = false

    Acrid.register_handler(Acrid::Event::PRINT, method(:handle_print))
    Acrid.register_handler(Acrid::Event::GETCH, method(:handle_input))
  end

  def handle_print(data)
    if data["target"] != "editor" then return end

    Acrid.trigger_event(Acrid::Event::PRINT,
      { "target" => "document" }
    )
    Acrid.trigger_event(Acrid::Event::PRINT, { "target" => "cli" })

    Acrid.trigger_event(Acrid::Event::FINISH_PRINT, {})
  end

  def flip_focus
    if @@document.focused
      Acrid.trigger_event(Acrid::Event::UNFOCUS, { "target" => "document" })
      Acrid.trigger_event(Acrid::Event::FOCUS, { "target" => "cli" })
    else
      Acrid.trigger_event(Acrid::Event::UNFOCUS, { "target" => "cli" })
      Acrid.trigger_event(Acrid::Event::FOCUS, { "target" => "document" })
    end
  end

  def handle_input(data)
    case data["char"]
    when "p"
      flip_focus
    when "q"
      exit
    end

    # TODO: theres probably a better place for this
    Acrid.trigger_event(Acrid::Event::PRINT, { "target" => "editor" })
  end
end