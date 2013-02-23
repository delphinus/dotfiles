#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use Date::Manip;
use Net::Twitter;
use Scalar::Util qw!blessed!;

binmode STDOUT => ':utf8';
binmode STDERR => ':utf8';

my $nt = Net::Twitter->new(
	traits => [qw!OAuth API::REST!],
	consumer_key => 'VKtSF6TLXPkVJw3w7FDSew',
	consumer_secret => 'Sd8tgWymQQRuvsjTaowyaFoDLv22VmnhCrsdxSMs',
	access_token => '31149073-lZBlHBXJsDp1cMMworn1qX9tLUWVfnw1dwMD1g6e0',
	access_token_secret => '42fXHUOaibI1APunV8BQDuFVQuVc1gPk3QSf7LGejk',
);

eval {
	my $statuses = $nt->friends_timeline({count => 1});
	for my $s (@$statuses) {
		my $timestamp = Date_ConvTZ $s->{created_at}, 'GMT';
		$timestamp = UnixDate $timestamp => '%Y/%m/%d %H:%M:%S';
		print "$timestamp <\@$s->{user}{screen_name}> $s->{text}\n";
	}
};
if (my $err = $@) {
	die $@ unless blessed $@ && $err->isa('Net::Twitter::Error');

	printf "HTTP Error: %d %s, Twitter Error: %s\n",
		$err->code, $err->message, $err->error;
}
