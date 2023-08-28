-- Automatically reads the file and returns its content, nil if the file doesn't exist
-- Noticed by PeurPioche, remade by klei
function readfile(filename)
	-- Getting the file, nil if there's no file with that name
	local file = io.open(filename)
	
	-- Returns nil if no file is found
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
