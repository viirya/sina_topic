/**
 */

package org.viirya.lucene.analysis.tw;

import java.io.*;
import java.util.Date;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.Token;
import org.apache.lucene.analysis.TokenStream;

import org.apache.lucene.analysis.cn.*;

public class ChineseAnalyzer {

    public static void main(String[] args) throws IOException {

        if (args.length > 0) {
            String fileName = args[0];
            String encoding = "utf8";

            if (args.length > 1)
                encoding = args[1];

            ChineseAnalyzer analyzer = new ChineseAnalyzer();

            String content = analyzer.readFile(fileName, encoding);
            analyzer.analyze(content);
 
        
        } else {
            System.out.println("Usage: java ChineseAnalyzer [text file]");
        }
        
    }

    private String readFile(String fFileName, String fEncoding) throws IOException {

        StringBuilder text = new StringBuilder();
        String NL = System.getProperty("line.separator");
        Scanner scanner = new Scanner(new FileInputStream(fFileName), fEncoding);

        try {
          while (scanner.hasNextLine()) {

            String line = scanner.nextLine() + NL;
            line = line.replaceAll("\\x0d", "");

            text.append(line);
          }
        }
        finally{
          scanner.close();
        }

        return text.toString();

    }

    private void analyze(String content) throws UnsupportedEncodingException, FileNotFoundException, IOException {
        Token nt = new Token();
        Analyzer ca = new SmartChineseAnalyzer(true);
        Reader sentence = new StringReader(content);
        TokenStream ts = ca.tokenStream("sentence", sentence);
        
        //System.out.println("start: " + (new Date()));
        long before = System.currentTimeMillis();
        nt = ts.next(nt);
        while (nt != null) {

            Pattern patten = Pattern.compile("^[,\\w\\s]*$");
            Matcher matcher = patten.matcher(nt.term());

            if (!matcher.find()) {
                System.out.println(nt.term());
            }

            nt = ts.next(nt);
        }
        ts.close();
        long now = System.currentTimeMillis();
        //System.out.println("time: " + (now - before) / 1000.0 + " s");
    }
}
