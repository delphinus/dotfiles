#!/usr/bin/env perl
use strict;
use warnings;
use MIME::Base64;
use Encode;
use constant TMUXLEN => 250;
use constant SCREENLEN => 510;

my $input = do {
    local $/;
    <STDIN>;
};
$input =~ s/ \n+ \z//xsm;
$input =~ s/\n/\r\n/g;
$input = encode_base64( $input, q{} );

if( $ENV{TMUX}) {
    print "\ePtmux;\e\e]52;;\e\\";
    # 分割して送信
    for(my $i = 0, my $len = length($input); TMUXLEN * $i < $len; $i++) {
        my $str = substr($input, TMUXLEN * $i, TMUXLEN);
        print "\ePtmux;$str\e\\";
    }
    print "\ePtmux;\e\e\\\\\e\\";
} elsif( $ENV{TERM} eq 'screen' ) {
    print "\eP\e]52;;\e\\";
    for(my $i = 0, my $len = length($input); SCREENLEN * $i < $len; $i++) {
        my $str = substr($input, SCREENLEN * $i, SCREENLEN);
        print "\eP$str\e\\";
    }
    print "\eP\x07\e\\";
} else {
    print "\e]52;;$input\e\\";
}

# vim:se et:
