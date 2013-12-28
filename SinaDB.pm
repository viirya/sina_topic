
package SinaDB;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
 
use DBI;
use XML::Simple;
use Data::Dumper;
use Encode;
use WWW::Mechanize;
use Encode;
use Encode::HanConvert qw(trad simple);
use POSIX qw/strftime/;
use utf8;
 
my $dbh;

my $repost_max = undef;
my $comment_max = undef;

sub open_db {

    $dbh = DBI->connect("DBI:mysql:database=;host=localhost", "", "", {'RaiseError' => 1});
    $dbh->do('SET NAMES utf8');

}

BEGIN {

    open_db();

}

$VERSION     = 0.01;
@ISA         = qw(Exporter);
@EXPORT      = qw(fetch_unclassified_posts fetch_all_posts get_posts_all_users get_posts_all_users_in_range get_posts_count post_user_influence);
@EXPORT_OK   = qw(fetch_unclassified_posts fetch_all_posts get_posts_all_users get_posts_all_users_in_range get_posts_count post_user_influence);

# functions modifying database

sub post_user_influence {

    my $user_id = shift;
    my $class_label = shift;
    my $class_score = shift;

    my $sth = $dbh->prepare("replace into data_users_influence values ($user_id, '$class_label', $class_score)");
    $sth->execute();

}

# functions querying data

sub get_posts_all_users {

    my $row_count = get_posts_count();

    my $all_posts = {};
    my $repost_max;
    my $comment_max;
    my $posts;
    for (my $i = 0; $i < $row_count; $i += 10000) {

        print "fetching from $i\n";

        ($posts, $repost_max, $comment_max) = get_posts_all_users_in_range($i, 10000);

        foreach my $uid (keys %{$posts}) {
            if (exists $all_posts->{$uid}) {
                @{$all_posts->{$uid}} = (@{$all_posts->{$uid}}, @{$posts->{$uid}});
            } else {
                $all_posts->{$uid} = $posts->{$uid};
            }
        }
    }

    return ($all_posts, $repost_max, $comment_max);
 
}

sub get_posts_count {

    my $sth = $dbh->prepare("select count(*) as count from data_users join data_posts on data_users.uid = data_posts.uid");
    $sth->execute();
 
    my $row_count = $sth->fetchrow_hashref()->{count};

    return $row_count;
}

sub get_posts_all_users_in_range {

    my $length = 100;
    my $start_from = shift || 0;
    my $limit = shift || 1000;
    

    my $row_count = get_posts_count();
    my $posts = {};

    for (my $i = $start_from; $i < $row_count && ($i - $start_from) < $limit; $i += $length) {
        my $sub_posts = get_all_posts_cate_users($i, $length);

        foreach my $uid (keys %{$sub_posts}) {
            if (defined($posts->{$uid})) {
                @{$posts->{$uid}} = (@{$posts->{$uid}}, @{$sub_posts->{$uid}});
            } else {
                $posts->{$uid} = $sub_posts->{$uid};
            }
        }
    }

    $repost_max = get_max_repost_count() if !defined($repost_max);
    $comment_max = get_max_comment_count() if !defined($comment_max);

    return ($posts, $repost_max, $comment_max);
}

sub get_max_repost_count {

    my $sth = $dbh->prepare("select max(reposts_count) as max from data_posts");
    $sth->execute();
 
    my $max_count = $sth->fetchrow_hashref()->{max};
    return $max_count; 

}

sub get_max_comment_count {

    my $sth = $dbh->prepare("select max(comments_count) as max from data_posts");
    $sth->execute();
 
    my $max_count = $sth->fetchrow_hashref()->{max};
    return $max_count; 

} 

sub get_all_user_ids {

    my $length = 100;

    my $sth = $dbh->prepare("select count(*) as count from data_users");
    $sth->execute();
 
    my $row_count = $sth->fetchrow_hashref()->{count};

    for (my $i = 0; $i < $row_count; $i += $length) {
        my $sth = $dbh->prepare("select uid from data_users limit $i, $length");
        $sth->execute();
    }
 
}

sub get_post_categories {
 
    my $pid = shift;

    my $sth = $dbh->prepare("select topic_name, topic_score from data_posts_topics where data_posts_topics.pid = $pid");
    $sth->execute();

    my @records; 
    while (my $ref = $sth->fetchrow_hashref()) {
        push @records, $ref; 
    }

    return @records;
 
}

sub get_all_posts_cate_users {

    my $start_record = shift;
    my $length = shift;
 
    my $sth = $dbh->prepare("select data_users.uid, data_posts.pid, data_posts.reposts_count, data_posts.comments_count from data_users join data_posts on data_users.uid = data_posts.uid limit $start_record, $length");
    $sth->execute();

    
    my $records = {};
    while (my $ref = $sth->fetchrow_hashref()) {
        my @categories = get_post_categories($ref->{pid});
        my $data = { pid => $ref->{pid}, categories => \@categories, reposts => $ref->{reposts_count}, comments => $ref->{comments_count}};
        $records->{$ref->{uid}} = () if (!defined($records->{$ref->{uid}}));
        push @{$records->{$ref->{uid}}}, $data;
    }

    return $records;

}

sub get_unclassified_posts {

    my $start_record = shift;
    my $length = shift;
 
    # my $sth = $dbh->prepare("select * from (select data_posts.pid, data_posts.text, data_posts_topics.topic_name from data_posts left join data_posts_topics on data_posts.pid = data_posts_topics.pid) as T where T.topic_name is NULL limit $start_record, $length");
    my $sth = $dbh->prepare("select data_posts.pid, data_posts.text, data_posts_topics.topic_name from data_posts left join data_posts_topics on data_posts.pid = data_posts_topics.pid limit $start_record, $length");
       
    $sth->execute();

    return $sth; 
}

sub get_all_posts {

    my $start_record = shift;
    my $length = shift;

    my $sth = $dbh->prepare("select data_posts.pid, data_posts.text from data_posts where 1 limit $start_record, $length");
    $sth->execute();

    return $sth;

}

sub fetch_unclassified_posts {

    my $start_record = shift;
    my $length = shift;
 
    my $sth = get_unclassified_posts($start_record, $length);
    my @records = extract_fields($sth);

    return @records;
 
}

sub fetch_all_posts {
 
    my $start_record = shift;
    my $length = shift;
 
    my $sth = get_all_posts($start_record, $length);
    my @records = extract_fields($sth);

    return @records;
    
}

sub extract_fields {

    my $sth = shift;
    my @records;

    while(my $ref = $sth->fetchrow_hashref()) {
        next if defined($ref->{topic_name});
        my $text = decode_utf8($ref->{text});
        $text =~ s/\x0d/ /g;
        $ref->{text} = simple($text);
        push @records, $ref;

    }

    return @records;

}

sub close_db {

    $dbh->disconnect();

}

END { close_db(); }

1;

