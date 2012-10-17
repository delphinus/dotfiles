@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!/usr/bin/env perl
#line 15

use utf8;
use common::sense;
use Encode;
use Path::Class;
use JSON;
use Time::HiRes qw!alarm!;

my $arg = decode(utf8 => shift) or exit;
my ($channel, $msg) = $arg =~ /^(.*?:) (.*)$/;

my @fifos = grep {
    -p and $_->basename =~ /^backtick-(\d+)\.fifo$/;
} dir('C:/cygwin/tmp')->children;

for my $fifo (@fifos) {
    eval {
        local $SIG{ALRM} = sub { die 'timeout'; };
        alarm 0.1;
        (my $fh = $fifo->open('a')) or die "can't open $fifo";
        binmode $fh => ':utf8';
        $fh->print("\cE{km} $channel \cE{-}\cE{kb} $msg \cE{-}");
        $fh->close;
    };
    alarm 0;
}

__END__
:endofperl
@rem = vim:syn=perl
