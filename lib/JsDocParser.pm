package JsDocParser;

use strict;
use warnings;

use Carp;

sub new {
    my $class   = shift;
    my $options = shift;

    return bless( {}, $class );
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
        
        print "DIRECTIVE: $directive\n";

    }

    return $result;

}

1;
