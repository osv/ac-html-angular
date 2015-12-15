#!/usr/bin/perl -I../lib -Ilib

use strict;
use warnings;

use Test::More qw( no_plan );

use JsDocParser qw(merge_parse_result);

subtest q(basic) => sub {
    my $data = { tags => { a => '' } };

    my $result = merge_parse_result {}, $data;
    is_deeply $result, $data, 'merge with empty should same data';

};

subtest q(merge 2 tags) => sub {
    my $a = { tags => { a => 'doc a' } };
    my $b = {
        tags => { b => 'doc b' },
        junk => 123
    };
    my $except = {
        tags => {
            a => 'doc a',
            b => 'doc b',
        }
    };

    my $result = merge_parse_result $a, $b;

    is_deeply $result, $except,
      q(keep tags when merge, but don't merge junk data);
};

subtest q(merge 2 attributes) => sub {
    my $a = {
        attributes => {
            div => {
                'ngFoo' => 'doc a1',
                'ngBar' => ''
            }
        }
    };
    my $b = {
        attributes => { global => { ngBaz => '' } },
        junk       => 123
    };
    my $except = {
        attributes => {
            div => {
                'ngFoo' => 'doc a1',
                ngBar   => ''
            },
            global => { ngBaz => '' },
        }
    };

    my $result = merge_parse_result $a, $b;

    is_deeply $result, $except,
      q(keep attributes when merge, but don't merge junk data);

};

