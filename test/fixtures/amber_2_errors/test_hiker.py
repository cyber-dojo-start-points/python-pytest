from hiker import answer

def test_life_the_universe_and_everything():
    assert answer() == 42

def test_the_answer_is_two_digits_long():
    assert len(str(answer())) == 2
