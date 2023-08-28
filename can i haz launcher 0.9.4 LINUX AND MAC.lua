-- Determine the clear command based on the operating system
local clear_command = os.getenv("HOME") and "clear" or "clear"

function clearscreen()
    io.read()  -- Clear the newline character from the previous input
    local input = io.read()

    if input == "y" then
        os.execute(clear_command)
        run()
    elseif input == "n" then
        run()
    else
        print("Well, I'm waiting for your fucking response. Are you just not gonna say anything dumbass?")
        clearscreen()
    end
end

function askfile()
    local file = io.read()

    if file == "" then
        print("Input a real file and stop wasting my time")
        askfile()
    elseif file == "help" then
        print([[
With a recent update, we added an error message when you request a non-existent file.
But if that didn't work for you and you get the following error:

lua: .\utils/file.lua:3: attempt to index local 'file' (a nil value)
stack traceback:
        .\utils/file.lua:3: in function 'readfile'
        main.lua:11: in main chunk
        [C]: ?

Then stop inputting bullshit, please.
(This error is just for Windows, so don't worry.)
]])
        askfile()
    end

    return file
end

function run(file)
    os.execute("lua main.lua " .. file .. ".lel")
end

while true do
    print("Ayo, what .lel file do you want to run? (type help for info)")
    local file = askfile()
    print("Clear screen? (y/n)")
    clearscreen()
end
