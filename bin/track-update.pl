#!/usr/bin/perl

=head1 DESCRIPTION

    Music track updater

=head1 SYNOPSIS

    track-update.pl (Album Name)
    # dry-run for the album

    track-update.pl -e (Album Name)
    # execute

    track-update.pl -u (Album Name)
    # update cache

    track-update.pl -v (Album Name)
    # print verbosely

    track-update.pl -h
    # show this messages

=cut

use 5.30.0;
use warnings;
use utf8;
use feature 'signatures';
no warnings 'experimental::signatures';
use constant COMPILATION_FORMATS => [
    'CD, Comp, Mixed',
    'CD, Comp, Mixed, RE',
    'CD, Comp, Copy Prot., Mixed',
];
use constant ERROR_ALBUM => {
    'HAPPY SPEED The BEST of Dancemania SPEED G' => { track => 7 },
};
use constant LABEL_ID => 284328;
use constant MAPPING => {
    'Dancemania SPEED G' => 'Dancemania Speed Super Best: Speed G',
    'Dancemania SPEED G2' => 'Dancemania Speed Evolution: Speed G2',
    'Dancemania SPEED G3' => 'Dancemania Speed Evolution Speed G3',
    'Dancemania SPEED G4' => 'Dancemania Speed Evolution Speed G4',
    'Dancemania SPEED G5' => 'Dancemania Speed Evolution Speed G5',
    'Dancemania SPEED SFX' => 'Speed SFX = スピード SFX ',
    'HAPPY SPEED The BEST of Dancemania SPEED G' => 'Happy Speed (The Best Of Dancemania Speed G)',
    'BEST OF HARDCORE' => 'Dancemania Speed Presents Best Of Hardcore',
    'HAPPY RAVERS' => ' Dancemania Speed Presents Happy Ravers',
    'TRANCE RAVERS' => ' Dancemania Speed Presents Trance Ravers',
};
use Capture::Tiny qw(capture);
use Encode qw(decode);
use Getopt::Long qw(:config posix_default no_ignore_case bundling auto_help);
use List::Util qw(any);
use JSON qw(decode_json);
use Path::Tiny qw(path);
use Pod::Usage qw(pod2usage);
use URI::Escape qw(uri_escape);
binmode STDOUT => ':utf8';

GetOptions(
    \my %opt, qw(
    execute|e
    update_cache|u
    verbose|v
    help|h
)) or pod2usage(1);
$opt{help} and pod2usage(0);
(my $album = shift) // pod2usage({ -message => 'set album name' });
my $script_name = path($0)->basename(qr/\..+$/);

sub logger($fmt, @params) {
    if ($opt{verbose}) {
        printf "[%s] $fmt%s", $script_name, @params, "\n";
    }
}

sub run_script($script) {
    logger('running script');
    my ($out, $err) = capture {
        system 'osascript', '-e', $script;
    };
    if ($err) {
        die "failed to run script: $err";
    }
    $out;
}

sub fetch($url) {
    my $cache_dir = path($ENV{HOME}, '.cache')->child($script_name);
    $cache_dir->mkpath;
    my $cache = $cache_dir->child(uri_escape($url));
    if (!$opt{update_cache}) {
        if ($cache->exists) {
            logger('use cache for %s', $url);
            return $cache->slurp_utf8;
        }
    }
    my ($out) = capture {
        system 'curl', '-L', $url;
    };
    $cache->spew_utf8($out);
    logger('cache saved to %s', $cache);
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
        sort { $a->{track} <=> $b->{track} } map {
            my ($track, $title, $artist) = split /\t/;
            {
                track => $track + 0,
                title => $title,
                artist => $artist,
            };
        } split /\n/, $out
    ];
}

sub fetch_discogs_label {
    my sub _fetch($url, $result = {}) {
        my $json = JSON->new->utf8->decode(fetch($url));
        my @matched = grep {
            my $cd = $_;
            any { $cd->{format} eq $_ } COMPILATION_FORMATS->@*;
        } $json->{releases}->@*;
        for my $cd (@matched) {
            $result->{$cd->{title}} = $cd->{id};
        }
        if (defined (my $next = $json->{pagination}{urls}{next})) {
            logger('fetch next url: %s', $next);
            __SUB__->($next, $result);
        } else {
            $result;
        }
    }

    _fetch("https://api.discogs.com/labels/@{[LABEL_ID]}/releases?per_page=25");
}

sub fetch_discogs_tracks($id) {
    my $content = fetch("https://api.discogs.com/releases/$id");
    my $json = JSON->new->utf8(0)->decode($content);
    [
        map {
            (my $artist = $_->{artists}[0]{name}) =~ s/\s+\(\d+\)$//;
            if ($_->{title} =~ /\p{Katakana}/) {
                $_->{title} =~ s/ = .*$//;
            }
            {
                artist => $artist,
                title => $_->{title},
            }
        } $json->{tracklist}->@*
    ];
}

sub update_atrist_title($album_name, $track, $artist, $title) {
    logger('updating: %s, %2d, %s, %s', $album_name, $track, $artist, $title);
    $album_name =~ s/"/\\"/g;
    $artist =~ s/"/\\"/g;
    $title =~ s/"/\\"/g;
    run_script(<<SCRIPT);
        tell application "Music"
            set theTracks to (get a reference to (every track of library playlist 1 whose album is "$album_name" and track number is $track))
            repeat with aTrack in theTracks
                set artist of aTrack to "$artist"
                set name of aTrack to "$title"
            end repeat
        end tell
SCRIPT
}

sub get_id($releases, $album) {
    if (defined $releases->{$album}) {
        $releases->{$album};
    } else {
        my $transformed = MAPPING->{$album} // '';
        (my $transformed2 = $album) =~ s/SPEED/Speed/;
        logger('1: %s', $transformed);
        logger('2: %s', $transformed2);
        $releases->{$transformed} // $releases->{$transformed2} // die "failed to find: $album";
    }
}

my $releases = fetch_discogs_label;
my $id = get_id($releases, $album);
my $track_data = fetch_discogs_tracks($id);
my $original = get_tracks($album);

for my $info ($original->@*) {
    my $d = $track_data->[$info->{track} - 1];
    if (my $err = ERROR_ALBUM->{$album}) {
        logger('Skip track %d because the album has an error: %s', $err->{track}, $album);
        next if $err->{track} == $info->{track};
    }
    if ($info->{title} ne $d->{title} || $info->{artist} ne $d->{artist}) {
        printf '%2d: %s - %s%s', $info->{track}, $info->{artist}, $info->{title}, "\n";
        printf '    %s - %s%s',  $d->{artist}, $d->{title}, "\n";
        if ($opt{execute}) {
            update_atrist_title($album, $info->{track}, $d->{artist}, $d->{title});
        }
    }
}
