def get_footer
  latest_commit = `git log`.split("\n")[0]
  short_commit = latest_commit[-7..]
  return "acrid (@#{short_commit})"
end