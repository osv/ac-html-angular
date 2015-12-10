#!/usr/bin/perl -I../lib -Ilib

use strict;
use warnings;

use Test::More qw( no_plan );

use JsDocParser;

my %tests = (
    "Basic test" => {
        text => <<'TEST'
/**
 * @ngdoc directive
 */
TEST
        ,
        expect => undef,
    },
);

while ( my ( $test_name, $test ) = each %tests ) {
    my $parse_result = JsDocParser::parse $test->{text};

    is_deeply( $test->{expect}, $parse_result, 'parse: ' . $test_name );
}

