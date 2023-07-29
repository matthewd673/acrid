# adapted from exec.rb

class Eval
  REGEXP = Regexp.new("^eval (.*)")

  def initialize
    Acrid.register_command(REGEXP, method(:eval_string))
  end

  def eval_string(str)
    code = str.match(REGEXP)[1]
    eval(code)
  end

  def name
    "eval"
  end

  def version
    "0.0.1"
  end
end

def mod
  return Eval.new
end