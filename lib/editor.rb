require_relative "acrid"
require_relative "fileio"
require_relative "themes"
require_relative "syntax"
require_relative "input"
require_relative "cursor"
require_relative "document"
require_relative "cli"

class Editor
  def initialize(filename)
    ext = filename.split(".")[-1]
    theme = load_theme("./config/theme.json")
    syntax = load_syntax_def("./config/syntax/#{ext}.json")

    @@document = Document.new(filename, theme, syntax)
    @@cli = Cli.new

    @@document.focused = true
    @@cli.focused = false

    Acrid.register_handler(Acrid::Event::PRINT, method(:handle_print))
    Acrid.register_handler(Acrid::Event::GETCH, method(:handle_getch))
    Acrid.register_handler(
      Acrid::Event::TOGGLE_FOCUS,
      method(:handle_toggle_focus)
    )
  end

  def handle_print(data)
    if data["target"] != "editor" then return end

    Acrid.send_event(Acrid::Event::PRINT,
      { "target" => "document" }
    )
    Acrid.send_event(Acrid::Event::PRINT, { "target" => "cli" })
  end

  def handle_toggle_focus(data)
    if @@document.focused
      Acrid.send_event(Acrid::Event::UNFOCUS, { "target" => "document" })
      Acrid.send_event(Acrid::Event::FOCUS, { "target" => "cli" })
    else
      Acrid.send_event(Acrid::Event::UNFOCUS, { "target" => "cli" })
      Acrid.send_event(Acrid::Event::FOCUS, { "target" => "document" })
    end

    Acrid.send_event(Acrid::Event::PRINT, { "target" => "editor" })
  end

  def handle_getch(data)
    # TODO: make const
    key_events = {
      Curses::Key::UP => {
        :event => Acrid::Event::CURSOR_MOVE,
        :data => { "direction" => "up" }
      },
      Curses::Key::DOWN => {
        :event => Acrid::Event::CURSOR_MOVE,
        :data => { "direction" => "down" }
      },
      Curses::Key::LEFT => {
        :event => Acrid::Event::CURSOR_MOVE,
        :data => { "direction" => "left" }
      },
      Curses::Key::RIGHT => {
        :event => Acrid::Event::CURSOR_MOVE,
        :data => { "direction" => "right" }
      },
      127 => { # macOS delete key
        :event => Acrid::Event::EDITOR_BACKSPACE,
        :data => {}
      },
      13 => { # macOS enter key
        :event => Acrid::Event::EDITOR_RETURN,
        :data => {}
      },
      27 => { # 27 is escape but also alt I think? TODO: figure this out
        :event => Acrid::Event::TOGGLE_FOCUS,
        :data => {}
      }
    }

    # handle special keys
    if data["char"].is_a?(Integer)
      if key_events[data["char"]] != nil

        event = key_events[data["char"]]
        Acrid.send_event(event[:event], event[:data])
      end
    # handle typing
    elsif data["char"].is_a?(String)
      Acrid.send_event(Acrid::Event::EDITOR_TYPE, { "char" => data["char"] })
    end

    # TODO: obviously temporary and awful
    case data["char"]
    # when "p"
    #   flip_focus
    when "q"
      exit
    end

    # Acrid.send_event(Acrid::Event::PRINT, { "target" => "editor" })
  end
end