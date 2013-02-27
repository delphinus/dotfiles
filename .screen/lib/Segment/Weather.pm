package Segment::Weather;
use utf8;
use common::sense;
use parent 'Segment';
__PACKAGE__->mk_accessors(qw!location_query!);

use LWP::UserAgent;

use Segment::Location;

sub new { my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{@_};
    return $class->SUPER::new(+{
        %$args,
    });
}

sub render { my $self = shift;
    my %data = $self->get_data;
    $self->text->add(fg => 'W', bg => 'c', string => $data{weather});
}

sub get_data { my $self = shift;
    my $ua = LWP::UserAgent->new;

    my %location;
    if ($self->location_query) {
        @location{qw!city regeion_name country_name!}
            = split ',', $self->location_query;
    } else {
        %location = Segment::Location->new;
    }
}

# vim:se et:
