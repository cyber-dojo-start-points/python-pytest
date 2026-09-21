set -e

# --------------------------------------------------------------
# Text files under /sandbox are automatically returned...
source ~/cyber_dojo_fs_cleaners.sh
export REPORT_DIR=${CYBER_DOJO_SANDBOX}/report
function cyber_dojo_enter()
{
  # 1. Only return _newly_ generated reports.
  cyber_dojo_reset_dirs ${REPORT_DIR}
}
function cyber_dojo_exit()
{
  # 2. Remove text files we don't want returned.
  cyber_dojo_delete_dirs .pytest_cache
  cyber_dojo_delete_dirs __pycache__
  #cyber_dojo_delete_files ...
}
cyber_dojo_enter
trap cyber_dojo_exit EXIT SIGTERM

# --------------------------------------------------------------
# Print a short summary of each test to stdout.
# Can produce a lot of output on parameterized tests.
export PYTEST_ADDOPTS="-v"

# --------------------------------------------------------------
# mypy spends most of its time on typeshed's stubs for the standard library
# rather than on anything you wrote, and that work is the same on every test-run.
# The image holds it already analysed; this says where. Left to itself mypy
# would use .mypy_cache here in the sandbox, which starts empty every run.
export MYPY_CACHE_DIR=/mypy-cache

# coverage watches your code through sys.monitoring rather than by a callback
# on every line, which is a good deal cheaper. The numbers it reports are the
# same either way.
export COVERAGE_CORE=sysmon

# --------------------------------------------------------------
# mypy, the tests and pycodestyle each read the sandbox and write nowhere
# the others read, so they run at once and their output is held until its
# turn comes. What reaches stdout, and which reports exist, is what running
# them one after another produces; only the waiting overlaps. Each phase is
# a fresh python interpreter, and the three of them were over half of a
# [test] press: 250ms of which the tests themselves were 126ms.
# HELD is on /tmp, which is a tmpfs the exit trap never walks, so nothing
# here comes back as a file.
readonly HELD=$(mktemp -d)

# --------------------------------------------------------------
# Every .py file is compiled, at any depth, including files nothing
# imports yet. A file you are halfway through writing is reported
# here instead of being quietly ignored. Nothing below runs until
# every file parses.
echo Compile
python3 -m compileall -q ${CYBER_DOJO_SANDBOX}

# Each tool's two streams are held apart. The traffic-light lambda is handed
# stdout and stderr separately, so a byte that moved from one to the other
# could change the colour.
mypy $(find ${CYBER_DOJO_SANDBOX} -name '*.py') > ${HELD}/mypy 2> ${HELD}/mypy.err || true &
readonly MYPY_PID=$!

# http://pycodestyle.pycqa.org/en/latest/intro.html#configuration
# Held rather than written straight to REPORT_DIR: a run whose tests fail
# stops before this report is reached, so the file must not appear then.
pycodestyle ${CYBER_DOJO_SANDBOX} \
  --show-source `# show source code for each error` \
  --show-pep8   `# show relevant text from pep8` \
  --ignore E302,E305,W293 \
  --max-line-length=80 \
  > ${HELD}/style 2> ${HELD}/style.err &
readonly STYLE_PID=$!

# --------------------------------------------------------------
# By default pytest captures stdout/stderr.
# The --capture=tee-sys option ensures sys.stdout and
# sys.stderr are actually written to.
#
# pytest is handed the whole directory, so it finds your tests at any
# depth. It recognizes a file as a test file when its name starts with
# test_ or ends with _test, so a test in a file named anything else
# will not run.

coverage run \
  --source=${CYBER_DOJO_SANDBOX} \
  --module pytest \
  --capture=tee-sys \
  --random-order-bucket=global \
    ${CYBER_DOJO_SANDBOX} > ${HELD}/pytest 2> ${HELD}/pytest.err &
readonly PYTEST_PID=$!

# --------------------------------------------------------------
# Replayed in the order running them one after another would have printed.
echo
echo MyPy
wait ${MYPY_PID}
tee ${REPORT_DIR}/mypy.txt < ${HELD}/mypy
cat ${HELD}/mypy.err >&2

echo
# The exit status is the tests' own, so a failing suite still stops the run
# here, before the two reports below, exactly as running in sequence did.
wait ${PYTEST_PID} || PYTEST_STATUS=$?
cat ${HELD}/pytest
cat ${HELD}/pytest.err >&2
if [ -n "${PYTEST_STATUS:-}" ]; then
  exit ${PYTEST_STATUS}
fi

# https://coverage.readthedocs.io/en/latest
echo
coverage report \
  --show-missing \
  | tee ${REPORT_DIR}/coverage.txt

echo
wait ${STYLE_PID} || true
cat ${HELD}/style.err >&2
cp ${HELD}/style ${REPORT_DIR}/style.txt

# E302 expected 2 blank lines, found 0
# E305 expected 2 blank lines after end of function or class
# W293 blank line contains whitespace
