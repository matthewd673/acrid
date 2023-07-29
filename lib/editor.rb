require_relative "acrid"
require_relative "fileio"
require_relative "themes"
require_relative "syntax"
require_relative "input"
require_relative "cursor"
require_relative "document"
require_relative "cli"

class Editor
  attr_reader :filename
  attr_reader :file_ext

  def initialize(filename)
    @filename = filename
    @file_ext = filename.split(".")[-1]
    theme = load_theme("./config/theme.json")
    syntax = load_syntax_def("./config/syntax/#{@file_ext}.json")

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

  def get_file_text
    @@document.raw_lines.join("\n")
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

  KEY_EVENTS = {
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
    },
    Curses::Key::HOME => { # TODO: broken
      :event => Acrid::Event::CURSOR_MOVE,
      :data => { "direction" => "home" }
    },
    Curses::Key::END => { # TODO: broken
      :event => Acrid::Event::CURSOR_MOVE,
      :data => { "direction" => "end" }
    }
  }

  def handle_getch(data)

    # File.write("log.txt", data["char"].to_s + "\n", mode: "a")

    # handle special keys
    if data["char"].is_a?(Integer)
      if KEY_EVENTS[data["char"]] != nil
        event = KEY_EVENTS[data["char"]]
        Acrid.send_event(event[:event], event[:data])
      end
    # handle typing
    elsif data["char"].is_a?(String)
      Acrid.send_event(Acrid::Event::EDITOR_TYPE, { "char" => data["char"] })
    end
  end
end