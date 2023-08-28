require("utils/file")
require("lang")

local filename = arg[1]

if not filename then
	print("can i haz a filenaem?")
	return
end

local code = readfile(filename)
-- lang_run("<stdin>", "x = 5;")
lang_run(filename, code)