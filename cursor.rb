require "curses"
require "./screen"
require "./input"

class Cursor
  @@x = 0
  @@y = 0

  def initialize
    register_input_listener(method(:handle_input))
  end

  def move_up
    if @@y > 0 then @@y -= 1 end
  end

  def move_down
    @@y += 1 # TODO
  end

  def set_physical_cursor
    Curses.setpos(@@y, @@x)
  end

  def handle_input(c)
    case c
    when Curses::Key::UP
      move_up
      set_physical_cursor
    when Curses::Key::DOWN
      move_down
      set_physical_cursor
    when Curses::Key::LEFT
      @@x -= 1
      set_physical_cursor
    when Curses::Key::RIGHT
      @@x += 1
      set_physical_cursor
    end
  end
end