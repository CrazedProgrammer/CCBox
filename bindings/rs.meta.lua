local rs = rs or {}
return {
	["getAnalogInput"] =    { tag = "var", contents = "rs.getAnalogInput",    value = rs.getAnalogInput,    },
	["getAnalogOutput"] =   { tag = "var", contents = "rs.getAnalogOutput",   value = rs.getAnalogOutput,   },
	["getAnalogueInput"] =  { tag = "var", contents = "rs.getAnalogueInput",  value = rs.getAnalogueInput,  },
	["getAnalogueOutput"] = { tag = "var", contents = "rs.getAnalogueOutput", value = rs.getAnalogueOutput, },
	["getBundledInput"] =   { tag = "var", contents = "rs.getBundledInput",   value = rs.getBundledInput,   },
	["getBundledOutput"] =  { tag = "var", contents = "rs.getBundledOutput",  value = rs.getBundledOutput,  },
	["getInput"] =          { tag = "var", contents = "rs.getInput",          value = rs.getInput,          },
	["getOutput"] =         { tag = "var", contents = "rs.getOutput",         value = rs.getOutput,         },
	["getSides"] =          { tag = "var", contents = "rs.getSides",          value = rs.getSides,          },
	["setAnalogOutput"] =   { tag = "var", contents = "rs.setAnalogOutput",   value = rs.setAnalogOutput,   },
	["setAnalogueOutput"] = { tag = "var", contents = "rs.setAnalogueOutput", value = rs.setAnalogueOutput, },
	["setBundledOutput"] =  { tag = "var", contents = "rs.setBundledOutput",  value = rs.setBundledOutput,  },
	["setOutput"] =         { tag = "var", contents = "rs.setOutput",         value = rs.setOutput,         },
	["testBundledInput"] =  { tag = "var", contents = "rs.testBundledInput",  value = rs.testBundledInput,  },
}
