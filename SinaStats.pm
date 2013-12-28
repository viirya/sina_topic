
package SinaStats;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 0.01;
@ISA         = qw(Exporter);
@EXPORT      = qw(rank_users_posts_categories compute_users_posts_scores);
@EXPORT_OK   = qw(rank_users_posts_categories compute_users_posts_scores);

use DBI;
use XML::Simple;
use Data::Dumper;
use Encode;
use WWW::Mechanize;
use Encode;
use Encode::HanConvert qw(trad simple);
use POSIX qw/strftime/;
use utf8;


sub compute_users_posts_scores {

    my $posts = shift;
    my $repost_max = shift;
    my $comment_max = shift;

    my $user_scores = {};

    foreach my $uid (keys %{$posts}) {
        my $user_posts = $posts->{$uid};
        my $score_sum = {};
        my $topic_factors = {};

        foreach my $pid (keys %{$user_posts}) {
            my $post = $posts->{$uid}->{$pid};
            my $categories = $post->{categories};
            my $reposts = $post->{reposts} + 1;
            my $comments = $post->{comments} + 1;

            $repost_max += 1;
            $comment_max += 1;

            my $repost_ratio = log($reposts) / log($repost_max);
            my $comment_ratio = log($comments) / log($comment_max);

            my $post_score = (0.5 * $repost_ratio) + (0.5 * $comment_ratio);

            $post_score = 1 if $post_score > 1;

            my @categories;
            foreach my $category (@{$categories}) {
                my $topic_factor = $category->{topic_score}; #log(($category->{topic_score} + 1) * 10) / log (20);
                #next if $topic_factor < 0.2;
                my $cate = { topic_name => $category->{topic_name}, post_score => $post_score * $topic_factor};
                push @categories, $cate;

                #next if $cate->{post_score} == 0;
                
                $score_sum->{$category->{topic_name}} = () if !defined($score_sum->{$category->{topic_name}});
                push @{$score_sum->{$category->{topic_name}}}, $cate->{post_score};

                if (defined($topic_factors->{$category->{topic_name}})) {
                    $topic_factors->{$category->{topic_name}} = $topic_factors->{$category->{topic_name}} > $topic_factor ? $topic_factors->{$category->{topic_name}} : $topic_factor;
                } else {
                    $topic_factors->{$category->{topic_name}} = $topic_factor;
                }
            }
            $post->{scores} = \@categories;
        }

        #$posts->{$uid}->{user_score} = $score_sum / scalar(keys %{$user_posts})
        
        
        foreach my $topic_name (keys %{$score_sum}) {
            my $sum = 0;
            foreach my $score (@{$score_sum->{$topic_name}}) {
                $sum += $score;
            }
            $score_sum->{$topic_name} = (($sum * scalar(@{$score_sum->{$topic_name}})) / scalar(keys %{$user_posts})) * $topic_factors->{$topic_name}; #scalar(@{$score_sum->{$topic_name}});    
        }
        
        $user_scores->{$uid} = $score_sum;
    } 

    return $user_scores;
}

sub rank_users_posts_categories {

    my $posts = shift;
    my $topn = shift || 10;

    my $users = {};
    foreach my $uid (keys %{$posts}) {
        my $user_posts = $posts->{$uid};
        
        foreach my $post (@{$user_posts}) {
            my $pid = $post->{pid};
            my $ranked_categories = rank_post_categories($post->{categories});

            $users->{$uid}->{$pid}->{categories} = ();
            # foreach my $index (0..($topn - 1)) {
            foreach my $index (0..(scalar(@{$ranked_categories}) - 1)) {
                push @{$users->{$uid}->{$pid}->{categories}},  $ranked_categories->[$index];
            }

            $users->{$uid}->{$pid}->{reposts} = $post->{reposts};
            $users->{$uid}->{$pid}->{comments} = $post->{comments};
        }
    }

    return $users;

}

sub rank_post_categories {

    my $categories = shift;

    my @categories = sort { $b->{topic_score} <=> $a->{topic_score} } @{$categories};
    return \@categories;

}

1;

