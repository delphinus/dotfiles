package Segment;
use utf8;
use common::sense;
use parent 'Class::Accessor::Lvalue::Fast';
__PACKAGE__->mk_accessors(qw!!);

use Log::Minimal;
use Path::Class;

my $log_file = file('/usr/local/var/logs/backtick-lastfm.log');

# log setting
#{{{
$Log::Minimal::PRINT = sub {
    my ($time, $type, $message, $trace, $raw_message) = @_;
    $ENV{TEST_MODE} or return;
    my $msg = sprintf "%s [%s] %s%s\n",
        $time, $type, $message, ($type eq 'INFO' ? '' : " at $trace");
    my $fh = $log_file->open('a') or die $!;
    binmode $fh => ':utf8';
    $fh->print($msg);
    $fh->close;
};
#}}}

sub new { my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{@_};
    return $class->SUPER::new(+{
        %$args,
    });
}

sub render { ... };

sub finish { my $self = shift;
    $self->text->add(fg => 'm', bg => 'K', string => '');
}

1;
