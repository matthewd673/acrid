class Help
  def initialize
    Acrid.register_command(Regexp.new("^h|help$"), method(:help))
  end

  def help(str)
    `open "https://github.com"` # TODO
  end

  def name
    "help"
  end

  def version
    "0.0.1"
  end
end

def mod
  return Help.new
end