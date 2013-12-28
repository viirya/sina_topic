use strict;
use HTML::Parser ();
use Data::Dumper;
use utf8;

#binmode STDOUT, ":utf8";

my $input_file = $ARGV[0];

my $p = HTML::Parser->new( api_version => 3,
                           text_h => [sub { print shift }, "dtext"],
                           marked_sections => 1,
                         );

$p->parse_file($input_file);

exit;


