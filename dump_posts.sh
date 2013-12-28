#!/bin/bash

rm data/*

i=0
#for ((  i = 0 ;  i <= 50000;  i=i+10000  ))
while :
do
    perl dump_posts.pl $i 10000 data/posts_f$i.txt
    java -cp /home/viirya/repo/chinese_analyzer/dist/imdict.jar:/home/viirya/repo/chinese_analyzer/dist/lucene-core-2.4.1.jar:/home/viirya/repo/chinese_analyzer/dist/chineseanalyzer.jar org.viirya.lucene.analysis.tw.ChineseLineAnalyzer data/posts_f$i.txt > data/posts_f${i}_seg.txt
    if [ -s "data/posts_f${i}_seg.txt" ];
    then
        cat data/posts_f${i}_seg.txt >> data/posts_seg.txt
        let i=i+10000
    else
        rm data/posts_f$i.txt
        rm data/posts_f${i}_seg.txt
        exit $?
    fi
done

