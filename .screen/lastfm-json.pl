#!/usr/bin/env perl
use utf8;
use common::sense;
use FindBin;
use JSON;

use lib "$FindBin::Bin/lib";
use Segment::LastFM;

my $lastfm = Segment::LastFM->new;
my $data = $lastfm->_get_data;

print to_json($data);
