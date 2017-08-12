local bit32 = bit32 or {}
return {
	["arshift"] = { tag = "var", contents = "bit32.arshift", value = bit32.arshift, },
	["band"] =    { tag = "var", contents = "bit32.band",    value = bit32.band,    },
	["bnot"] =    { tag = "var", contents = "bit32.bnot",    value = bit32.bnot,    },
	["bor"] =     { tag = "var", contents = "bit32.bor",     value = bit32.bor,     },
	["btest"] =   { tag = "var", contents = "bit32.btest",   value = bit32.btest,   },
	["bxor"] =    { tag = "var", contents = "bit32.bxor",    value = bit32.bxor,    },
	["lshift"] =  { tag = "var", contents = "bit32.lshift",  value = bit32.lshift,  },
	["rshift"] =  { tag = "var", contents = "bit32.rshift",  value = bit32.rshift,  },
}
