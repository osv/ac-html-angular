#!/usr/bin/perl -w -Ilib

use strict;
use warnings;

use File::Spec;
use File::Slurp qw(read_file write_file);
use File::Path qw(make_path);

use JsDocParser qw(sanitize_text snake_case);

use constant AC_HTML_TAG_LIST            => 'html-tag-list';
use constant AC_HTML_TAG_DOCS            => 'html-tag-short-docs';
use constant AC_HTML_ATTRIBUTES          => 'html-attributes-list';
use constant AC_HTML_ATTR_DOCS           => 'html-attributes-short-docs';
use constant AC_HTML_ATTRIBUTES_COMPLETE => 'html-attributes-complete';

my $path       = $ARGV[0];
my $output_dir = $ARGV[1];

if ( !-d $path || !defined $output_dir ) {
    print <<HELP
Create autocompletion data for ac-html and company-web

Usage:
 $0 <dir to angular.js> <output_dir>
HELP
      ;

    exit(1);
}

# Accepts one argument: the full path to a directory.
# Returns: A list of js files that end in '.js'
sub get_js_files {
    my $path = shift;

    opendir( DIR, $path )
      or die "Unable to open $path: $!";

    my @files =
      map { File::Spec->catfile( $path, $_ ); }
      grep { !/^\.{1,2}$/ } readdir(DIR);

    # Rather than using a for() loop, we can just
    # return a directly filtered list.
    return grep { (/\.js$/) && ( !-l $_ ) }
      map { -d $_ ? get_js_files($_) : $_ } @files;
}

my @files = get_js_files $path;

my $merged = {};

foreach my $file (@files) {
    my $data = read_file $file;

    my $parsed_data = JsDocParser::parse $data;
    $merged = JsDocParser::merge_parse_result $merged, $parsed_data;
}

# create html stuff

make_path $output_dir;

my $text_tags =
  join( "\n", map { snake_case $_ } sort keys %{ $merged->{tags} } );
my $tag_file = File::Spec->catfile( $output_dir, AC_HTML_TAG_LIST );

write_file( $tag_file, $text_tags );
print "$tag_file\n";

my $tag_doc_dir = File::Spec->catfile( $output_dir, AC_HTML_TAG_DOCS );
make_path $tag_doc_dir;

while ( my ( $tag_name, $doc ) = each %{ $merged->{tags} } ) {
    my $file_name = File::Spec->catfile( $tag_doc_dir, snake_case $tag_name );
    my $sanitized_doc = sanitize_text $doc;
    write_file( $file_name, $sanitized_doc );
    print "$file_name\n";
}

my $attr_list_dir = File::Spec->catfile( $output_dir, AC_HTML_ATTRIBUTES );
my $attr_doc_dir  = File::Spec->catfile( $output_dir, AC_HTML_ATTR_DOCS );
make_path $attr_list_dir;
make_path $attr_doc_dir;

foreach my $ng_tag_name ( sort keys %{ $merged->{attributes} } ) {

    my $tag      = $merged->{attributes}->{$ng_tag_name};
    my $tag_name = snake_case $ng_tag_name;
    my @attributes;

    foreach my $ng_attribute ( sort keys %{$tag} ) {
        my $attribute    = snake_case $ng_attribute;
        my $filename     = qq($tag_name-$attribute);
        my $doc_filename = File::Spec->catfile( $attr_doc_dir, $filename );
        my $doc          = sanitize_text $tag->{$ng_attribute};

        push @attributes, $attribute;
        write_file $doc_filename, $doc;
        print "  $doc_filename\n";
    }
    my $tag_filename = File::Spec->catfile( $attr_list_dir, $tag_name );
    my $attributes_txt = join( "\n", sort @attributes );

    write_file $tag_filename, $attributes_txt;
    print " $tag_filename\n";
}

