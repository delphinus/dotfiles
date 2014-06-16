#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw!:config posix_default no_ignore_case gnu_compat!;

my ($input_file, $output_file, $color_number, $color, $help) = @_;
GetOptions(
    'input-file|i=s'  => \$input_file,
    'output-file|o=s' => \$output_file,
    'number|n=i'      => \$color_number,
    'color|c=o'       => \$color,
    #'help|h'          => \$help,
);

main() if $0 eq __FILE__;

sub main {
    if (defined $input_file && 0 < length $input_file) {
        set_color_palette($input_file);
        print "set whole color palette success\n";
    } elsif (defined $output_file && 0 < length $output_file) {
        get_color_palette($output_file);
        print "save whole color palette to file: $output_file\n";
    } elsif (defined $color_number && 0 <= $color_number && 15 >= $color_number) {
        if (defined $color) {
            set_color($color_number, $color);
        } else {
            get_color($color_number);
        }
    } else {
        #get_color_palette();
    }
}

sub set_color_palette {
    my $input_file = shift;

    open my $fh, '<', $input_file or die "can't open file: $input_file";
    my @colors;
    while (defined(my $line = $fh->getline)) {
        push @colors, parse_color($line);
    }

    for my $color_number (0 .. 15) {
        set_color($color_number, $colors[$color_number])
            if defined $colors[$color_number];
    }
}

sub get_color {
    my $color_number = shift;

    my $cmd = sprintf "\e]4;%d;?\e\\", $color_number;
    my $color = `$cmd`;
    my ($b, $g, $r) = $color =~ m!(..)../(..)../(..)!;

    return "$r$g$b";
}

sub set_color {
    my ($color_number, $color) = @_;

    printf "\e]4;%d;#%s\e\\", $color_number, $color;
}

sub parse_color {
    my $text = shift;
    my ($color) = /^\s*(\S*)\s*$/;

    my ($r, $g, $b);
    if ($color =~ /,/) {
        ($r, $g, $b) = map { defined $_ ? sprintf('%02x', $_) : '00' }
            split ',', $color;
    } else {
        $color = '000000' unless 6 == length $color;
        ($r, $g, $b) = $color =~ /(..)(..)(..)/;
    }

    return "$b$g$r";
}

__DATA__
---
- solarized:
    - 0x073642
    - 0xdc322f
    - 0x859900
    - 0xb58900
    - 0x268bd2
    - 0xd33682
    - 0x2aa198
    - 0xeee8d5
    - 0x002b36
    - 0xcb4b16
    - 0x586e75
    - 0x657b83
    - 0x839496
    - 0x6c71c4
    - 0x93a1a1
    - 0xfdf6e3
