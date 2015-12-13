#!/usr/bin/perl -I../lib -Ilib

use strict;
use warnings;

use Test::More qw( no_plan );

use JsDocParser qw( snake_case );

is( snake_case('foBar'), 'fo-bar', 'camelCase foBar -> fo-bar' );

is( snake_case('foBarBaz'), 'fo-bar-baz', 'camelCase foBarBaz -> fo-bar-baz' );

is( snake_case('FoBarBaz'), '-fo-bar-baz', 'camelCase FoBarBaz -> -fo-bar-baz' );

