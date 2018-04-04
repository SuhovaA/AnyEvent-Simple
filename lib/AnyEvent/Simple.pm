package AnyEvent::Simple;

use 5.016000;
use strict;
use warnings;
use lib './blib';

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
	my $rin = my $win = my $ein = '';
	
	my $self = bless {
		rin => $rin,
		win => $win,
		ein => $ein,
		wait => my $wait,
		get_fh => my $arr,
		deadlines => my $deadlines,
	}, $class;
	return $self;
}

sub io {
	my ($self, $fh, $sign, $cb) = @_;
	if ($sign eq "r") {
		vec($self->{rin}, fileno($fh), 1) = 1;
	} elsif ($sign eq "w") {
		vec($self->{win}, fileno($fh), 1) = 1;
	} elsif ($sign eq "e") {
		vec($self->{ein}, fileno($fh), 1) = 1;
	} else {
		die "Error: sign != (r, w, e)";
	}
	${ $self->{wait} }{$fh} = $cb;
	${ $self->{get_fh} }{fileno($fh)} = $fh;
	
	my @a = ($fh, $sign);
	return \@a;

}

sub destroy {
	my ($self, $ref) = @_;
	my ($fh, $sign) = @$ref;
	if ($sign eq "r") {
		vec($self->{rin}, fileno($fh), 1) = 0;
	} elsif ($sign eq "w") {
		vec($self->{win}, fileno($fh), 1) = 0;
	} elsif ($sign eq "e") {
		vec($self->{ein}, fileno($fh), 1) = 0;
	} else {
		die "Error: sign != (r, w, e)";
	};
	delete ${ $self->{get_fh} }{fileno($fh)};
	delete ${ $self->{wait} }{$fh};
}

sub ready_fds {
	my ($self, $vec) = @_;
	my %get_fh = %{ $self->{get_fh} };
	my @map = map { $get_fh{$_} } grep { vec($vec,$_,1) } 0..8*length($vec)-1;
	return @map;
}

sub timer {
	my ($self, $t, $cb) = @_;
	my $deadline = time + $t;
	my @deadlines;
	@deadlines = sort { $a->[0] <=> $b->[0] } @deadlines, [ $deadline, $cb ];
	@{ $self->{deadlines} } = @deadlines;
}

sub run_loop {
	my ($self, $timeout) = @_;

	my $rin;
	my $win;
	my $ein;

	while (1) {

		$rin = $self->{rin};
		$win = $self->{win};
		$ein = $self->{ein};

		my $nfound = select($rin, $win, $ein, $timeout);
		if ($nfound) {
			my %waiters = %{ $self->{wait} };
			for my $fh (ready_fds($self, $rin)) {
				my $cb = $waiters{$fh};
				$cb->();
			}
			for (ready_fds($self, $win)) {
				my $cb = $waiters{$_};
				$cb->();
			}
		}
		if (defined $self->{deadlines}) {
			my @deadlines = @{ $self->{deadlines} };
			if (@deadlines) {
				my $now = time;
				my @exec;

			    while ((@deadlines) && ($now > $deadlines[0][0])) {
			        push @exec, shift(@deadlines);
			    }
		    	for my $dl (@exec) {
		        	$dl->[1]->();
		    	}
		    	$self->{deadlines} = \@deadlines;
			}
		}
	}
}
1;
__END__

