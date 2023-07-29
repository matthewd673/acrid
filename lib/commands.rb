require_relative "acrid"
require_relative "fileio"

def prepare_inbuilt_commands
  # define a few basic default commands
  # Acrid.register_command(Regexp.new('^h|help$'), method(:command_help))
  Acrid.register_command(Regexp.new("^q|quit$"), method(:command_quit))

  # trigger all commands when event is fired
  Acrid.register_handler(
    Acrid::Event::SUBMIT_COMMAND,
    method(:handle_submit_command)
  )
end

def handle_submit_command(data)
  File.write("log.txt", data["command"] + "\n", mode: "a")
  Acrid.send_command(data["command"])
end

# def command_help(str)
#   # TODO
# end

def command_quit(str)
  exit
end