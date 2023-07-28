require "curses"
require "./acrid"

def input_loop
  while true
    c = Curses.getch
    Acrid::send_event(Acrid::Event::GETCH, { "char" => c })
  end
end