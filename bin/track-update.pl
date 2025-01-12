#!/usr/bin/perl
use 5.30.0;
use warnings;

my $album = shift;
my $script = <<SCRIPT;
tell application "Music"
    set albumTracks to "" set theAlbum to (first item of (every album whose name is "$album"))
    set albumArtist to artist of theAlbum
    repeat with t in (tracks of theAlbum)
        set trackName to name of t
        set trackArtist to artist of t
        set albumTracks to albumTracks & trackName & " - " & trackArtist
    end repeat
    return {{"artist": albumArtist, "tracks": albumTracks}}
end tell
SCRIPT
my $out = `osascript -e $script`;
say $out;
