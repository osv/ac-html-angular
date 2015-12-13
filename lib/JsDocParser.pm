package JsDocParser;

use strict;
use warnings;

use Carp;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(snake_case parse);

sub snake_case {
    my $text = shift;
    $text =~s/([A-Z])/-\l$1/g;
    return $text;
}

sub parse {
    my $text = shift;

    my $any = '(?:[*]/)*';

    my $result;

    while (
        $text =~ m|
                        ^(\s*)  # save indent space
                        /\*\*   # start jsdoc comment
                        (.*?
                            \@ngDoc\s+directive # @ngDoc directive
                            .*?   # other stuff
                        )
                        \*/
                    |xgsim
      )
    {

        my ( $indent, $body ) = ( $1, $2 );

        # remove comments
        $body =~ s/^$indent(\s\*\s?|\s{3})//mg;
        next unless ( $body =~ m|\@name\s+(\w+)| );
        my $directive = $1;

        # split by \@XXX and setup structure { \@XXX => '..rest'}
        my %jsdoc_items;

        $body =~ s/(^\s*)\@/_SPLIT_\@/gms;
        foreach my $jsdoc_item ( split( /_SPLIT_/, $body ) ) {
            if ( $jsdoc_item =~ m /(\@\w+)\s+(.*)[\s\n]*/ms ) {
                my ( $item_name, $rest ) = ( $1, $2 );
                $rest =~ s/[\n\s]+$//s;
                push @{ $jsdoc_items{$item_name} }, $rest;
            }
        }

        my $doc = $jsdoc_items{'@description'}[0] || '';

        $result->{tags}->{$directive} |= $doc;

    }

    return $result;

}

1;
