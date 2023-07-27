#!/usr/bin/env ruby
require "./screen"
require "./editor"
require "./input"

module Acrid
  @@event_listeners = []

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
  end

  def self.register_handler(event, listener)
    if @@event_listeners[event] == nil
      @@event_listeners[event] = [ listener ]
    else
      @@event_listeners[event].push(listener)
    end
  end

  def self.deregister_handler(event, listener)
    if @@event_listeners[event] == nil then return end

    @@event_listeners[event].delete(listener)
  end

  def self.trigger_event(event, data)
    if @@event_listeners[event] != nil
      @@event_listeners[event].each { |l|
        l.call(data)
      }
    end
  end
end

# main
if __FILE__ == $0

  # TODO: load config
  # TODO: load mods

  # load commandline args
  filename = ARGV[0]

  if filename == nil
    puts("acrid: no filename provided")
    exit
  end

  # take over terminal and enter editor
  prepare_terminal
  Acrid.trigger_event(Acrid::Event::PREPARE_TERMINAL, {})

  ed = Editor.new(filename)
  Acrid.trigger_event(Acrid::Event::PRINT, { "target" => "editor" })

  Acrid.trigger_event(Acrid::Event::BEGIN_INPUT_LOOP, {})
  input_loop

  # cleanup
  restore_terminal
  Acrid.trigger_event(Acrid::Event::RESTORE_TERMINAL, {})
end