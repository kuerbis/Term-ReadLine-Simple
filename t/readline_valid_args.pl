#!/usr/bin/env perl
use strict;
use warnings;
use 5.008003;

use Term::ReadLine::Simple;

use FindBin qw( $RealBin );
use lib $RealBin;
use Data_Test_Arguments;

my $a_ref = Data_Test_Arguments::valid_args();
my $args = $a_ref->[shift]{args};

my $tiny  = Term::ReadLine::Simple->new();
my $line = $tiny->readline( @$args );

print "<$line>\n";
