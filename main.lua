require("utils/file")
require("lang")

-- Getting the filename from the 1st argument
local filename = arg[1]

-- If the given filename is nil then output "can i haz a filenaem?" :P
if not filename then
	print("can i haz a filenaem?")
	return
end

-- Getting the code from the file
local code = readfile(filename)

-- If the code is nil then output "File <filename> doesn't exist!"
if not code then
	print("File " .. filename .. " doesn't exist!")
	return
end

-- Run the code
-- lang_run("<stdin>", "x = 5;")
lang_run(filename, code)