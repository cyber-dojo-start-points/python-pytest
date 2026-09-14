# Named neither test_*.py nor *_test.py, so pytest does not collect it and
# these tests do not run. The assertion is one that would fail, so a green
# says it really did not run rather than that it ran and passed.
from hiker import answer

def test_the_answer_is_three_digits_long():
    assert len(str(answer())) == 3
