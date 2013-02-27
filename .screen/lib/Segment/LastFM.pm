package Segment::LastFM;
use utf8;
use common::sense;
use parent 'Segment';
__PACKAGE__->mk_accessors(qw!url user api_key text!);

use HTTP::Date qw!time2iso!;
use JSON;
use Log::Minimal;
use LWP::UserAgent;
use URI;

use ColoredString;

sub new { my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{@_};
    $args->{api_key} ||= 'fca0142adfe95a7fb622a63d28b7d1a5';
    $args->{user} ||= 'delphinus_iddqd';
    $args->{text} ||= ColoredString->new;
    return $class->SUPER::new(+{
        url => 'http://ws.audioscrobbler.com/2.0/',
        %$args,
    });
}

sub render { my $self = shift;
    my %data = $self->_get_data;
    $self->text->add(fg => 'W', bg => 'G', string => $data{timestamp});
    $self->text->add(fg => 'k', bg => 'w', string => $data{artist});
    $self->text->add(fg => 'R', bg => 'w', string => $data{title});
    $self->text->add(fg => 'W', bg => 'R', string => 'Now Playing')
        if $data{playing} eq 'now_playing';
}

sub _get_data { my $self = shift;
    my $ua = LWP::UserAgent->new;
    (my $url = URI->new($self->url))->query_form(
        method => 'user.getrecenttracks',
        format => 'json',
        user => $self->user,
        api_key => $self->api_key,
        nowplaying => 'true',
        limit => 1,
    );
    my $res = $ua->get($url);

    if ($res->is_error) {
        infof("can't access to Last.fm : " . $res->error_as_HTML);
        return;
    }

    my $data = eval { from_json($res->content); };
    if ($@) {
        infof("can't decode json : " . $res->content);
        return;
    }

    my $track_info = $data->{recenttracks}{track};
    my $track_info_type = ref $track_info;
    my $status = '';
    my $track;

    # unknown response
    if (!defined $track_info_type || $track_info_type !~ /^(?:ARRAY|HASH)$/) {
        infof("invalid reponse : $data");
        return;

    # now playing
    } elsif (ref $track_info eq 'ARRAY') {
        $track = $track_info->[0];
        $status = 'now_playing';

    # played
    } elsif (ref $track_info eq 'HASH') {
        $track = $track_info;
        $status = 'played';
    }

    my %data = (
        timestamp => time2iso($track->{date}{uts}),
        artist => $track->{artist}{'#text'},
        title => $track->{name},
        playing => $status,
    );

    return wantarray ? %data : \%data;
}

1;

# vim:se et:
