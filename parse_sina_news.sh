#!/bin/bash

FILES=./sina_opml/opml/*.xml
for f in $FILES
do
    perl parse_sina_news_opml.pl $f raw_data
done

FILES=./sina_opml/xml/*.xml
for f in $FILES
do
    perl parse_sina_news_xml.pl $f raw_data
done


