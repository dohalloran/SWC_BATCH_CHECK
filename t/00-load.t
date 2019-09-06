#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'SWC_BATCH_CHECK' ) || print "Bail out!\n";
}

diag( "Testing SWC_BATCH_CHECK $SWC_BATCH_CHECK::VERSION, Perl $], $^X" );
