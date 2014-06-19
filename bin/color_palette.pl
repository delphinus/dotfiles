#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long qw!:config posix_default no_ignore_case gnu_compat!;

my ($palette_name, $input_file, $color_number, $color, $help) = @_;
GetOptions(
    'palette|p=s'   => \$palette_name,
    'inputfile|i=s' => \$input_file,
    'number|n=i'    => \$color_number,
    'color|c=s'     => \$color,
    'help|h'        => \$help,
);

my %conf = (
    palette => +{
        default => [qw!
            0 1 2 3 4 5 6 7
            8 9 10 11 12 13 14 15
        !],
        solarized => [qw!
            073642 dc322f 859900 b58900 268bd2 d33682 2aa198 eee8d5
            002b36 cb4b16 586e75 657b83 839496 6c71c4 93a1a1 fdf6e3
        !],
        gruvbox => [qw!
            fdf4c1 cc241d 98971a d79921 458588 b16286 689d6a 665c54
            a89984 9d0006 79740e b57614 076678 8f3f71 427b58 3c3836
        !],
    },
    xterm_color => [map { split /\s+/ }
        # Primary 3-bit (8 colors). Unique representation!
        # number: 0 - 7
        '000000 800000 008000 808000 000080 800080 008080 c0c0c0',

        # Equivalent "bright" versions of original 8 colors.
        # number: 8 - 15
        '808080 ff0000 00ff00 ffff00 0000ff ff00ff 00ffff ffffff',

        # Strictly ascending.
        # number: 16 - 79
        '000000 00005f 000087 0000af 0000d7 0000ff 005f00 005f5f',
        '005f87 005faf 005fd7 005fff 008700 00875f 008787 0087af',
        '0087d7 0087ff 00af00 00af5f 00af87 00afaf 00afd7 00afff',
        '00d700 00d75f 00d787 00d7af 00d7d7 00d7ff 00ff00 00ff5f',
        '00ff87 00ffaf 00ffd7 00ffff 5f0000 5f005f 5f0087 5f00af',
        '5f00d7 5f00ff 5f5f00 5f5f5f 5f5f87 5f5faf 5f5fd7 5f5fff',
        '5f8700 5f875f 5f8787 5f87af 5f87d7 5f87ff 5faf00 5faf5f',
        '5faf87 5fafaf 5fafd7 5fafff 5fd700 5fd75f 5fd787 5fd7af',

        # number: 80 - 143
        '5fd7d7 5fd7ff 5fff00 5fff5f 5fff87 5fffaf 5fffd7 5fffff',
        '870000 87005f 870087 8700af 8700d7 8700ff 875f00 875f5f',
        '875f87 875faf 875fd7 875fff 878700 87875f 878787 8787af',
        '8787d7 8787ff 87af00 87af5f 87af87 87afaf 87afd7 87afff',
        '87d700 87d75f 87d787 87d7af 87d7d7 87d7ff 87ff00 87ff5f',
        '87ff87 87ffaf 87ffd7 87ffff af0000 af005f af0087 af00af',
        'af00d7 af00ff af5f00 af5f5f af5f87 af5faf af5fd7 af5fff',
        'af8700 af875f af8787 af87af af87d7 af87ff afaf00 afaf5f',

        # number: 144 - 207
        'afaf87 afafaf afafd7 afafff afd700 afd75f afd787 afd7af',
        'afd7d7 afd7ff afff00 afff5f afff87 afffaf afffd7 afffff',
        'd70000 d7005f d70087 d700af d700d7 d700ff d75f00 d75f5f',
        'd75f87 d75faf d75fd7 d75fff d78700 d7875f d78787 d787af',
        'd787d7 d787ff d7af00 d7af5f d7af87 d7afaf d7afd7 d7afff',
        'd7d700 d7d75f d7d787 d7d7af d7d7d7 d7d7ff d7ff00 d7ff5f',
        'd7ff87 d7ffaf d7ffd7 d7ffff ff0000 ff005f ff0087 ff00af',
        'ff00d7 ff00ff ff5f00 ff5f5f ff5f87 ff5faf ff5fd7 ff5fff',

        # number: 208 - 231
        'ff8700 ff875f ff8787 ff87af ff87d7 ff87ff ffaf00 ffaf5f',
        'ffaf87 ffafaf ffafd7 ffafff ffd700 ffd75f ffd787 ffd7af',
        'ffd7d7 ffd7ff ffff00 ffff5f ffff87 ffffaf ffffd7 ffffff',

        # Gray-scale range.
        # number: 232 - 255
        '080808 121212 1c1c1c 262626 303030 3a3a3a 444444 4e4e4e',
        '585858 626262 6c6c6c 767676 808080 8a8a8a 949494 9e9e9e',
        'a8a8a8 b2b2b2 bcbcbc c6c6c6 d0d0d0 dadada e4e4e4 eeeeee',
    ]
);

