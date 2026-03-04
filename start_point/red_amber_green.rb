
# Python-pytest, like most test frameworks does not
# set status to non-zero at appropriate times :-(
# So you have to look at stdout/stderr.
# The particular problem is distinguishing red from amber.
# Below is a start at trapping some specific amber errors.
# There are no doubt more.

lambda { |stdout,stderr,status|
  output = stdout + stderr

  return :amber if /=== ERRORS ===/.match(output)

  %w(
    Attribute
    Index
    Key
    Name
    Type
    UnboundLocal
  ).each do |syntax_error_prefix|
     return :amber if
       /=== FAILURES ===/.match(output) &&
         Regexp.new(".*:[0-9]+: #{syntax_error_prefix}Error").match(output)
  end

  return :green if /=== (\d+) passed/.match(output)
  return :red
}
