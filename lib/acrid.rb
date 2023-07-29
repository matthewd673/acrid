#!/usr/bin/env ruby
require_relative "screen"
require_relative "editor"
require_relative "input"
require_relative "commands"
require_relative "mods"

module Acrid
  def self.ping
    "pong"
  end

  # basic "global store" responsibilities
  @@editor = nil

  def self.create_editor(filename)
    @@editor = Editor.new(filename)
  end

  def self.editor
    @@editor
  end

  # fancy stuff
  @@event_handlers = []
  @@command_handlers = []
  @@mods = []

  module Event
    GETCH               ||= 0
    PREPARE_TERMINAL    ||= 1
    RESTORE_TERMINAL    ||= 2
    BEGIN_INPUT_LOOP    ||= 3
    PRINT               ||= 4
    FINISH_PRINT        ||= 5
    FOCUS               ||= 6
    UNFOCUS             ||= 7
    CURSOR_MOVE         ||= 8
    EDITOR_TYPE         ||= 9
    EDITOR_BACKSPACE    ||= 10
    EDITOR_RETURN       ||= 11
    EDIT_LINE           ||= 12
    REMOVE_LINE         ||= 13
    ADD_LINE            ||= 14
    SUBMIT_COMMAND      ||= 15
    TOGGLE_FOCUS        ||= 16
    DOCUMENT_SCROLL     ||= 17
  end

  def self.register_handler(event, handler)
    if @@event_handlers[event] == nil
      @@event_handlers[event] = [handler]
    else
      @@event_handlers[event].push(handler)
    end
  end

  def self.deregister_handler(event, handler)
    if @@event_handlers[event] == nil then return end

    @@event_handlers[event].delete(handler)
  end

  def self.send_event(event, data)
    if @@event_handlers[event] != nil
      @@event_handlers[event].each { |l|
        l.call(data)
      }
    end
  end

  def self.register_command(regexp, handler)
    @@command_handlers.push({
      :regexp => regexp,
      :handler => handler
    })
  end

  # TODO: deregister command (should this even be an option?)

  def self.send_command(str)
    @@command_handlers.each { |h|
      if str.match(h[:regexp])
        h[:handler].call(str)
      end
    }
  end

  def self.register_mod(mod_class)
    @@mods.push(mod_class)
  end
end

# main
if __FILE__ == $0
  # TODO: load config
  # load mods
  load_all_mods

  # load commandline args
  filename = ARGV[0]

  if filename == nil
    puts("acrid: no filename provided")
    exit
  end

  prepare_inbuilt_commands

  # take over terminal and enter editor
  Acrid.send_event(Acrid::Event::PREPARE_TERMINAL, {})
  prepare_terminal

  # editor = Editor.new(filename)
  Acrid.create_editor(filename)
  Acrid.send_event(Acrid::Event::PRINT, { "target" => "editor" })

  Acrid.send_event(Acrid::Event::BEGIN_INPUT_LOOP, {})
  input_loop

  # cleanup
  Acrid.send_event(Acrid::Event::RESTORE_TERMINAL, {})
  restore_terminal
end