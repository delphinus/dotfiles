#!/usr/bin/env perl
use utf8;
use common::sense;
use LWP::UserAgent;
use HTTP::Date qw!time2iso!;
use JSON;
use Path::Class;
use URI;
use YAML;

my $refresh_interval = 30;
my $fifo = file('/tmp/backtick.fifo');
-p $fifo or die "can't find FIFO! : $fifo";

my %param = (
    method => 'user.getrecenttracks',
    format => 'json',
    user => 'delphinus_iddqd',
    api_key => 'fca0142adfe95a7fb622a63d28b7d1a5',
    limit => 1,
    nowplaying => 'true',
);

my $url = 'http://ws.audioscrobbler.com/2.0/';
(my $u = URI->new($url))->query_form(%param);

my $ua = LWP::UserAgent->new;

my $last_song;
while (1) {
    my $res = $ua->get($u);

    unless ($res->is_error) {
        my $data = from_json($res->content);
        my $track_info = $data->{recenttracks}{track};
        my $status = '';
        my $track;
        # now playing
        if (ref $track_info eq 'ARRAY') {
            $track = $track_info->[0];
            $status = 'now_playing';

        # played
        } elsif (ref $track_info eq 'HASH') {
            $track = $track_info;
            $status = 'played';

        # unknown
        } else {
            print Dump $data;
            die;
        }

        my $song = "$track->{artist}{'#text'} - $track->{name}";
        my $timestamp = time2iso($track->{date}{uts});
        $song eq $last_song and next;

        my $colored_song = color($song, 'kb', 1);
        my $colored_timestamp = color($timestamp, 'km');
        my $colored_status =
            $status eq 'now_playing' ? color('Now Playing', 'r kb') : '';

        my $msg = "$colored_timestamp$colored_song$colored_status$/";
        (my $fh = $fifo->open('a')) or die "can't open $fifo";
        binmode $fh => ':utf8';
        $fh->print($msg);
        $fh->close;
    }

    sleep $refresh_interval;
}

sub color {
    my ($string, $color_code, $dont_reset) = @_;
    $string or $color_code or return '';
    my $reset_color = $dont_reset ? '' : "\cE{-}";
    return "\cE{$color_code} $string $reset_color";
}
