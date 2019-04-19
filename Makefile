URN = urn
override COMPILEFLAGS += ./src/main.lisp -i ./src -o ./buildenv/ccbox
override EMBEDFLAGS += -fembed-bios -fembed-json -fembed-ccfs
override PROFILEFLAGS += --profile=stack --stack-show=flame
override RUNFLAGS += --run -- --json ./buildenv/json.lua --bios ./buildenv/bios.lua --log ./buildenv/log.txt tw:/:./buildenv/ccfs.json
override REPLFLAGS += --repl

buildenv:
	mkdir buildenv
	curl https://i.crzd.me/ccfs.json -o buildenv/ccfs.json
	curl https://raw.githubusercontent.com/dan200/ComputerCraft/master/src/main/resources/assets/computercraft/lua/bios.lua -o buildenv/bios.lua
	curl https://raw.githubusercontent.com/rxi/json.lua/master/json.lua -o buildenv/json.lua

build:
	$(URN) $(COMPILEFLAGS)

build-embed:
	$(URN) $(COMPILEFLAGS) $(EMBEDFLAGS)

run:
	$(URN) $(COMPILEFLAGS) $(RUNFLAGS)

profile-run:
	$(URN) $(COMPILEFLAGS) $(PROFILEFLAGS) $(RUNFLAGS) | tee /tmp/urn-output
	cat /tmp/urn-output | tail -n +2 | flamegraph.pl > ./buildenv/profile.svg
	rm /tmp/urn-output

repl:
	$(URN) $(COMPILEFLAGS) $(REPLFLAGS)
