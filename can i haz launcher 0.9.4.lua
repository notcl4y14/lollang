os.execute("color A")
function clearscreen()
    input = io.read()
    if input == "y" then
        os.execute("cls")
        run()
    elseif input == "n" then
        run()
    else
        print("Well, I'm waiting for your fucking response. Are you just not gonna say anything dumbass?")
        clearscreen()
    end
end

function askfile()
    file = io.read()
    if file == "" then
        print("Input a real file and stop wasting my time")
        askfile()
		elseif file == "help" then
		print[[with a recent update, we added an error message when you request a non-existent file
		but if that didint work for you and you get the following error:

lua: .\utils/file.lua:3: attempt to index local 'file' (a nil value)
stack traceback:
        .\utils/file.lua:3: in function 'readfile'
        main.lua:11: in main chunk
        [C]: ?

		then stop inputing bullshit please.
		(this error is just for windows but yeah, dont worry)]]
		askfile()
    end
end

function run()
    os.execute("lua main.lua " .. file .. ".lel")
end

while true do
    print("Ayo, what .lel file ya wanna run? (type help for info)")
    askfile()
    print("Clear screen? (y/n)")
    clearscreen()
end
