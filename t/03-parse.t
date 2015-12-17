#!/usr/bin/perl -I../lib -Ilib

use strict;
use warnings;

use Test::More qw( no_plan );

use JsDocParser;

# jsdocs
my %tests = (
    "01 ngdoc w/o directive" => {
        text => <<'TEST'
  /**
   * @ngdoc directive
   */
TEST
        ,
        expect => undef,
    },
    '02 One diretive @name' => {
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

    '03 Two diretives' => {
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

    '04 @description documentation' => {
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

    '05 @description documentation up to next @{directive}' => {
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

    '06 @param - create attribute for diretive' => {
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
            tags         => { ngCloak => '' },
            'attributes' => {
                'ngCloak' => {
                    'ngModel' => "doc line1\n  doc line 2",
                    'ngMin'   => 'second doc'
                }
            }
        },
    },

    '07 @restrict A @element ANY - should create global attribute' => {
        text => <<'TEST'
/**
 * @ngdoc directive
 * @name ngCloak
 * @restrict A
 * @element ANY
 */
TEST
        ,
        expect => {
            'attributes' => {
                'global' => {
                    'ngCloak' => '',
                }
            }
        },
    },

'08 @restrict A @element input, form - should create attributes for "input" and "form"'
      => {
        text => <<'TEST'
/**
 * @ngdoc directive
 * @name ngCloak
 * @restrict A
 * @description
 * some doc
 * @element INPUT, form
 */
TEST
        ,
        expect => {
            'attributes' => {
                'input' => { 'ngCloak' => 'some doc' },
                'form'  => { 'ngCloak' => 'some doc' },
            }
        },
      },

    '09 @ngDoc input' => {
        text => <<'TEST'
    /**
     * @ngdoc input
     * @name input[date]
     * @param {string} ngModel data-bind to.
     * @param {string=} name Property name.
     */
TEST
        ,
        expect => {
            'tags'       => { input => '' },
            'attributes' => {
                'input' => {
                    'ngModel' => 'data-bind to.',
                    'name'    => 'Property name.'
                },
            }
        },
      },

);

foreach my $test_name ( sort keys %tests ) {
    my $test         = $tests{$test_name};
    my $parse_result = JsDocParser::parse $test->{text};

    is_deeply( $parse_result, $test->{expect}, 'parse: ' . $test_name );
}

