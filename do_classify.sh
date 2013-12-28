#!/bin/bash

prefix=posts_class_
suffix=$(date +%s)
filename=$prefix$suffix.txt

cd ~/repo/mallet-2.0.7
bin/mallet classify-file --input ~/repo/data/posts_seg.txt --output ~/repo/classify_data/$filename --classifier sina.classifier --encoding utf8 > /dev/null 2>&1

cd ~/repo
perl store_classified_posts.pl ~/repo/classify_data/$filename

