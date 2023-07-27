require "curses"
require "./screen"
require "./input"

class Cursor
  # virtual x & y
  @@vx = 0
  @@vy = 0

  # physical x & y
  @@px = 0
  @@py = 0

  def apply_physical_cursor
    Curses.setpos(@@py, @@px)
  end
end