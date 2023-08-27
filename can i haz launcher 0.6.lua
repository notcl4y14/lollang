--i have no fucking idea where to start
os.execute("color A")
function run()
	os.execute("lua main.lua "..file..".wick")
end
print("ayo, what .wick file ya wanna run?")
file = io.read()
print("clear screen? (y/n)")
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
	print("well since the dev for this launcher was too lasy to make a function to repeat this, you'll have to restart the launcher, congrats")
	io.read()
end
io.read()
