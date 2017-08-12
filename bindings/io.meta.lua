local io = io or {}
return {
	["close"] =  { tag = "var", contents = "io.close",  value = io.close,  },
	["flush"] =  { tag = "var", contents = "io.flush",  value = io.flush,  },
	["input"] =  { tag = "var", contents = "io.input",  value = io.input,  },
	["lines"] =  { tag = "var", contents = "io.lines",  value = io.lines,  },
	["open"] =   { tag = "var", contents = "io.open",   value = io.open,   },
	["output"] = { tag = "var", contents = "io.output", value = io.output, },
	["read"] =   { tag = "var", contents = "io.read",   value = io.read,   },
	["type"] =   { tag = "var", contents = "io.type",   value = io.type,   },
	["write"] =  { tag = "var", contents = "io.write",  value = io.write,  },
}
