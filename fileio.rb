require "curses"
require "./screen"

def load_file(filename)
  file = File.open(filename)
  lines = file.readlines.map(&:chomp)
  file.close

  return lines
end