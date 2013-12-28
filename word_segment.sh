#!/bin/bash

DATADIR=./raw_data
DIRS=`ls -l $DATADIR | egrep '^d' | awk '{print $9}'`

for DIR in $DIRS
do
    perl word_segment.pl $DATADIR/$DIR segmented_data
done 
