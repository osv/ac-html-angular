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
blabla
 /**
  * @ngdoc directive
  * @restrict E
  * @name ngCloak
  */
TEST
        ,
        expect => {
            tags => { ngCloak => '' }
        },
    },

    'Two diretives' => {
        text => <<'TEST'
 /**
  * @ngdoc directive
  * @restrict E
  * @name ngCloak
  *
  */
  
 /**
  * @ngdoc directive
  * @restrict E
  * @name ngCloak2
  */
TEST
        ,
        expect => {
            tags => { ngCloak => '', ngCloak2 => '' }
        },
    },

    '@description documentation' => {
        text => <<'TEST'
    /**
     * @ngdoc directive
     * @name ngCloak
     * @restrict E
     * @describe
     * @description
     * Doc line 1
     * doc line 2
     */
TEST
        ,
        expect => {
            tags => { ngCloak => "Doc line 1\ndoc line 2" }
        }
    },

    '@description documentation up to next @{directive}' => {
        text => <<'TEST'
    /**
     * @ngdoc directive
     * @name ngCloak
     * @restrict E
     * @describe
     * @description
     * Doc line 1
     * doc @link 2
     * @test
     */
TEST
        ,
        expect => {
            tags => { ngCloak => "Doc line 1\ndoc \@link 2" }
        }
    },

    '@param - create attribute for diretive' => {
        text => <<'TEST'
 /**
  * @ngdoc directive
  * @name ngCloak
  * @restrict E
  * @param {string} ngModel doc line1
  *   doc line 2
  * @param {string=} ngMin second doc 
  */
TEST
        ,
        expect => {
            tags => { ngCloak => '' },
            'attributes' => {
                'ngCloak' => {
                    'ngModel' => "doc line1\n  doc line 2",
                    'ngMin' => 'second doc'
                }
            }
        },
    },

    
);

while ( my ( $test_name, $test ) = each %tests ) {
    my $parse_result = JsDocParser::parse $test->{text};

    is_deeply( $parse_result, $test->{expect}, 'parse: ' . $test_name );
}

