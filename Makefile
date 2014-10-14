.PHONY: all
all: index.js


# Compiling

index.js: src/chai-builder.coffee
	coffee --compile --print $< > $@


# Developing

.PHONY: test
test: all lint
	node_modules/.bin/mocha test

prepublish: all test
	git tag "v${npm_package_version}"


precommit: index.js
	git add $<

.PHONY: lint
lint:
	node_modules/.bin/coffeelint --quiet src test

.PHONY: clean
clean:
	rm -r dist
