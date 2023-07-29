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

def load_file_lines(filename, create = false)
  file_text = load_file(filename)

  if create && file_text == nil
    file_text = "" # default value: empty
    file = File.open(filename, "w+")
    file.write(file_text)
    file.close

    File.write("log.txt", "wowa", mode: "a")

  end

  lines = file_text.split("\n")
  if lines.length == 0 then lines.push("") end
  return lines
end

def save_file(filename, text)
  file = File.open(filename, "w+")
  file.write(text)
  file.close
end