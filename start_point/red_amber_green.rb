
# Python-pytest, like most test frameworks, does not set its status
# to something that tells a failing test apart from a test that never
# ran, so the colour comes from stdout/stderr.
#
# An assertion failure is a test failing, which is red. Anything else
# that stops a test is amber: a raised exception, a name that does not
# exist, a file that will not parse, a suite with no tests in it.
#
# pytest ends each traceback with '<file>:<line>: <ExceptionName>', so
# the exceptions are named by the framework rather than listed here.
# Only AssertionError has to be known, which keeps a newly met
# exception amber instead of silently red.

lambda { |stdout,stderr,status|
  output = stdout + stderr

  # A suite that would not load, or a file that would not compile.
  return :amber if /=== ERRORS ===/.match(output)
  return :amber if /SyntaxError/.match(output)

  # Nothing was collected, so nothing was proved either way.
  return :amber if /no tests ran/.match(output)

  if /=== FAILURES ===/.match(output)
    exceptions = output.scan(/^.+:\d+: (\w*Error)\b/).flatten
    return :amber if exceptions.any? { |name| name != 'AssertionError' }
    return :red
  end

  return :green if /(\d+) passed/.match(output)
  return :red
}
