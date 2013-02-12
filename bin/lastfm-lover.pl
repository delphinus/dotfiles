#!/usr/bin/env perl
use utf8;
use common::sense;
use FindBin;
use Net::LastFM;
use Path::Class;
use Term::ReadKey;
use YAML;

binmode STDOUT => ':utf8';

my $username = 'delphinus_iddqd';
my $api_key = '7a77671178c4f4cff16222c46f72d193';
my $api_secret = 'cfee1ad56e589e215f7b06f266389225';
my $token_file = "$FindBin::Bin/lastfm-lover.token";

my $lastfm = Net::LastFM->new(
    api_key => $api_key,
    api_secret => $api_secret,
);

my $res_recenttracks = $lastfm->request_signed(
    method => 'user.getRecentTracks',
    user => $username,
    limit => 1,
);
my $track = eval {
    my $tmp = $res_recenttracks->{recenttracks}{track};
    ref $tmp eq 'ARRAY' ? $tmp->[0] : $tmp;
};
$@ and die "data corrupted\n" . Dump $res_recenttracks;

my $now_playing = $track->{'@attr'}{nowplaying} eq 'true';
my $title = $track->{name};
my $artist = $track->{artist}{'#text'};

print <<EOF;
now playing: @{[$now_playing ? 'OK' : 'NG']}
artist:      $artist
title:       $title

EOF

$now_playing or
    confirm('This track is not now playing. Do you continue?') or exit;

confirm('Do you Love this track?') or exit;

my $token = eval { file($token_file)->slurp };
unless ($token) {
    $token = $lastfm->request_signed(method => 'auth.getToken')->{token};
    file($token_file)->openw->print($token);
}

my $res_love = eval {
    my $session_key = $lastfm->request_signed(
        method => 'auth.getSession',
        token => $token,
    )->{session}{key};

    my $req = $lastfm->create_http_request_signed(
        method => 'track.love',
        track => $title,
        artist => $artist,
        sk => $session_key,
    );
    $req->method('POST');

    $lastfm->_make_request($req);
};

if (!$@ and ref $res_love and $res_love->{status} eq 'ok') {
    print "Successfully Loved!\n";

} else {
    my ($err_code, $err_msg, $trace) = $@ =~ /^(\d+): (.*?) at (.*)$/s;
    if ($err_code == 14) {
        die <<EOF;
Please access URL below in web browser.
http://www.last.fm/api/auth/?api_key=$api_key&token=$token
EOF
    } else {
        die $@;
    }
}


sub confirm {
    my $message = shift;
    my $char = '';
    $message and print "$message (y/n)\n";
    do {
        ReadMode 'cbreak';
        $char = ReadKey 0;
        ReadMode 'restore';
    } while ($char ne 'y' and $char ne 'n');
    return $char eq 'y';
}

# vim:se et:
