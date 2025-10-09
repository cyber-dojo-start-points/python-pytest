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
  cyber_dojo_delete_dirs .mypy_cache
  #cyber_dojo_delete_files ...
}
cyber_dojo_enter
trap cyber_dojo_exit EXIT SIGTERM

# --------------------------------------------------------------
# Print a short summary of each test to stdout.
# Can produce a lot of output on parameterized tests.
export PYTEST_ADDOPTS="-v"

echo MyPy
mypy *.py | tee ${REPORT_DIR}/mypy.txt || true

# --------------------------------------------------------------
# By default pytest captures stdout/stderr.
# The --capture=tee-sys option ensures sys.stdout and
# sys.stderr are actually written to.

echo
coverage3 run \
  --source=${CYBER_DOJO_SANDBOX} \
  --module pytest \
  --capture=tee-sys \
  --random-order-bucket=global \
    *test*.py

# https://coverage.readthedocs.io/en/latest

coverage3 report \
  --show-missing \
    > ${REPORT_DIR}/coverage.txt

# http://pycodestyle.pycqa.org/en/latest/intro.html#configuration

pycodestyle \
  ${CYBER_DOJO_SANDBOX} \
    --show-source `# show source code for each error` \
    --show-pep8   `# show relevent text from pep8` \
    --ignore E302,E305,W293 \
    --max-line-length=80 \
      > ${REPORT_DIR}/style.txt

# E302 expected 2 blank lines, found 0
# E305 expected 2 blank lines after end of function or class
# W293 blank line contains whitespace
