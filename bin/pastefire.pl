#!/usr/bin/env perl
use strict;
use warnings;
use JSON;
use Path::Class;
use WebService::Pastefire;
binmode STDIN => ':utf8';

local $/;
my $text = shift || <>;
length $text or die "please specify text.\n";

my $config = file(($ENV{H} or $ENV{HOME}) . '/.pastefire');
-f $config or die "can't find config file.\n";
my $setting = eval { from_json($config->slurp) };
$@ and die "can't read config file. : $config\n";
$setting->{username} and $setting->{password}
	or die "invalid config : $config\n";

my $pf = WebService::Pastefire->new($setting);
$pf->paste($text);
