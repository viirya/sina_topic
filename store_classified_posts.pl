#!/usr/bin/perl

# use module
use DBI;
use Data::Dumper;
use Encode;
use utf8;
#use encoding 'utf8', Filter => 1;

my $file = $ARGV[0];

my $dbh = DBI->connect("DBI:mysql:database=;host=localhost", "", "", {'RaiseError' => 1});
$dbh->do('SET NAMES utf8');

if (defined($ARGV[1]) && $ARGV[1] eq "overwrite") {
 
    my $sth = $dbh->prepare("delete from data_posts_topics;");
    $sth->execute();

}

open FILE, "<:utf8", "$file" or die $!;
while (<FILE>) {

    # find classified posts
    if ($_ =~ /^(\d*)(\t.*)/s) {
        my $post_id = $1;
        my $classified = $2;

        print "post: " . $post_id . "\n";

        while ($classified =~ /\t(\w*?)\t(\S+)/sg) {
            my $class_label = $1;
            my $class_score = $2;                           

            my $sth = $dbh->prepare("replace into data_posts_topics values ($post_id, '$class_label', $class_score)");
            $sth->execute();

        }
        
    }

}

close FILE;


exit;

