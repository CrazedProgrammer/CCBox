local rednet = rednet or {}
return {
	["CHANNEL_BROADCAST"] = { tag = "var", contents = "rednet.CHANNEL_BROADCAST", value = rednet.CHANNEL_BROADCAST, },
	["CHANNEL_REPEAT"] =    { tag = "var", contents = "rednet.CHANNEL_REPEAT",    value = rednet.CHANNEL_REPEAT,    },
	["broadcast"] =         { tag = "var", contents = "rednet.broadcast",         value = rednet.broadcast,         },
	["close"] =             { tag = "var", contents = "rednet.close",             value = rednet.close,             },
	["host"] =              { tag = "var", contents = "rednet.host",              value = rednet.host,              },
	["isOpen"] =            { tag = "var", contents = "rednet.isOpen",            value = rednet.isOpen,            },
	["lookup"] =            { tag = "var", contents = "rednet.lookup",            value = rednet.lookup,            },
	["open"] =              { tag = "var", contents = "rednet.open",              value = rednet.open,              },
	["receive"] =           { tag = "var", contents = "rednet.receive",           value = rednet.receive,           },
	["run"] =               { tag = "var", contents = "rednet.run",               value = rednet.run,               },
	["send"] =              { tag = "var", contents = "rednet.send",              value = rednet.send,              },
	["unhost"] =            { tag = "var", contents = "rednet.unhost",            value = rednet.unhost,            },
}
