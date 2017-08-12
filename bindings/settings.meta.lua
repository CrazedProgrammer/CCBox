local settings = settings or {}
return {
	["clear"] =    { tag = "var", contents = "settings.clear",    value = settings.clear,    },
	["get"] =      { tag = "var", contents = "settings.get",      value = settings.get,      },
	["getNames"] = { tag = "var", contents = "settings.getNames", value = settings.getNames, },
	["load"] =     { tag = "var", contents = "settings.load",     value = settings.load,     },
	["save"] =     { tag = "var", contents = "settings.save",     value = settings.save,     },
	["set"] =      { tag = "var", contents = "settings.set",      value = settings.set,      },
	["unset"] =    { tag = "var", contents = "settings.unset",    value = settings.unset,    },
}
