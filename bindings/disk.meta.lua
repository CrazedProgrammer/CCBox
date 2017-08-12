local disk = disk or {}
return {
	["eject"] =         { tag = "var", contents = "disk.eject",         value = disk.eject,         },
	["getAudioTitle"] = { tag = "var", contents = "disk.getAudioTitle", value = disk.getAudioTitle, },
	["getID"] =         { tag = "var", contents = "disk.getID",         value = disk.getID,         },
	["getLabel"] =      { tag = "var", contents = "disk.getLabel",      value = disk.getLabel,      },
	["getMountPath"] =  { tag = "var", contents = "disk.getMountPath",  value = disk.getMountPath,  },
	["hasAudio"] =      { tag = "var", contents = "disk.hasAudio",      value = disk.hasAudio,      },
	["hasData"] =       { tag = "var", contents = "disk.hasData",       value = disk.hasData,       },
	["isPresent"] =     { tag = "var", contents = "disk.isPresent",     value = disk.isPresent,     },
	["playAudio"] =     { tag = "var", contents = "disk.playAudio",     value = disk.playAudio,     },
	["setLabel"] =      { tag = "var", contents = "disk.setLabel",      value = disk.setLabel,      },
	["stopAudio"] =     { tag = "var", contents = "disk.stopAudio",     value = disk.stopAudio,     },
}
