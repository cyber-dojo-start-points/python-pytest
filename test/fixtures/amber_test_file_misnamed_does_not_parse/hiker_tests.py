# Named neither test_*.py nor *_test.py, so pytest never collects it, and
# half written so it does not parse either. Vanishing is what it must not do:
# compileall compiles every .py file, so this one is seen even though pytest
# would not run it.
from hiker import answer

def test_the_answer_is_two_digits_long():
    assert len(str(answer()) == 2
