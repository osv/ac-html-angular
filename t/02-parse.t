#!/usr/bin/perl -I../lib -Ilib

use strict;
use warnings;

use Test::More qw( no_plan );

use JsDocParser;

# jsdocs
my %tests = (
    "ngdoc w/o directive" => {
        text => <<'TEST'
  /**
   * @ngdoc directive
   */
TEST
        ,
        expect => undef,
    },
        'One diretive @name' => {
        text => <<'TEST'
 /**
  * @ngdoc directive
    @name ngCloak
  */
TEST
        ,
        expect => {
            tags => {ngCloak => ''}
        },
    },

);

while ( my ( $test_name, $test ) = each %tests ) {
    my $parse_result = JsDocParser::parse $test->{text};

    is_deeply( $parse_result, $test->{expect}, 'parse: ' . $test_name );
}

