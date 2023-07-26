#!/usr/bin/env ruby
require "./screen"
require "./editor"
# require "./fileio"
# require "./themes"
# require "./tokenizer"

prepare_terminal

ed = Editor.new("screen.rb")
ed.print_file_lines

restore_terminal