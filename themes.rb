require "curses"
require "json"
require "./fileio"

class Theme
  attr_accessor :name
  attr_accessor :token_defs

  def initialize(name, token_defs)
    @name = name
    @token_defs = token_defs.keys.map { |k|
      { name: k, regexp: Regexp.new(token_defs[k]) }
    }
  end
end

def load_theme(filename)
  data = JSON.parse(load_file(filename))
  return Theme.new(data["name"], data["tokens"])
end