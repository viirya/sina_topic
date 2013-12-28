use strict;
use Data::Dumper;
use utf8;

my $input_dir = $ARGV[0];
my $output_dir_prefix = $ARGV[1];

$input_dir =~ /.*\/(.*)/;

my $output_dir = "$output_dir_prefix/$1/";

unless(-d $output_dir){
    system("mkdir -p $output_dir") == 0 or die "Error: mkdir -p $output_dir";
}

if(-x $input_dir) {

    # search this directory
    my @lines = `cd $input_dir; ls -1`;
    foreach my $line (@lines) {
        $line =~ /(\S+)$/;
        my $file = $1; 

        print "Processing $file in $input_dir\n";

        `java org.viirya.lucene.analysis.tw.ChineseAnalyzer $input_dir/$file >> $output_dir$file`;

    }   

}

exit;

