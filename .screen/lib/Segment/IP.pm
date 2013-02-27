package Segment::IP;
use utf8;
use common::sense;
use parent 'Segment';
__PACKAGE__->mk_accessors(qw!url!);

use LWP::Simple;

sub new { my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{@_};
    return $class->SUPER::new(+{
        url => 'http://ipv4.icanhazip.com/',
        %$args,
    });
}

sub render { my $self = shift;
    my %data = $self->get_data;
    $self->text->add(fg => 'k', bg => 'y', string => $data{weather});
}

sub get_data { my $self = shift;
    return get($self->url);
}

# vim:se et:
