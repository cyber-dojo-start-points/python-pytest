from hiker import answer

def test_the_answer_is_two_digits_long():
    assert len(str(answer())) == 2

def test_the_answer_is_three_digits_long():
    assert len(str(answer())) == 3
