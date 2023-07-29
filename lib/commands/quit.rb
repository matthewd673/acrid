def create_quit_command
  Acrid.register_command(Regexp.new("^q|quit$"), method(:command_quit))
end

def command_quit(str)
  exit
end