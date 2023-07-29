require_relative "../acrid"
require_relative "../fileio"

def create_write_command
  Acrid.register_command(Regexp.new("^w$"), method(:command_write))
end

def command_write(str)
  save_file(Acrid.editor.filename, Acrid.editor.get_file_text)
end