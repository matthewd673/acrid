require_relative "acrid"
require_relative "fileio"
require_relative "commands/quit"
require_relative "commands/write"

def prepare_inbuilt_commands
  # load a few basic default commands
  create_quit_command
  create_write_command

  # trigger all commands when event is fired
  Acrid.register_handler(
    Acrid::Event::SUBMIT_COMMAND,
    method(:handle_submit_command)
  )
end

def handle_submit_command(data)
  Acrid.send_command(data["command"])
end