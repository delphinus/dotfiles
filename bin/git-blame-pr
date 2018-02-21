#! /usr/bin/perl

use strict;
use warnings;

my $git_blame_pid = open(my $fh, "-|", "git", "blame", "--first-parent", @ARGV)
    or die "failed to invoke git-blame:$!";

my %cached; # commit-id -> substitution string

while (my $line = <$fh>) {
    my ($commit, $src) = split / .*?\) /, $line, 2;
    $cached{$commit} = lookup($commit)
        unless $cached{$commit};
    print $cached{$commit}, ' ', $src;
}

while (waitpid($git_blame_pid, 0) != $git_blame_pid) {}
exit $?;

sub lookup {
    my $commit = shift;
    my $message = `git show --oneline $commit`;
    if ($message =~ /Merge\s+(?:pull\s+request|pr)\s+\#?(\d+)\s/i) {
        return sprintf '%-9s', "PR #$1";
    }
    return $commit;
}
