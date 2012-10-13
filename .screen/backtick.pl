#!/usr/bin/env perl
use utf8;
use common::sense;
use Path::Class;
use POSIX qw!mkfifo!;

binmode STDOUT => ':utf8';

my $fifo = file('/tmp/backtick.fifo');
unless (-p $fifo) {
    $fifo->remove;
    mkfifo($fifo, 0666);
}

while (1) {
    my $fh = $fifo->openr;
    binmode $fh => ':utf8';
    while (my $line = <$fh>) {
        $line =~ s/\x0D?\x0A?$//;
        print $line, $/;
        (*STDOUT)->flush;
    }
    $fh->close;
}
