#!/usr/bin/perl
use 5.30.0;
use warnings;
use feature 'signatures';
no warnings 'experimental::signatures';
use Capture::Tiny qw(capture);
use Data::Dumper qw(Dumper);
use Getopt::Long qw(:config posix_default no_ignore_case bundling auto_help);
use List::Util qw(reduce);
use JSON qw(decode_json);
use Pod::Usage qw(pod2usage);

GetOptions(
    \my %opt, qw(
    help|h
)) or pod2usage(1);
$opt{help} and pod2usage(0);
(my $album = shift) // die 'set album name';

my $label_id = 284328;
my $COMPILATION_FORMAT = 'CD, Comp, Mixed';

sub run_script($script) {
    my ($out, $err) = capture {
        system 'osascript', '-e', $script;
    };
    if ($err) {
        die "failed to run script: $err";
    }
    $out;
}

sub fetch($url) {
    my ($out) = capture {
        system 'curl', '-L', $url;
    };
    $out;
}

sub get_tracks($album_name) {
    my $out = run_script(<<SCRIPT);
        tell application "Music"
            set albumTracks to (get a reference to (every track of library playlist 1 whose album is "$album_name"))
            set trackList to ""
            repeat with aTrack in albumTracks
                set trackName to (get name of aTrack)
                set artistName to (get artist of aTrack)
                set trackNumber to (get track number of aTrack)
                set trackList to trackList & trackNumber & "\\t" & trackName & "\\t" & artistName & "\\n"
            end repeat
            return trackList
        end tell
SCRIPT
    [
        sort { $a->{no} <=> $b->{no} } map {
            my ($no, $title, $artist) = split /\t/;
            {
                no => $no,
                title => $title,
                artist => $artist,
            };
        } split /\n/, $out
    ];
}

sub fetch_discogs_label {
    my sub _fetch($url, $result = {}) {
        my $json = decode_json fetch($url);
        for my $cd (grep { $_->{format} eq $COMPILATION_FORMAT } $json->{releases}->@*) {
            $result->{$cd->{title}} = $cd->{id};
        }
        if (defined (my $next = $json->{pagination}{urls}{next})) {
            __SUB__->($next, $result);
        } else {
            $result;
        }
    }

    _fetch("https://api.discogs.com/labels/$label_id/releases?per_page=25");
}

sub fetch_discogs_tracks($id) {
    my $content = fetch("https://api.discogs.com/releases/$id");
    my $json = decode_json $content;
    [
        map {
            (my $artist = $_->{artists}[0]{name}) =~ s/\s+\(\d+\)$//;
            {
                artist => $artist,
                title => $_->{title},
            }
        } $json->{tracklist}->@*
    ];
}

my $releases = fetch_discogs_label;
my $id = $releases->{$album} // die "failed to find: $album";
my $track_data = fetch_discogs_tracks($id);
my $tracks = get_tracks($album);

for my $i (0 .. $tracks->$#*) {
    my $t = $tracks->[$i];
    my $d = $track_data->[$i];
    if ($t->{title} ne $d->{title} || $t->{artist} ne $d->{artist}) {
        printf '%2d: %s - %s%s', $i + 1, $t->{artist}, $t->{title}, "\n";
        printf '    %s - %s%s',  $d->{artist}, $d->{title}, "\n";
    }
}
