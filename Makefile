URN = urn
override COMPILEFLAGS += ./src/main.lisp -i ./src -o ./buildenv/ccbox
override EMBEDFLAGS += -fembed-bios -fembed-ccfs
override PROFILEFLAGS += --profile=stack --stack-show=flame
override RUNFLAGS += --run -- --bios ./buildenv/bios.lua --log ./buildenv/log.txt tw:/:./buildenv/ccfs.json
override REPLFLAGS += --repl
override TESTFLAGS += -fstrict -i ./src

TESTS=$(shell find tests -type f -name '*.lisp')

.DEFAULT_GOAL := build
.PHONY: buildenv build build-embed run profile-run repl \
        test $(TESTS)

buildenv:
	mkdir buildenv
	cp assets/ccfs.json buildenv/ccfs.json
	curl https://raw.githubusercontent.com/dan200/ComputerCraft/master/src/main/resources/assets/computercraft/lua/bios.lua -o buildenv/bios.lua

build:
	$(URN) $(COMPILEFLAGS)

build-embed:
	$(URN) $(COMPILEFLAGS) $(EMBEDFLAGS)

run:
	$(URN) $(COMPILEFLAGS) $(RUNFLAGS)

run-profile:
	$(URN) $(COMPILEFLAGS) $(PROFILEFLAGS) $(RUNFLAGS) | tee /tmp/urn-output
	cat /tmp/urn-output | tail -n +2 | flamegraph.pl > ./buildenv/profile.svg
	rm /tmp/urn-output

repl:
	$(URN) $(COMPILEFLAGS) $(REPLFLAGS)

test: ${TESTS}

${TESTS}:
	$(eval TMP := $(shell mktemp -d))
	${URN} $(basename $@) -o ${TMP} $(TESTFLAGS) $(RUNFLAGS)
	@rm -rf ${TMP}.lisp ${TMP}.lua ${TMP}
