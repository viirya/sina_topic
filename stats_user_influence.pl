#!/bin/perl

use Data::Dumper;
use Text::Iconv;
use Encode;
use SinaDB;
use SinaStats;

binmode STDOUT, ":utf8";

my $num_posts = get_posts_count();

my $all_user_scores = {};

for (my $i = 0; $i < $num_posts; $i += 1000) {

    print "post: $i ($num_posts)\n";

    my ($posts, $repost_max, $comment_max) = get_posts_all_users_in_range($i, 1000);

=begin
    my $count = 0;
    foreach my $uid (keys %{$posts}) {
        my $user_posts = $posts->{$uid}; 
        $count += scalar(@{$user_posts});
    }

    print "posts: $count\n";
=cut

    my $ranked_posts = rank_users_posts_categories($posts);

    undef $posts;

    my $user_scores = compute_users_posts_scores($ranked_posts, $repost_max, $comment_max);

    undef $ranked_posts;

    foreach my $uid (keys %{$user_scores}) {
        if (exists $all_user_scores->{$uid}) {
            foreach my $topic_name (keys %{$user_scores->{$uid}}) {
                if (exists $all_user_scores->{$uid}->{$topic_name}) {
                    $all_user_scores->{$uid}->{$topic_name} += $user_scores->{$uid}->{$topic_name};
                    $all_user_scores->{$uid}->{$topic_name} /= 2;
                } else {
                    $all_user_scores->{$uid}->{$topic_name} = $user_scores->{$uid}->{$topic_name};
                }
            }
        } else {
            $all_user_scores->{$uid} = $user_scores->{$uid};
        }
    }

}

foreach my $uid (keys %{$all_user_scores}) {
    foreach my $topic_name (keys %{$all_user_scores->{$uid}}) {
        post_user_influence($uid, $topic_name, $all_user_scores->{$uid}->{$topic_name});
    }
}

exit;

