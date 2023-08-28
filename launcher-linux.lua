function clearscreen()
    input = io.read()
    if input == "y" then
        os.execute("clear")
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
		print[[this is a small project, dont expect much for now, this has only been tested on windows and lunbutu (a linux distro)!]]
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
