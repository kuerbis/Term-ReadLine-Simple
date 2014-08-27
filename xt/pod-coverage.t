use 5.008000;
use strict;
use warnings;
use Test::More;

use Test::Pod::Coverage;
use Pod::Coverage;

plan tests => 1;
pod_coverage_ok( 'Term::Choose' );
#all_pod_coverage_ok();
