So, if you see this, ya prob wanna test the language.
So its pretty damn straightforward.


# -----------------[VERY IMPORTANT NOTE]------------------

This was made in lua for windows, so if you're a linux or mac user... well, idk how it works fo finding the directory and all but you still have to type
"lua main.lua [filename].lel" once you found it.


## [---------------------if you have Notepad++----------------------]

1-Right click main.lua and do "Edit with Notepad++"
2-Once in Notepad++, go to "File" and "Open containing folder" and choose "cmd".
3-Type "lua main.lua [filename].lel"

and voila, dont worry if the cmd turns green, its intended.


## [--------------------if you DONT have notepad++----------------]

1-Do win+r then type "cmd"
2-Do a series of the "cd" command ("cd [directory]") to the file where main.lua us located
EXAMPLE: cd downloads -> cd [whatheaver the heck this language's file will be called]
3-Type "lua main.lua [filename].lel"

Trust me, typing the directory everytime is a pain in the ass, so you better get smth that can do the same as Notepad++.

## [----------------------very USEFUL update-------------------]

so, i (PeurPioche) made a quick little launcher called "can i haz launcher" for it, so no more hassle of using cmd for the most part.
and i also made a linux ver for it! (pretty sure it works on MAC too)

# TODO
- ~~Fix the error calling lines that somehow got their `details` property have the same properties they have~~
- Add the comments
- Make the code kleiner :trollface:
- Set the `true` and `false` values to be non-string
	+ And the `null` and `undefined` values too
- ~~finish the "new" ver of that damn launcher~~
- add a file where we put the .lel files so everythings nice and clean (harder than it sounds.)
- Shell/REPL
- ~~Fix the error that the interpreter gets an unknown node~~
- ~~Fix the lang_evaluate_callExpr return an empty `arguments` table to the function~~ (just put `.value` to `value` lol)
- ~~Finish the array node or rewrite it~~
- Rewrite all the node functions to return a manually-made table instead of letting the `lang_Node` function do that
	+ Wrote that when did the same to runtime values

# CREDITS
Thanks to CodePulse and tylerlaceby for the tutorials!

CodePulse: https://www.youtube.com/@CodePulse, tylerlaceby: https://www.youtube.com/@tylerlaceby
