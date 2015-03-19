use 5.008003;
use warnings;
use strict;
use Test::More;
use FindBin               qw( $RealBin );
use File::Spec::Functions qw( catfile );

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        plan skip_all => "MSWin32: Expect not available.";
    }
    #if ( ! $ENV{TESTS_USING_EXPECT_OK} ) {
    #    plan skip_all => "Environment variable 'TESTS_USING_EXPECT_OK' not enabled.";
    #}
}

eval "use Expect";
if ( $@ ) {
    plan skip_all => $@;
}

use lib $RealBin;
use Data_Test_Readline;

my $command = $^X;
my $key = Data_Test_Readline::key_seq();
my $a_ref = Data_Test_Readline::return_test_data();

( my $nr = __FILE__ )=~ s/.*06_readline_(\d+)\.t\z/$1/;

my $readline_pl = catfile $RealBin, 'readline.pl';
my @parameters = ( $readline_pl, $nr );

my $exp;
eval {
    $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->clone_winsize_from( \*STDIN );
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
    1;
}
or plan skip_all => $@;

my $pressed_keys = $a_ref->[$nr]{used_keys};
my $expected     = $a_ref->[$nr]{expected};

my @seq;
for my $k ( @$pressed_keys ) {
    push @seq, exists $key->{$k} ? $key->{$k} : $k;
}

$exp->send( @seq );

my $ret = $exp->expect( 2, [ qr/<.*>/ ] );
my $result = $exp->match();
$result = '' if ! defined $result;

ok( $ret, 'matched something' );
ok( $result eq $expected, "expected: '$expected', got: '$result'" );


$exp->hard_close();

done_testing();
