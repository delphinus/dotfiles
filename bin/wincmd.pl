#!/usr/bin/env perl
use strict;
use warnings;
use Encode;
use File::Basename;
binmode STDOUT => ':utf8';

open my $output, basename(__FILE__) . ".exe @ARGV 2>&1 |";
print decode(cp932 => $_) while $_ = <$output>;
