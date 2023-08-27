--mmm, spagheti
function clearscreen()
input = io.read()
if input == "y" then
	os.execute("cls")
	run()
	io.read()
	elseif input == "n" then
	run()
	io.read()
	else
	print("well i'm waiting for your fucking response, are you just not gonna say anything dumbass?")
	clearscreen()
end
function askfile()
file = io.read()
if file == "" then
	print("input a real file and stop wasting my time")
	askfile()
	end
end
function run()
	os.execute("lua main.lua "..file..".wick")
end
print("ayo, what wick file ya wanna run?")
askfile()
print("clear screen? (y/n)")
clearscreen()
io.read()
