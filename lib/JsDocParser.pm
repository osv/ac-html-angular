package JsDocParser;

use strict;
use warnings;

use Carp;
use Data::Dumper;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(snake_case parse);

sub snake_case {
    my $text = shift;
    $text =~ s/([A-Z])/-\l$1/g;
    return $text;
}

sub parse {
    my $text = shift;

    my $any = '(?:[*]/)*';

    my $result;

    while (
        $text =~ m|
                      ^([ ]*)  # save indent space
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

        # @restricts EAC - E - tag, - A attribute, C - class
        my %restricts =
          map { $_ => 1 }
          split( / /x, ( $jsdoc_items{'@restrict'} || ['A'] )->[0] );

        my @elements =
          split( /,\s*/, ( $jsdoc_items{'@elements'} || ['ANY'] )->[0] );

        my $doc = $jsdoc_items{'@description'}[0] || '';

        # if element
        if ( $restricts{E} ) {
            $result->{tags}->{$directive} |= $doc;

            # each @param in jsdoc is directive's attribute
            foreach my $jsdoc_param ( @{ $jsdoc_items{'@param'} } ) {

                # parse str like '{string=} ngRequired Adds `required` attribute and'
                # get           ---------$1-^-------$2-^
                if (
                    $jsdoc_param =~ m /
                                     \{.*?\}
                                     \s+
                                     (\w+)
                                     \s+
                                     (.*)
                                 /xs
                  )
                {
                    my ( $name, $doc ) = ( $1, $2 );

                    $result->{attributes}->{$directive}->{$name} = $2;
                }
            }

        }

        # attribute
        if ( $restricts{A} ) {
            print "XXXXXXXXXXXXXX\n";
            print "$body\n";
            print "indent '$indent'\n";

        }

    }

    return $result;

}

1;
