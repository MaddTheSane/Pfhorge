-- This is only an example...  Pfhorge does not need to be open
-- for this to work, it will automaticaly open if not already open.
-- (but make sure it is on your hard drive)
-- This script will create a new map and put five polygons
-- in the center of it...

-- I have very limited support for AppleScript, I plan
-- to put more into latter...

-- Remember that index numbers for points, lines, etc. start at zero

-- For more info look in the dicionary of Pfhorge

-- Not everything works yet in apple scirpt for Pfhorge
-- But I hope to add more to it as time goes on...
-- Spent most of my time so far firguring out how to do apple scirpt
-- with cocoa apps...

tell application "Pfhorge"
	-- Creates a new map
	make new map at end of maps
	tell front map in maps
		repeat with i from 1 to 5
			-- I know there are better ways then using count all the time
			-- could use some math to just use it once at the begining
			-- and make the script run a little faster...
			
			-- Gets count of points
			set firstPointIndex to count of points
			
			-- makes a new point
			make new point at end of points with properties {x:100 * i, y:150 * i}
			
			-- makes a new line from the last point to new point
			lineToPoint at {x:50 * i, y:-900 * i}
			lineToPoint at {x:910 * i, y:-963 * i}
			
			set lastPointIndex to count of points
			
			lineToPoint at {x:950 * i, y:4 * i}
			--set x of point lastPointIndex to 2024 * i
			
			-- makes a line from two exsisting points
			lineFromPoint at firstPointIndex to lastPointIndex
			
			-- fills a polygon, all you have to do is supply 
			-- a line index number that is apart of the
			-- soon to be polygon. Right now it fills
			-- Every fourth line...
			fill withline ((i * 4) - 3)
			
			-- I will have pfhorge tell the index of the currenlt
			-- selected item in the future to help with debuging
			-- and also for MML, or anything else that needs
			-- index numbers...
		end repeat
		-- this tells the map to redraw, etc.
		refresh
	end tell
end tell
