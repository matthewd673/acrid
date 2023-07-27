require "curses"

$input_listeners = []

def register_input_listener(listener)
  $input_listeners.push(listener)
end

def input_loop
  while true
    # fetch input character and call all input_listeners
    c = Curses.getch
    $input_listeners.each { |l|
      l.call(c)
    }
  end
end