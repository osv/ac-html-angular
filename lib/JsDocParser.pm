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
    print "test: $text\n";

    while (
        $text =~ m|
                        ^(\s*)  # save indent space
                        /\*\*   # start jsdoc comment
                        (.*?
                            \@ngDoc\s+directive # @ngDoc directive
                            .*?   # other stuff
                        )
                        \*/
                    |xgsi
      )
    {

        my ( $indent, $body ) = ( $1, $2 );

        # remove comments
        $body =~ s/^$indent( \* |\s{3})//mg;
        next unless ( $body =~ m|\@name\s+(\w+)| );
        my $directive = $1;

        $result->{tags}->{$directive} |= '';

    }

    return $result;

}

1;
