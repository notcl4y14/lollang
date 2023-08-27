function readfile(filename)
	local file = io.open(filename)
	local data = file:read("*all")
	file:close()

	return data
end