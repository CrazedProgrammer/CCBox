URN=urn
URNFLAGS=
RUNFLAGS=

testenv:
	mkdir testenv
	curl https://i.crzd.me/ccfs.json -o testenv/ccfs.json
	curl https://raw.githubusercontent.com/dan200/ComputerCraft/master/src/main/resources/assets/computercraft/lua/bios.lua -o testenv/bios.lua
	curl https://raw.githubusercontent.com/rxi/json.lua/master/json.lua -o testenv/json.lua

build:
	$(URN) ./src/main.lisp -i ./src -o ./testenv/ccbox $(URNFLAGS)

run:
	$(MAKE) build URNFLAGS+="--run -- --json ./testenv/json.lua --boot ./testenv/bios.lua --log ./testenv/log.txt tw:/:./testenv/ccfs.json"
