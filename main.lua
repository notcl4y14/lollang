require("utils/file")
require("lang")

-- Getting the arguments
local filename = ""
local showLexer = false
local showParser = false

-- Iterating through each argument
for i=1, #arg do
	-- Getting the current argument and storing it into the "argument" variable
	local argument = arg[i]

	-- If the first 2 symbols in the argument are "--" then it's and option
	if string.sub(argument, 1, 2) == "--" then
		-- --show-lexer
		if argument == "--show-lexer" then
			showLexer = true

		-- --show-parser
		elseif argument == "--show-parser" then
			showParser = true

		elseif argument == "--v" or argument == "--V" or argument == "--version" then
			print("The language is still in development!")
			return
		end

	-- Otherwise, it should be a filename
	else
		-- Getting the filename from the argument
		filename = argument
	end
end

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
lang_run(filename, code, showLexer, showParser)