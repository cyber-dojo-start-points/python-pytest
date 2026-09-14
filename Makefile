.PHONY: all lights-only matrix-only

# The three traffic-lights, then the cases in test/fixtures/
all:
	./run_tests.sh

# The three traffic-lights only, and how long each took
lights-only:
	./run_tests.sh --lights-only

# The cases in test/fixtures/ only, skipping the three traffic-lights
matrix-only:
	./run_tests.sh --matrix-only
