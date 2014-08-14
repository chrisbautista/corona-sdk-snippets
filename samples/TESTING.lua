--- Staging area.

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Corona modules --
local composer = require("composer")

-- --
local Scene = composer.newScene()

--
function Scene:create ()
	--
end

Scene:addEventListener("create")

--
function Scene:show (e)
	if e.phase == "will" then return end

local mf=require("graph_ops.flow")
-- A = { b = 3, d = 3 } -> 1 = 2, 4
-- B = { c = 4 } -> 2 = 3
-- C = { a = 3, d = 1, e = 2 } -> 3 = 1, 4, 5
-- D = { e = 2, f = 6 } -> 4 = 5, 6
-- E = { b = 1, g = 1 } -> 5 = 2, 7
-- F = { g = 9 } -> 6 = 7
-- G = "SINK"
-- Source = a, sink = g
do
	-- s = 1, x = 2, y = 3, t = 4
--[[
	local a, b, c = mf.MaxFlow({
		1, 2, 1,
		1, 3, 3,
		2, 3, 1,
		3, 2, 1,
		2, 4, 3,
		3, 4, 1
	}, 1, 4, { compute_mincut = true })]]
	-- a .. j = 1 .. 10
	local a, b, c = mf.MaxFlow({
		1, 2, 1,
		1, 3, 1,
		1, 4, 1,
		2, 5, 1,
		3, 5, 1,
		4, 5, 1,
		5, 6, 1,
		6, 7, 1,
		6, 8, 1,
		6, 9, 1,
		7, 10, 1,
		8, 10, 1,
		9, 10, 1
	}, 1, 10, { compute_mincut = true })
	print("Max flow = " .. tostring(a))
	vdump(b)
	vdump(c)
end

end

Scene:addEventListener("show")

--[[
	Near / not-too-far future TODO list:

	- Finish off seams sample, including dealing with device-side problems (PARTIAL)
	- Do the colored corners sample

	- Proceed with editor, finally implement some things like the background view
	- Refine link system, make more linkables (FSM's? All those things I was making before...)
	- Editor-wise, generally just make everything prettier, cleaner
	- Improve custom widgets (Bitmap, Grid1D, Grid2D, Keyboard, Link, LinkGroup, etc.)
	- Make some dialogs to stress-test the section feature
	- Decouple dialogs from the editor
	- Decouple links / tags from editor? Instancing?
	- Some sort of stuff for recurring UI tasks: save / load dialogs, listbox, etc. especially ones that recur outside the editor (PARTIAL)
	- Kill off redundant widgets (button, checkbox)

	- Play with input devices

	- Fix formatting, which is rather off on tablets and probably more high-definition phones
	- To that end, do a REAL objects helper module, that digs in and deals with anchors and such

	- The Great Migration! (i.e. move much of snippets into CrownJewels and Tektite submodules) (PARTIAL)
	- Might even be worth making the submodules even more granular
	- Kick off a couple extra programs to stress-test submodule approach

	- Deprecate DispatchList? (perhaps add some helpers to main)

	- Make the resource system independent of Corona, then start using it more pervasively

	- Figure out if quaternions ARE working, if so promote them
	- Figure out what's wrong with some of the code in collisions module (probably only practical from game side)

	- Embedded free list / ID-occupied array ops modules
	- Finally finish mesh ops / Delaunay
	- Finish up the dart-throwing stuff
	- Finish up the union-find-delete, some of those other data structures
	- Do a CMV or Poisson MVC sample?
	- Start something with geometric algebra, a la Lengyel
]]

return Scene