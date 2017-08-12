local redstone = redstone or {}
return {
	["getAnalogInput"] =    { tag = "var", contents = "redstone.getAnalogInput",    value = redstone.getAnalogInput,    },
	["getAnalogOutput"] =   { tag = "var", contents = "redstone.getAnalogOutput",   value = redstone.getAnalogOutput,   },
	["getAnalogueInput"] =  { tag = "var", contents = "redstone.getAnalogueInput",  value = redstone.getAnalogueInput,  },
	["getAnalogueOutput"] = { tag = "var", contents = "redstone.getAnalogueOutput", value = redstone.getAnalogueOutput, },
	["getBundledInput"] =   { tag = "var", contents = "redstone.getBundledInput",   value = redstone.getBundledInput,   },
	["getBundledOutput"] =  { tag = "var", contents = "redstone.getBundledOutput",  value = redstone.getBundledOutput,  },
	["getInput"] =          { tag = "var", contents = "redstone.getInput",          value = redstone.getInput,          },
	["getOutput"] =         { tag = "var", contents = "redstone.getOutput",         value = redstone.getOutput,         },
	["getSides"] =          { tag = "var", contents = "redstone.getSides",          value = redstone.getSides,          },
	["setAnalogOutput"] =   { tag = "var", contents = "redstone.setAnalogOutput",   value = redstone.setAnalogOutput,   },
	["setAnalogueOutput"] = { tag = "var", contents = "redstone.setAnalogueOutput", value = redstone.setAnalogueOutput, },
	["setBundledOutput"] =  { tag = "var", contents = "redstone.setBundledOutput",  value = redstone.setBundledOutput,  },
	["setOutput"] =         { tag = "var", contents = "redstone.setOutput",         value = redstone.setOutput,         },
	["testBundledInput"] =  { tag = "var", contents = "redstone.testBundledInput",  value = redstone.testBundledInput,  },
}
