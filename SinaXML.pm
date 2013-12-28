
package SinaXML;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 0.01;
@ISA         = qw(Exporter);
@EXPORT      = qw(parse_sina_opml parse_sina_xml);
@EXPORT_OK   = qw(parse_sina_opml parse_sina_xml);

use XML::Simple;
use Data::Dumper;
use Encode;
use WWW::Mechanize;
use POSIX qw/strftime/;
use utf8;

my $xml = new XML::Simple;
my $mech = WWW::Mechanize->new();
$mech->agent_alias("Windows Mozilla");

sub parse_sina_opml {

    my $content = shift;
    my $data = eval { $xml->XMLin(encode_utf8($content)) };
    if($@) {
        print "Error found in opml format.\n";
        return ();
    }

    my @return_articles;

    foreach my $outline (@{$data->{body}->{outline}->{outline}}) {

        my @articles = parse_sina_xml_url($outline->{xmlUrl});
        push @return_articles, join "\n", @articles if (@articles);
        
    }

    return @return_articles;

}

sub parse_sina_xml_url {

    my $url = shift;
    $url = encode_utf8($url);

    print "Parsing $url.\n";

    $mech->get($url);
    return parse_sina_xml($mech->content());

}

sub parse_sina_xml {
    
    my $content = shift;
    my $channel_data = eval { $xml->XMLin(encode_utf8($content)) };
    if($@) {
        print "Error found in parsing xml.\n";
        return ();
    }

    my @return_articles;
    foreach my $news (@{$channel_data->{channel}->{item}}) {

        my $news_url = encode_utf8($news->{link});
        $mech->get($news_url);

        push(@return_articles, parse_news_content(encode_utf8($mech->content())));        

        sleep(5);
    
    }

    return @return_articles;
 
}

sub parse_news_content {

    my $html = shift;

    my $p = HTML::Parser->new( api_version => 3,
                           text_h => [sub { $SinaXML::text .= shift; }, "dtext"],
                           marked_sections => 1,
                         );  
 
    my $parsed_text = "";

    if ($html =~ /\<\!-- google_ad_section_start --\>(.*?)\<\!-- publish_helper_end --\>/s || $html =~ /\<\!-- publish_helper .*? --\>(.*?)\<\!-- publish_helper_end --\>/s || $html =~ /\<div.*?articalContent.*?\>(.*?)\<div.*?shareUp.*?\>/s) {

        our $text = '';

        $p->parse($1);

        $text =~ s/\<\!--.*?--\>//sg;

        $parsed_text .= $text;
    }
    
    return $parsed_text;

}

1;

