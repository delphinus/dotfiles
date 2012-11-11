#!/usr/bin/env perl
use utf8;
use common::sense;
use Path::Class;
use Time::HiRes qw!sleep alarm!;

my $fifo_dir = dir('/tmp');               # directory of FIFO
my $fifo_re = qr/^backtick-(\d+)\.fifo$/; # regex of FIFO filename
my $fifo_timeout = 0.1;                   # timeout for writing to FIFO
my $refresh_interval = 0.05;
my %kao = (1 => 'o～((((～´∀`)～ﾌﾗﾌﾗ～', -1 => '～ﾌﾗﾌﾗ～(´∀`～))))～o');
my $width = 15;
my @colors = split '', 'krgybmcw';
my $count = 0;
my $inc = 1;

# make message
sub get_message { #{{{
    $count += $inc;
    ($count > $width || $count < 0) and $inc *= -1;
    return set_color(' ' x $count, 'kw') # white on black
        . set_color($kao{$inc}, 'k' . $colors[rand @colors], 1);
            # random color on black and do not reset color
} #}}}

# set color using escape sequences of GNU Screen
sub set_color { #{{{
    my ($string, $color_code, $dont_reset) = @_;
    my $reset_color = $dont_reset ? '' : "\cE{-}";
    return "\cE{$color_code}$string$reset_color";
} #}}}

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
        };
    }

} continue {
    sleep $refresh_interval;
} #}}}
