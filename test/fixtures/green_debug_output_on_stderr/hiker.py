import sys

def answer() -> int:
    # The learner is watching the call happen and has not taken this out yet.
    print('answer was called', file=sys.stderr)
    return 6 * 7
