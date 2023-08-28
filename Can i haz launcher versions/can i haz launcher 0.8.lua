function clearscreen()
    input = io.read()
    if input == "y" then
        os.execute("cls")
        run()
    elseif input == "n" then
        run()
    else
        print("Well, I'm waiting for your fucking response. Are you just not gonna say anything, dumbass?")
        clearscreen()
    end
end

function askfile()
    file = io.read()
    if file == "" then
        print("Input a real file and stop wasting my time")
        askfile()
    end
end

function run()
    os.execute("lua main.lua " .. file .. ".lel")
end

while true do
    print("Ayo, what .lel file ya wanna run?")
    askfile()
    print("Clear screen? (y/n)")
    clearscreen()
end
