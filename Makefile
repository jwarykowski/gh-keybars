.PHONY: lint test check

lint:
	shellcheck gh-keybars tests/*.sh

test:
	sh tests/watch_test.sh

check: lint test
