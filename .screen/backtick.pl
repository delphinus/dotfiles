#!/usr/bin/env perl
use common::sense;
use Path::Class;
use POSIX qw!mkfifo!;

my $fifo = file('/tmp/backtick.fifo');
$fifo->remove;
mkfifo($fifo, 0666);

while (1) {
    my $fh = $fifo->openr;
    while (my $line = <$fh>) {
        $line =~ s/\x0D?\x0A?$//;
        print $line, $/;
        (*STDOUT)->flush;
    }
    $fh->close;
}
