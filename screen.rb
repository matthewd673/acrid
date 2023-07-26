require "curses"
include Curses

def prepare_terminal
  # basic setup
  init_screen
  noecho
  stdscr.keypad(true)

  # TODO: formalize no color support
  if !has_colors?
    addstr("No color support\n")
  else
    start_color

    # initialize all colors
    colors.times { |i|
      init_pair(i, i, 0)
    }
  end
end

def restore_terminal
  # basic cleanup
  getch
  close_screen
end

def move_cursor(x, y)
  setpos(y, x)
end

def write_str(str, color)
  # set color and write the string
  attrset(color_pair(color))
  addstr(str)
end