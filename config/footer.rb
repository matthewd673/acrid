class Footer
  def initialize
    latest_commit = `git log`.split("\n")[0]
    @@commit = latest_commit[-7..]
  end

  def to_s
    return "acrid (@#{@@commit})"
  end
end