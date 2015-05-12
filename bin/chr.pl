#!/usr/bin/env perl
binmode STDOUT => ':encoding(utf8)';
for my $code (0xe000 .. 0xe7ff) {
  printf '%04x ', $code unless $code % 16;
  print chr($code) . '  ';
  print ";\n" if $code % 16 == 15;
}
