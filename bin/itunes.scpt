#!/usr/bin/env osascript
# Returns the current playing song in iTunes for OSX

tell application "System Events"
	set itunes_active to the count(every process whose name is "iTunes")
	if itunes_active is 0 then
		return
	end if
end tell

tell application "iTunes"
	set player_state to player state
	set track_name to name of current track
	set artist_name to artist of current track
	set album_name to album of current track
	set trim_length to 40
	set music_duration to the duration of the current track
	set music_elapsed to the player position
	return track_name & "{0}" & artist_name & "{0}" & album_name & "{0}" & music_elapsed & "{0}" & music_duration & "{0}" & player_state
end tell
