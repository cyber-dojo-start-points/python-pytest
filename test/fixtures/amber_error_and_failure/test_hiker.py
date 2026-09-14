from hiker import answer, checksum

def test_life_the_universe_and_everything():
    assert answer() == 42

def test_the_checksum_of_the_answer():
    assert checksum() == 0
