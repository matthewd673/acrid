require "curses"
require "./screen"

def load_file(filename)
  file = File.open(filename)
  text = file.read
  file.close

  return text
end

def load_file_lines(filename)
  return load_file(filename).split("\n")
end