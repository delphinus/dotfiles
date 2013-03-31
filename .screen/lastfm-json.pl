#!/usr/bin/env perl
use utf8;
use common::sense;
use FindBin;
use JSON;
use Path::Class;

use lib "$FindBin::Bin/lib";
use Segment::LastFM;

my $interval = 30;
my $tmp = '/tmp/lastfm-data.txt';

my $now = time;
my %last;

my $result = eval { from_json(file($tmp)->slurp) };
if (defined $result) {
	$last{timestamp} = $result->{timestamp} || $now;
	$last{data} = $result->{data} || +{};
} else {
	$last{timestamp} = 0;
	$last{data} = +{};
}

if ($now - $last{timestamp} < $interval) {
	print to_json($last{data});
} else {
	my $lastfm = Segment::LastFM->new;
	my $data = $lastfm->_get_data;
	file($tmp)->openw->print(to_json(+{
		timestamp => $now,
		data => $data,
	}));
	print to_json($data);
}
