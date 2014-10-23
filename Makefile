VERSION=$(shell node -e 'console.log(require("./package.json")["version"])')


.PHONY: all
all: index.js


# Compiling

index.js: src/chai-builder.coffee
	coffee --compile --print $< > $@


# Developing

.PHONY: test
test: all lint
	node_modules/.bin/mocha test

.PHONY: lint
lint:
	node_modules/.bin/coffeelint --quiet src test


publish: test assert-clean-tree assert-proper-version
	git tag "v${VERSION}"
	git push
	npm publish

precommit: all
	git add index.js


.PHONY: assert-clean-tree
assert-clean-tree:
	@(git diff --exit-code --no-patch \
    && git diff --cached --exit-code --no-patch) \
		|| (echo "There are uncommited files" && false)

.PHONY: assert-proper-version
assert-proper-version:
	@if echo "${VERSION}" | grep --quiet '.*-dev'; \
	 then echo "Found development version" && false; fi
