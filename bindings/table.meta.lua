local table = table or {}
return {
	["concat"] =   { tag = "var", contents = "table.concat",   value = table.concat,   },
	["foreach"] =  { tag = "var", contents = "table.foreach",  value = table.foreach,  },
	["foreachi"] = { tag = "var", contents = "table.foreachi", value = table.foreachi, },
	["getn"] =     { tag = "var", contents = "table.getn",     value = table.getn,     },
	["insert"] =   { tag = "var", contents = "table.insert",   value = table.insert,   },
	["maxn"] =     { tag = "var", contents = "table.maxn",     value = table.maxn,     },
	["pack"] =     { tag = "var", contents = "table.pack",     value = table.pack,     },
	["remove"] =   { tag = "var", contents = "table.remove",   value = table.remove,   },
	["sort"] =     { tag = "var", contents = "table.sort",     value = table.sort,     },
	["unpack"] =   { tag = "var", contents = "table.unpack",   value = table.unpack,   },
}
