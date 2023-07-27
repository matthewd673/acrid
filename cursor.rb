require "curses"
require "./screen"
require "./input"

class Cursor
  # virtual x & y
  attr_accessor :vx, :vy

  # physical x & y
  attr_accessor :px, :py

  def initialize
    @vx = 0
    @vy = 0
    @px = 0
    @py = 0
  end

  def apply_physical_cursor
    Curses.setpos(@py, @px)
  end
end