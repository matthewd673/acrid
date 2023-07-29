class Exec

  REGEXP = Regexp.new("^% (.*)")

  def initialize
    Acrid.register_command(REGEXP, method(:execute_shell_command))
  end

  def execute_shell_command(str)
    command = str.match(REGEXP)[1]
    `#{command}`
  end

  def name
    "exec"
  end

  def version
    "0.0.1"
  end
end

def mod
  return Exec.new
end