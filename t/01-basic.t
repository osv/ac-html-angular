#!/usr/bin/perl -I../lib -Ilib
# 
#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More qw( no_plan );
BEGIN { use_ok( JsDocParser ); }

can_ok('JsDocParser', qw(parse snake_case sanitize_text merge_parse_result))
