#!/usr/bin/env ruby
require "./screen"
require "./editor"
require "./input"

module Acrid
  @@event_listeners = []

  module Event
    GETCH ||= 0
  end

  def self.register_event_listener(event, listener)
    if @@event_listeners[event] == nil
      @@event_listeners[event] = [ listener ]
    else
      @@event_listeners[event].push(listener)
    end
  end

  def self.trigger_event(event, body)
    if @@event_listeners[event] != nil
      @@event_listeners[event].each { |l|
        l.call(body)
      }
    end
  end
end

# main
if __FILE__ == $0
  # load commandline args
  filename = ARGV[0]

  if filename == nil
    puts("acrid: no filename provided")
    exit
  end

  # take over terminal and enter editor
  prepare_terminal

  ed = Editor.new(filename)
  ed.print

  input_loop

  # cleanup
  restore_terminal
end