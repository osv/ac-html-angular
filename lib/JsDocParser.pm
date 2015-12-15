package JsDocParser;

use strict;
use warnings;

use Carp;
use Data::Dumper;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(snake_case sanitize_text parse merge_parse_result);

sub snake_case {
    my $text = shift;
    $text =~ s/([A-Z])/-\l$1/g;
    return $text;
}

sub sanitize_text {
    my $text = shift;

    # '{@link foo/bar baz}' - keep only 'baz'
    $text =~ s/\{\@link.*?\s([^\s]+)\s*?\}/$1/gx;

    return $text;
}

sub parse {
    my $text = shift;

    my $result;

    while (
        $text =~ m|
                      ^([ ]*)  # save indent space
                        /\*\*   # start jsdoc comment
                        (.*?
                            \@ngDoc\s+((?:directive\|input)) # @ngDoc directive
                            .*?   # other stuff
                        )
                        \*/
                    |xgsim
      )
    {

        my ( $indent, $body, $ngdoc_type ) = ( $1, $2, $3 );

        # remove comments
        $body =~ s/^$indent(\s\*\s?|\s{3})//mg;

        next unless ( $body =~ m|\@name\s+(\w+)| );
        my $directive = $1;

        $directive =~ s/\[.*\]//;

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
        my $jsdoc_restricts;
        if ( $ngdoc_type eq 'input' ) {
            $jsdoc_restricts = 'E';
        }
        else {
            $jsdoc_restricts = ( $jsdoc_items{'@restrict'} || ['A'] )->[0];
        }

        my %restricts =
          map { $_ => 1 }
          split( / /x, $jsdoc_restricts );

        my %elements =
          map { $_ => 1 }
          split( /,\s*/, ( $jsdoc_items{'@element'} || ['ANY'] )->[0] );

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
            if ( $elements{ANY} ) {
                $result->{attributes}->{global}->{$directive} |= $doc;
            }
            else {
                foreach my $tag ( sort keys %elements ) {
                    $result->{attributes}->{$tag}->{$directive} |= $doc;
                }

            }
        }

    }

    return $result;

}

# maybe later add merge documentation too
sub merge_parse_result {
    my ( $a, $b ) = @_;

    my $result;

    if ( exists $a->{tags} ) {
        $result->{tags} = $a->{tags};
    }

    if ( exists $b->{tags} ) {
        while ( my ( $tag, $doc ) = each( %{$b->{tags}} ) ) {
            if ( !exists $result->{tags}->{$tag} ) {
                $result->{tags}->{$tag} = $doc;
            }
        }
    }

    # attributes

    if ( exists $a->{attributes} ) {
        while ( my ( $tag, $attributes ) = each( %{ $a->{attributes} } ) ) {
            $result->{attributes} = $a->{attributes};
        }
    }

    if ( exists $b->{attributes} ) {
        while ( my ( $tag, $attributes ) = each( %{ $b->{attributes} } ) ) {
            while ( my ( $attribute, $doc ) = each( %{$attributes} ) ) {
                $result->{attributes}->{$tag}->{$attribute} = $doc;
            }
        }
    }
    return $result;
}

1;
