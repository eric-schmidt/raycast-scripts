#!/usr/bin/osascript
# @raycast.schemaVersion 1
# @raycast.title Search Crest Spaces
# @raycast.mode silent
# @raycast.packageName Crest
# @raycast.icon 🧭
# @raycast.description Open Crest's command palette scoped to @spaces

-- Crest's scripting dictionary can't count windows (-1708), so ask System Events instead.
tell application "Crest" to activate
tell application "System Events"
	repeat 40 times
		if frontmost of process "Crest" then exit repeat
		delay 0.05
	end repeat
	if (count of windows of process "Crest") is 0 then
		keystroke "n" using command down -- New Window
		delay 0.3
	end if
	-- ⌘L toggles the palette, so only press it when the palette isn't already open.
	if not my paletteFocused() then keystroke "l" using command down
	-- Wait until the palette's field has focus; keys typed earlier are lost.
	set ready to false
	repeat 40 times
		if my paletteFocused() then
			set ready to true
			exit repeat
		end if
		delay 0.05
	end repeat
	-- Never type into the page if the palette didn't open.
	if not ready then return
	delay 0.1 -- let the palette finish animating in
	keystroke "@spaces " -- scope to Spaces (Space commits the filter)
end tell

on paletteFocused()
	tell application "System Events" to tell process "Crest"
		try
			set fe to value of attribute "AXFocusedUIElement"
			return (role of fe is "AXTextField") and (description of fe is "Command Palette")
		end try
	end tell
	return false
end paletteFocused
