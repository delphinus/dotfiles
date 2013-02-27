package ColoredString;
use utf8;
use common::sense;
use parent 'Class::Accessor::Lvalue::Fast';
__PACKAGE__->mk_accessors(qw!
    fg bg current_bg string
    hard_left_arrow soft_left_arrow hard_right_arrow soft_right_arrow
!);

sub new { my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{@_};
    my $str = '';
    my $fg = $args->{fg} || '.';
    my $bg = $args->{bg} || '.';
    defined $args->{string}
        and $args->{string} = sprintf "\cE{%s%s}%s", @$args{qw!bg fg string!};
    return $class->SUPER::new(+{
        current_bg => $bg,
        hard_left_arrow => "\x{2b80}", # ⮀
        soft_left_arrow => "\x{2b81}", # ⮁
        hard_right_arrow => "\x{2b82}", # ⮂
        soft_right_arrow => "\x{2b83}", # ⮃
        %$args,
    });
}

sub add { my $self = shift;
    my %p = @_;
    my ($attr_before, $attr_after) = ('', '');
    if ($p{bold}) {
        $attr_before = "\cE{+b}";
        $attr_after = "\cE{-}";
    }
    if ($p{bg} eq $self->current_bg) {
        $self->string .= sprintf " \cE{%s%s}%s %s%s%s",
            $p{bg}, $p{fg}, $self->soft_left_arrow,
            $attr_before, $p{string}, $attr_after;
    } else {
        $self->current_bg = $p{bg};
        $self->string .= sprintf
            " \cE{!r}\cE{.%s}%s\cE{-}\cE{-}\cE{%s%s} %s%s%s",
                $p{bg}, $self->hard_left_arrow,
                $p{bg}, $p{fg}, $attr_before, $p{string}, $attr_after;
    }
}

1;
