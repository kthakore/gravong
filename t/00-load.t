#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Gravong' ) || print "Bail out!
";
}

diag( "Testing Gravong $Gravong::VERSION, Perl $], $^X" );
