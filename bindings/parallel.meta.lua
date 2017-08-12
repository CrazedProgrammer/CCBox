local parallel = parallel or {}
return {
	["waitForAll"] = { tag = "var", contents = "parallel.waitForAll", value = parallel.waitForAll, },
	["waitForAny"] = { tag = "var", contents = "parallel.waitForAny", value = parallel.waitForAny, },
}
