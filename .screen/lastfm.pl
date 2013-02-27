#!/usr/bin/env perl
package main;
use utf8;
use common::sense;
use FindBin;
use Log::Minimal;
use Path::Class;
use Time::HiRes qw!alarm sleep!;

use lib "$FindBin::Bin/lib";
use Segment::LastFM;

my $fifo_dir = dir('/tmp');               # directory of FIFO
my $fifo_re = qr/^backtick-(\d+)\.fifo$/; # regex of FIFO filename
my $fifo_timeout = 0.1;                   # timeout for writing to FIFO
my $refresh_interval = 30;                # interval for accessing to Last.fm

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
    my $segment = Segment::LastFM->new;
    $segment->render;
    $segment->finish;
    return $segment->text->string;
} #}}}

# vim:se et:
