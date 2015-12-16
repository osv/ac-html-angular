#!/usr/bin/perl -I../lib -Ilib

use strict;
use warnings;

use Test::More qw( no_plan );

use JsDocParser qw(sanitize_text);

is( sanitize_text('foo {@link far/bar link}'), 'foo link', '@link sanitize' );
is( sanitize_text('{@link ngRoute `ngRoute`}'),
    '`ngRoute`', '@link sanitize with backquote' );
is(
    sanitize_text(
        '{@link ng.$sceDelegateProvider#resourceUrlWhitelist whitelist them}'),
    'whitelist them',
    '@link multiple words'
);
