use strict;
use Data::Dumper;
use utf8;

my $input_dir = $ARGV[0];
my $output_dir = $ARGV[1];

if(-x $input_dir) {

    # search this directory
    my @lines = `cd $input_dir; ls -1`;
    foreach my $line (@lines) {
        $line =~ /(\S+)$/;
        my $file = $1;
        print "Processing $file in $input_dir\n";

        `perl trim_html_file.pl $input_dir$file >> $output_dir$file`;

    }

}

exit;


