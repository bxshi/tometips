SHELL := /bin/bash

VERSIONS := 1.1.5 1.2.0 1.2.1 1.2.2 1.2.3
VERSIONS += master

# GitHub Pages output
PAGES_OUTPUT = ../tometips.github.io

all: t-engine4 img html/js/templates.js html/js/partials.js \
	$(patsubst %,html/data/%/tome.json,$(VERSIONS)) \
	$(patsubst %,html/data/%/classes.json,$(VERSIONS)) \
	$(patsubst %,html/data/%/changes.talents.json,$(VERSIONS)) \
	$(patsubst %,html/data/%/recent-changes.talents.json,$(VERSIONS))

html/data/%/tome.json: % talent_spoilers.lua
	lua talent_spoilers.lua $< $(dir $@)

html/data/%/classes.json: % class_spoilers.lua
	lua class_spoilers.lua $< $(dir $@)

html/js/partials.js: html/js/partials/*.handlebars
	handlebars --min --partial html/js/partials > $@

html/js/templates.js: html/js/templates/*.handlebars
	handlebars --min html/js/templates > $@

clean:
	rm -rf html/data/* html/img/talents/*.png html/img/talents/*/*.png html/js/templates.js html/js/partials.js

publish:
	test -d $(PAGES_OUTPUT)
	rsync --recursive --times --exclude=*.template --delete --verbose html/* $(PAGES_OUTPUT)

# Changes from one version to the next
changes.mk: Makefile scripts/make-changes-mk.sh
	scripts/make-changes-mk.sh $(VERSIONS) > $@
-include changes.mk

# Convert and publish images.
img: t-engine4
	scripts/prepare-img.sh

# Pretty-prints each of the JSON files.
pretty: html/data/$(VERSION)
	for file in $$(find html -name '*.json'); do python -mjson.tool $$file > $$file.tmp && mv $$file.tmp $$file; done

# git shortcuts to automate maintenance of the local source tree
t-engine4:
	git clone http://git.net-core.org/darkgod/t-engine4.git

# git shortcut - git pull
pull:
	cd t-engine4 && git checkout master
	cd t-engine4 && git pull

# Symlinks and working copies
master:
	scripts/link-master-src.sh

$(filter-out master,$(VERSIONS)):
	scripts/copy-tag-src.sh $@

.PHONY: clean pretty img pull publish

