#!/usr/bin/env ruby
require "./screen"
require "./editor"

prepare_terminal

ed = Editor.new("screen.rb")
ed.print_file_lines

restore_terminal