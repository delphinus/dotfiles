#!/usr/bin/env perl
package ColoredString;
use utf8;
use common::sense;

sub new { my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{@_};
    my $str = '';
    my $fg = $args->{fg} || 'k';
    my $bg = $args->{bg} || 'g';
    defined $args->{string}
        and $str = sprintf "\cE{%s%s}%s", @$args{qw!bg fg string!};
    return bless +{%$args,
        current_fg => $fg,
        current_bg => $bg,
        hard_left_arrow => "\x{2b80}", # ⮀
        soft_left_arrow => "\x{2b81}", # ⮁
        hard_right_arrow => "\x{2b82}", # ⮂
        soft_right_arrow => "\x{2b83}", # ⮃
        string => $str,
    } => $class;
}

sub add { my $self = shift;
    my %p = @_;
    my ($attr_before, $attr_after) = ('', '');
    if ($p{bold}) {
        $attr_before = "\cE{+b}";
        $attr_after = "\cE{-}";
    }
    if ($p{bg} eq $self->{current_bg}) {
        $self->{string} .= sprintf " \cE{%s%s}%s %s%s%s",
            $p{bg}, $p{fg}, $self->{soft_left_arrow},
            $attr_before, $p{string}, $attr_after;
    } else {
        $self->{string} .= sprintf " \cE{%s%s}%s\cE{%s%s} %s%s%s",
            $p{bg}, $self->{current_bg}, $self->{hard_left_arrow},
            $p{bg}, $p{fg}, $attr_before, $p{string}, $attr_after;
        $self->{current_bg} = $p{bg};
        $self->{current_fg} = $p{fg};
    }
}

sub draw { my $self = shift;
    return $self->{string};
}

1;

package main;
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
my $log_file = file('/usr/local/var/logs/backtick-lastfm.log');

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
        eval {
            local $SIG{ALRM} = sub { die 'timeout'; };
            alarm $fifo_timeout;
            (my $fh = $fifo->open('a')) or die "can't open $fifo";
            binmode $fh => ':utf8';
            $fh->print($msg);
            $fh->close;
            alarm 0;
            infof("write to $fifo : $msg");
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

    my $str = ColoredString->new(fg => 'k', bg => 'g', string => '');
    $str->add(fg => 'K', bg => 'C', string => $timestamp);
    $str->add(fg => 'k', bg => 'w', string => $track->{artist}{'#text'});
    $str->add(fg => 'R', bg => 'w', string => $track->{name}, bold => 1);
    $str->add(fg => 'W', bg => 'R', string => 'Now Playing')
        if $status eq 'now_playing';
    $str->add(fg => 'k', bg => 'g', string => ' ');

    return $str->draw;
} #}}}

# vim:se et:
