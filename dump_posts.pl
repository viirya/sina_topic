#!/bin/perl

use Data::Dumper;
use Text::Iconv;
use Encode;
use SinaDB;

binmode STDOUT, ":utf8";

my $start_record = $ARGV[0];
my $length = $ARGV[1];
my $filename = $ARGV[2]; 
my $dumpall = defined($ARGV[3]) ? $ARGV[3] : "no";

my @records;

if ($dumpall eq "no") {
    @records = fetch_unclassified_posts($start_record, $length);
} else {
    @records = fetch_all_posts($start_record, $length);
}
 
open FILE, ">:utf8", "$filename" or die $!;

while (my $ref = pop @records) {

    print FILE $ref->{pid}, ",", ",", $ref->{text} . "\n";
    
}

close(FILE);
                  
exit;

