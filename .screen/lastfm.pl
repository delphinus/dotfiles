#!/usr/bin/env perl
use utf8;
use common::sense;
use HTTP::Date qw!time2iso!;
use JSON;
use Log::Minimal;
use LWP::UserAgent;
use Path::Class;
use Time::HiRes qw!alarm sleep!;
use URI;

my $fifo_dir = dir('/tmp');               # directory of FIFO
my $fifo_re = qr/^backtick-(\d+)\.fifo$/; # regex of FIFO filename
my $fifo_timeout = 0.1;                   # timeout for writing to FIFO
my $refresh_interval = 30;                # interval for accessing to Last.fm

# Last.fm setting
my %param = (
    method     => 'user.getrecenttracks',
    format     => 'json',
    user       => 'delphinus_iddqd',
    api_key    => 'fca0142adfe95a7fb622a63d28b7d1a5',
    nowplaying => 'true',
    limit      => 1,
);

# setup URL
my $url = 'http://ws.audioscrobbler.com/2.0/';
(my $u = URI->new($url))->query_form(%param);
my $ua = LWP::UserAgent->new;

# log setting
#{{{
my $log_file = file('/usr/local/var/logs/backtick-lastfm.log');
local $Log::Minimal::PRINT = sub {
    my ($time, $type, $message, $trace, $raw_message) = @_;
    $ENV{TEST_MODE} or return;
    my $msg = sprintf "%s [%s] %s%s\n",
        $time, $type, $message, ($type eq 'INFO' ? '' : " at $trace");
    my $fh = $log_file->open('a') or die $!;
    binmode $fh => ':utf8';
    $fh->print($msg);
    $fh->close;
};
#}}}

# start main routine
while (1) { #{{{
    (my $msg = get_message()) or next;

    my @fifos = grep { -p and $_->basename =~ $fifo_re } $fifo_dir->children;

    for my $fifo (@fifos) {
        infof("write to $fifo : $msg");
        (my $fh = $fifo->open('a')) or die "can't open $fifo";
        binmode $fh => ':utf8';
        eval {
            local $SIG{ALRM} = sub { die 'timeout'; };
            alarm $fifo_timeout;
            $fh->print($msg);
            $fh->close;
            alarm 0;
        };
    }

} continue {
    sleep $refresh_interval;
} #}}}

# get track info from Last.fm
sub get_message { #{{{
    my $res = $ua->get($u);

    if ($res->is_error) {
        infof("can't access to Last.fm : " . $res->error_as_HTML);
        return;
    }

    my $data = eval { from_json($res->content); };
    if ($@) {
        infof("can't decode json : " . $res->content);
        return;
    }

    my $track_info = $data->{recenttracks}{track};
    my $track_info_type = ref $track_info;
    my $status = '';
    my $track;

    # unknown response
    if (!defined $track_info_type || $track_info_type !~ /^(?:ARRAY|HASH)$/) {
        infof("invalid reponse : $data");
        return;

    # now playing
    } elsif (ref $track_info eq 'ARRAY') {
        $track = $track_info->[0];
        $status = 'now_playing';

    # played
    } elsif (ref $track_info eq 'HASH') {
        $track = $track_info;
        $status = 'played';
    }

    my $song = "$track->{artist}{'#text'} - $track->{name}";
    my $timestamp = time2iso($track->{date}{uts});

    my $colored_song = set_color($song, 'kb', 1);
    my $colored_timestamp = set_color($timestamp, 'km');
    my $colored_status =
        $status eq 'now_playing' ? set_color('Now Playing', 'r kb') : '';

    return "$colored_timestamp$colored_song$colored_status\n";
} #}}}

# set color using escape sequences of GNU Screen
sub set_color { #{{{
    my ($string, $color_code, $dont_reset) = @_;
    defined $string or defined $color_code or return '';
    my $reset_color = $dont_reset ? '' : "\cE{-}";

    return "\cE{$color_code} $string $reset_color";
} #}}}
