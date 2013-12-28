#!/usr/bin/perl

# use module
use XML::Simple;
use Data::Dumper;
use Encode;
use WWW::Mechanize;
use POSIX qw/strftime/;
use utf8;
#use encoding 'utf8', Filter => 1;

my $opml_dooc = $ARGV[0];
my $xml = new XML::Simple;

open FILE, "<:utf8", "$opml_dooc" or die $!;
my $content = '';
while (<FILE>) {
    $content .= $_ . "\n";
}

close FILE;

my $data = $xml->XMLin(encode_utf8($content));

my $mech = WWW::Mechanize->new();
$mech->agent_alias("Windows Mozilla");

my $output_dir = $ARGV[1];
my $output_file_prefix = $output_dir . "/"; 

$output_file_prefix .= strftime('%Y-%b-%d-%H-%M',localtime);

my $article_count = 1;

foreach $outline (@{$data->{body}->{outline}->{outline}}) {
    my $url = encode_utf8($outline->{xmlUrl});

    $mech->get($url);
    my $channel_data = $xml->XMLin(encode_utf8($mech->content()));

    my $output_file = $output_file_prefix . '-' . $article_count++ . ".txt";

    open FILE, ">", $output_file or die $!;
    print $output_file . "\n";
 
    foreach $news (@{$channel_data->{channel}->{item}}) {
        my $news_url = encode_utf8($news->{link});

        $mech->get($news_url);
        print FILE parse_news_content(encode_utf8($mech->content()));        

        sleep(5);

    }

    close FILE;
 
}

sub parse_news_content {

    my $html = shift;

    my $p = HTML::Parser->new( api_version => 3,
                           text_h => [sub { $main::text .= shift; }, "dtext"],
                           marked_sections => 1,
                         );  
 
    my $parsed_text = "";

    if ($html =~ /\<\!-- google_ad_section_start --\>(.*?)\<\!-- publish_helper_end --\>/s || $html =~ /\<div.*?articalContent.*?\>(.*?)\<div.*?shareUp.*?\>/s) {

        our $text = '';

        $p->parse($1);

        $text =~ s/\<\!--.*?--\>//sg;

        $parsed_text .= $text;
    }
    
    return $parsed_text;

}

exit;

