HUGO ?= hugo
THEME_DIR ?= ../oink
BIND ?= 127.0.0.1
PORT ?= 1313

.PHONY: sync dev serve build
sync:
	./scripts/sync-handbook.sh

dev: sync
	GOWORK=off HUGO_MODULE_WORKSPACE=off HUGO_MODULE_REPLACEMENTS='github.com/pgsty/oink -> $(abspath $(THEME_DIR))' $(HUGO) server --renderToMemory --bind $(BIND) --port $(PORT)

serve: sync
	env -u HUGO_MODULE_REPLACEMENTS GOWORK=off HUGO_MODULE_WORKSPACE=off $(HUGO) server --bind $(BIND) --port $(PORT)

build: sync
	env -u HUGO_MODULE_REPLACEMENTS GOWORK=off HUGO_MODULE_WORKSPACE=off $(HUGO) --minify --environment production --printPathWarnings
