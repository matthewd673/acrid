require "curses"
require "json"
require_relative "fileio"

class Theme

  @@COLOR_NAME_MAP = {
    "white" => 0, "red" => 1, "green" => 2, "yellow" => 3, "blue" => 4,
    "magenta" => 5, "cyan" => 6,
  }

  attr_accessor :name
  attr_accessor :token_colors

  def initialize(name, color_defs)
    @name = name
    @token_colors = Hash.new
    color_defs.keys.each { |k|
      token_colors[k] = @@COLOR_NAME_MAP[color_defs[k]]
    }
    token_colors.default = @@COLOR_NAME_MAP["white"]
  end
end

def load_theme(filename)
  theme_file = load_file(filename)

  if theme_file == nil then return nil end

  data = JSON.parse(theme_file)
  return Theme.new(data["name"], data["colors"])
end