main() if $0 eq __FILE__;

sub help {
    my $palettes = join ' or ', map { "`$_'" } sort keys %{$conf{palette}};
    print <<HELP;
set terminal color palette tool

    --palette, -p name:
        set whole palette to `name'.
        name will be $palettes.

    --inputfile, -i filename:
        set whole palette from a file named `filename'.
        file must have one color in each line and 16 lines at all.

    --number, -n num:
        specify color number.
        this option can be used with -c option.

    --color, -c color:
        specify color.
        color can be these formats:
            112        : xterm color 0 .. 255
            0x33       : xterm color 0x00 .. 0xff
            102,36,443 : RGB in decimal
            0xfc2669   : RGB in hex
            #fc2669    : same
            fc2669     : prefix can be skipped

    --help, -h:
        show this message.
HELP
}

sub main {
    if ($help) {
        help();
    } elsif (defined $palette_name && 0 < length $palette_name) {
        my $palette = $conf{palette}{$palette_name}
            or die "unknown palette '$palette_name'";
        set_color_palette($palette);
        print "set whole color palette success\n";
    } elsif (defined $input_file && 0 < length $input_file) {
        my $palette = get_palette_from_file($input_file)
            or die "can't get palette from file: '$input_file'";
        set_color_palette($palette);
        print "set whole color palette success\n";
    } elsif (defined $color_number && 0 <= $color_number && 15 >= $color_number
            && defined $color) {
        set_color($color_number, parse_color($color));
        print "set color number $color_number to color $color\n";
    } else {
        help();
    }
}

sub get_palette_from_file {
    my $input_file = shift;

    open my $fh, '<', $input_file or die "can't open file: $input_file";
    my @palette;
    while (defined(my $line = $fh->getline)) {
        push @palette, parse_color($line);
    }

    return \@palette;
}

sub set_color_palette {
    my $palette = shift;

    for my $color_number (0 .. 15) {
        set_color($color_number, parse_color($palette->[$color_number]))
            if defined $palette->[$color_number];
    }
}

sub get_color {
    my $color_number = shift;

    my $cmd = sprintf 'printf \e]4;%d;?\e\\\\', $color_number;
    my $color = `printf "$cmd"`;
    my ($b, $g, $r) = $color =~ m!(..)../(..)../(..)!;

    return "$r$g$b";
}

sub set_color {
    my ($color_number, $color) = @_;

    printf "\e]4;%d;#%s\e\\", $color_number, $color;
}

sub parse_color {
    my ($color) = shift =~ /^\s*(\S*)\s*$/;

    my ($r, $g, $b) = ('00', '00', '00');

    # xterm color in hex
    if ($color =~ /^0x([a-f\d]{2})$/i && defined $conf{xterm_color}[hex $1]) {
        ($r, $g, $b) = $conf{xterm_color}[hex $1] =~ /(..)(..)(..)/;

    # RGB in decimal: 102,36,443
    } elsif ($color =~ /,/) {
        ($r, $g, $b) = map { defined $_ ? sprintf('%02x', $_) : '00' }
            split ',', $color;

    # RGB in hex
    } elsif ($color =~ /^(?:0x|#)?([a-f\d]{6})$/i) {
        ($r, $g, $b) = $1 =~ /(..)(..)(..)/;

    # xterm color in decimal
    } elsif ($color =~ /^\d+$/ && defined $conf{xterm_color}[$color]) {
        ($r, $g, $b) = $conf{xterm_color}[$color] =~ /(..)(..)(..)/;
    }

    return "$b$g$r";
}
