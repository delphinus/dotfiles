die 'this is module.' if $0 eq __FILE__;
$Log::Minimal::AUTODUMP = 1;
$Log::Minimal::COLOR = 1;
{
	my %package_cache;
	$Log::Minimal::PRINT = sub {
		my ($time, $type, $message, $trace, $raw_message) = @_;
		my ($filename, $line) = $trace =~ /^(\S+) line (\d+)$/;
		unless ($package_cache{$filename}) {
			open my $fh, '<', $filename or die;
			my $source = do { local $/; <$fh> };
			$fh->close;
			($package_cache{$filename}) = $source =~ /package\s+([^\n\s]+);/;
		}
		warn "$time [$type] $message at $package_cache{$filename} line $line\n";
	};
}
