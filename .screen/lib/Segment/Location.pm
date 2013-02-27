package Segment::Location;
use utf8;
use common::sense;
use parent 'Segment';
__PACKAGE__->mk_accessors(qw!!);

use JSON;
use LWP::Simple;

use Segment::IP;

sub new { my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{@_};
    return $class->SUPER::new(+{
        url => 'http://freegeoip.net/json/',
        %$args,
    });
}

sub render { my $self = shift;
    my %data = $self->get_data;
    $self->text->add(fg => 'W', bg => 'c', string => $data{weather});
}

sub get_data { my $self = shift;
    my $external_ip = Segment::IP->new->get_data;
    my $location = eval { from_json(get($self->url . $external_ip)) } || +{};
    return wantarray ? %$location : $location;
}

# vim:se et:
