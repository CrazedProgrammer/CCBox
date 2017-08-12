local http = http or {}
return {
	["checkURL"] = { tag = "var", contents = "http.checkURL", value = http.checkURL, },
	["get"] =      { tag = "var", contents = "http.get",      value = http.get,      },
	["post"] =     { tag = "var", contents = "http.post",     value = http.post,     },
	["request"] =  { tag = "var", contents = "http.request",  value = http.request,  },
}
