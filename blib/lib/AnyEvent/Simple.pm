package AnyEvent::Simple;

use 5.016000;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use AnyEvent::Simple ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

use IO::Select;

sub new {
	my $class = shift;
	my $select = IO::Select->new();
	my %waiters = ();
	my $self = bless {
		waiters => %waiters,
		select => $select,
	}, $class;
	return $self;
}

sub io {
	my ($fh, $sign, $cb) = @_;

}

sub timer {

}

1;
__END__

