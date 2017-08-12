local peripheral = peripheral or {}
return {
	["call"] =       { tag = "var", contents = "peripheral.call",       value = peripheral.call,       },
	["find"] =       { tag = "var", contents = "peripheral.find",       value = peripheral.find,       },
	["getMethods"] = { tag = "var", contents = "peripheral.getMethods", value = peripheral.getMethods, },
	["getNames"] =   { tag = "var", contents = "peripheral.getNames",   value = peripheral.getNames,   },
	["getType"] =    { tag = "var", contents = "peripheral.getType",    value = peripheral.getType,    },
	["isPresent"] =  { tag = "var", contents = "peripheral.isPresent",  value = peripheral.isPresent,  },
	["wrap"] =       { tag = "var", contents = "peripheral.wrap",       value = peripheral.wrap,       },
}
