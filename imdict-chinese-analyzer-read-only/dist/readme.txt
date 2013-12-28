

The word segmentation program for Simplified Chinese implemented using Java.

Usage:

Showing one tem a line:

java -cp ./imdict.jar:./lucene-core-2.4.1.jar:./chineseanalyzer.jar org.viirya.lucene.analysis.tw.ChineseAnalyzer [text file]

Show all terms of a document a line:
 
java -cp ./imdict.jar:./lucene-core-2.4.1.jar:./chineseanalyzer.jar org.viirya.lucene.analysis.tw.ChineseLineAnalyzer [text file]
 
