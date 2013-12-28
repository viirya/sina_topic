# Sina post classification tools

This project includes the tools used to classify sina posts and prepare corpus for training.

## Training

### Crawl and parse corpus from sina news 

    ./parse_sina_news.sh

### Simplified Chinese word segmentation

    ./word_segment.sh

### Training classifier

    ./do_trainning.sh
  

## Classification

### Dump unclassified posts from DB

    ./dump_posts.sh

### Perform classification

    ./do_classify.sh


## Computing user influence scores by topic

    ./compute_user_influence.sh



## Usage

1. Check out this github repo.  
2. `mkdir data; mkdir raw_data; mkdir segmented_data; mkdir classify_data`  
3. Training classifier  

        ./parse_sina_news.sh  
        ./word_segment.sh  
        ./do_trainning.sh  
      
4. Classifying sina posts  

        ./dump_posts.sh  
        ./do_classify.sh 

5. Computing influence scores for users

        ./compute_user_influence.sh

5. Set dump_posts.sh, do_classify.sh, compute_user_influence.sh as cronjobs to regularly classify new posts

The above process will dump new and unclassified posts from DB and insert classification results back into DB.
When new classifiers are added, since olders posts are classified, those posts will not be dumped to classify using new classifiers.
If it is needed to classify older posts using new classifiers, please use the tools described below.
  
  
# Data tools 

## Dump unclassified sina posts from database

This tool will dump unclassified sina posts from DB. When new classifiers are added, since there are previous classification results in DB, those posts classified will not be dumped if the last argument is not set to "yes". 

Usage:

    perl dump_posts.pl [start] [length] [output file] [dump all posts]

For example:

    perl dump_posts.pl 0 10000 posts_f0.txt no

    perl dump_posts.pl 0 10000 posts_f0.txt yes
 

## Crawl training corpus from sina news

### OPML documents

OPML documents of Sina news are stored in sina_opml/opml.

Usage:

    perl parse_sina_news_opml.pl [opml file] [output directory]

For example:

    perl parse_sina_news_opml.pl sina_opml/opml/sina_ent_opml.xml raw_data

### XML documents

XML documents of Sina news are stored in sina_opml/xml.

Usage:

    perl parse_sina_news_xml.pl [xml file] [output directory]

For example:

    perl parse_sina_news_xml.pl sina_opml/xml/sina_ent.xml raw_data
 
The above command parses news from the entertainment (ent) channel of Sina news and stores results in the directory raw/data/sina_ent_xml. Parsed text documents are stored by using current datetime as filenames.

## Chinese word segmentation

Segment Simplified Chinese documents.

Usage:

    perl word_segment.pl [input directory] [output directory]

    perl word_segment.pl raw_data/ent segmented_data

The above command segments all documents stored in raw_data/ent and stores results in segmented_data/ent.

## Import training data

Usage:
    
    cd mallet-2.0.7   
    bin/mallet import-dir --input [input directory] --output [output data file] --encoding utf8

For example:

    cd mallet-2.0.7        
    bin/mallet import-dir --input segmented_data/* --output sina.mallet --encoding utf8
 
## Training classifiers

Usage:

    cd mallet-2.0.7        
    bin/mallet train-classifier --input sina.mallet --output-classifier sina.classifier \--trainer NaiveBayes

For example:

    cd mallet-2.0.7          
    bin/mallet train-classifier --input [input data file] --output-classifier [classifier] \--trainer NaiveBayes

## Predict data 

A line is an example:

    cd mallet-2.0.7        
    bin/mallet classify-file --input [post file] --output [classification results] --classifier [classifier] --encoding utf8
    
A file is an example:

    cd mallet-2.0.7
    bin/mallet classify-dir --input [post directory] --output [classification result] --classifier [classifier] --encoding utf8

## Store classification results
  
    perl store_classified_posts.pl [classification results]  
    
    
# How to add new classifier

To add new classifier, you need to prepare data corpus for the classifier, segment the corpus and train the classifier.

## Prepare data corpus

* OPML/XML from sina

  1. Retrieve OPML/XML from Sina and put in sina_opml/opml/ or sina_opml/xml

  2. Parse it

            perl parse_sina_news_opml.pl sina_opml/opml/sina_ent_opml.xml raw_data          
        OR    
    
            perl parse_sina_news_xml.pl sina_opml/xml/sina_ent.xml raw_data
        
      
  3. Segment it

            perl word_segment.pl raw_data/sina_ent_opml segmented_data        
      
  4. Import new corpus

    
            cd mallet-2.0.7        
            bin/mallet import-dir --input segmented_data/* --output sina.mallet --encoding utf8
      
  5. Train classifier

            cd mallet-2.0.7          
            bin/mallet train-classifier --input [input data file] --output-classifier [classifier] \--trainer NaiveBayes

* Other data resources
  
  1. Retrieve data and put in raw_data/[data resource name]/[document id]

  2. Segment, import and train the data as the 3th, 4th and 5th steps above.

