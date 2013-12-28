#!/bin/bash

cd ~/repo/mallet-2.0.7
bin/mallet import-dir --input ~/repo/segmented_data/* --output sina.mallet --encoding utf8
bin/mallet train-classifier --input sina.mallet --output-classifier sina.classifier --trainer NaiveBayes

