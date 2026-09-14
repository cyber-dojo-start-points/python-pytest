from hiker import answer

def test_life_the_universe_and_everything():
    assert answer() == 42

def test_the_answer_is_not_the_question():
    assert str(answer()) != '6 * 7'
