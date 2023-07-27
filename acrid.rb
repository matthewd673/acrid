#!/usr/bin/env ruby
require "./screen"
require "./editor"

# load commandline args
filename = ARGV[0]

if filename == nil
  puts("acrid: no filename provided")
  exit
end

# take over terminal and enter editor
prepare_terminal

ed = Editor.new(filename)
ed.print_file_lines

# cleanup
restore_terminal