require "curses"
include Curses

def prepare_terminal
  @DEFAULT_BACKGROUND_COLOR = 8

  # basic setup
  init_screen
  use_default_colors
  nonl
  noecho
  stdscr.keypad(true)

  # TODO: formalize no color support
  if !has_colors?
    addstr("No color support\n")
  else
    start_color

    # initialize all colors
    colors.times { |i|
      init_pair(i, i, @DEFAULT_BACKGROUND_COLOR)
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