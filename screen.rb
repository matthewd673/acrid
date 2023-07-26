require "curses"

def prepare_terminal
  Curses.init_screen
  Curses.getch
end