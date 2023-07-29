require "curses"
require_relative "screen"

def load_file(filename)
  begin
    file = File.open(filename)
    text = file.read
    file.close

    return text
  rescue
    return nil
  end
end

def load_file_lines(filename)
  return load_file(filename).split("\n")
end

def save_file(filename, text)
  file = File.open(filename, "w+")
  file.write(text)
  file.close
end