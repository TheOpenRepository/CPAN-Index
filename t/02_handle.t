#!/usr/bin/perl -w

# Test that the way we use IO::File and IO::Zlib work as expected

use strict;
use File::Spec::Functions ':ALL';
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 3;
use Params::Util '_HANDLE';
use CPAN::Index;
use CPAN::Index::Loader;

# Test mirror
my $MIRROR = catdir('t', 'data');
ok( -d $MIRROR, 'Mirror directory found' );





#####################################################################
# Create the loader

my $loader = CPAN::Index::Loader->new( root => $MIRROR );
isa_ok( $loader, 'CPAN::Index::Loader' );

# Test a file in the mirror
sub test_file {
	my $file = shift;
	my $path = $loader->local_file('files/test.txt');
	ok( -f $path, "Found test file $file" );
	my $handle = $loader->local_handle('files/text.txt');
	ok( _HANDLE($handle), '->local_handle($file) returns a _HANDLE ' );

	# Pull the lines off it
	my $counter = 0;
	foreach ( 0 .. 100000 ) { # Infinite loop protection
		last unless defined $handle->getline;
		$counter++;
	}

	ok( $counter, "Got $counter lines from the $file handle" );
	ok( $handle->eof, '->eof returns true at EOF' );
}

# Make sure both a regular and zipped file work
test_file( 'files/test.txt' );
test_file( 'files/test.txt.gz' );

exit(0);
