#!/usr/bin/env perl
use warnings;
use strict;
use 5.008003;

use Term::ReadLine::Simple;

use FindBin qw( $RealBin );
use lib $RealBin;
use Data_Test_Readline;

my $a_ref = Data_Test_Readline::return_test_data();
my $args  = $a_ref->[shift]{arguments};

my $tiny = Term::ReadLine::Simple->new();
my $line = $tiny->readline( @$args );

print "<$line>\n";
