URN=urn
COMPILEFLAGS=./src/main.lisp -i ./src -o ./testenv/ccbox
PROFILEFLAGS=--profile=stack --stack-show=flame
RUNFLAGS=--run -- --json ./testenv/json.lua --boot ./testenv/bios.lua --log ./testenv/log.txt tw:/:./testenv/ccfs.json

testenv:
	mkdir testenv
	curl https://i.crzd.me/ccfs.json -o testenv/ccfs.json
	curl https://raw.githubusercontent.com/dan200/ComputerCraft/master/src/main/resources/assets/computercraft/lua/bios.lua -o testenv/bios.lua
	curl https://raw.githubusercontent.com/rxi/json.lua/master/json.lua -o testenv/json.lua

build:
	$(URN) $(COMPILEFLAGS)

run:
	$(URN) $(COMPILEFLAGS) $(RUNFLAGS)

profile-run:
	$(URN) $(COMPILEFLAGS) $(PROFILEFLAGS) $(RUNFLAGS) | tee /tmp/urn-output
	cat /tmp/urn-output | tail -n +2 | flamegraph.pl > ./testenv/profile.svg
	rm /tmp/urn-output
