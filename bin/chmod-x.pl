#!/usr/bin/env perl
use 5.12.0;
use common::sense;
use utf8;
use Path::Class;
use Regexp::Assemble;

my $home = "$ENV{HOME}/git/dotfiles";
my @exclude_file = qw!perlbrew_env cpu memory!;
my @exclude_ext = qw!pl py pyc pyo sh bat vbs!;
my @exclude_re = (
    qr!$home/bin!,
    qr!$home/\.vim/bundle!,
    qr!$home/\.git!,
);
my $ra = Regexp::Assemble->new;
$ra->add(qr!$_$!) for @exclude_file;
$ra->add(qr!\.$_$!) for @exclude_ext;
$ra->add($_) for @exclude_re;
dir("$ENV{HOME}/git/dotfiles")->recurse(callback => sub {
    my $file = shift;
    (!-f $file or $file->absolute =~ $ra->re) and return;
    my @mode = (split '', sprintf '%o', $file->stat->mode)[-3 .. -1];
    scalar grep { $_ & 1 } @mode or return;
    say $file;
    system "chmod -x $file";
});
