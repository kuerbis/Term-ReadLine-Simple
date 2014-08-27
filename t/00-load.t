use 5.008000;
use strict;
use warnings;
use Test::More tests => 1;

BEGIN {
    use_ok( 'Term::ReadLine::Simple' ) or print "Bail out!\n";
}

diag( "Testing Term::ReadLine::Simple $Term::ReadLine::Simple::VERSION, Perl $], $^X" );
