-- Automatically reads the file and returns its content, nil if the file doesn't exist
-- The function used to still read a file whether it exists or not is noticed by PeurPioche and remade by klei
function readfile(filename)
	-- Getting the file, nil if the given file doesn't exist
	local file = io.open(filename)
	
	-- Return nil if the given file doesn't exist
	if file == nil then
		return nil
	end
	
	-- Getting the text from the file
	local data = file:read("*all")
	-- Close the file
	file:close()
	
	-- Return the text from the file
	return data
end
