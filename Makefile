TEST_FILES = t/*.t

test-verbose:
	@prove -v $(TEST_FILES)

test:
	@prove $(TEST_FILES)

build:
	./parse.pl ./angular.js/src/ html-stuff
