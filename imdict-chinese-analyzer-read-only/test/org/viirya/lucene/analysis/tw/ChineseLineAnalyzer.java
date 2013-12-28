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

public class ChineseLineAnalyzer {

    public static void main(String[] args) throws IOException {

        if (args.length > 0) {
            String fileName = args[0];
            String encoding = "utf8";

            if (args.length > 1)
                encoding = args[1];

            ChineseLineAnalyzer analyzer = new ChineseLineAnalyzer();

            analyzer.readFile(fileName, encoding);
        
        } else {
            System.out.println("Usage: java ChineseLineAnalyzer [text file]");
        }
        
    }

    private void readFile(String fFileName, String fEncoding) throws IOException {

        String NL = System.getProperty("line.separator");
        Scanner scanner = new Scanner(new FileInputStream(fFileName), fEncoding);

        try {
            while (scanner.hasNextLine()){
                String text = scanner.nextLine() + NL;

                text = text.replaceAll("\\x0d", "");
                
                Pattern patten = Pattern.compile("^(.*?),(.*?),(.*)$");
                Matcher matcher = patten.matcher(text);

                if (matcher.find()) {
                    System.out.println(matcher.group(1) + ",," + analyze(matcher.group(3)));
                }
            }
        }
        finally{
            scanner.close();
        }

    }

    private String analyze(String content) throws UnsupportedEncodingException, FileNotFoundException, IOException {
        StringBuilder text = new StringBuilder();
        Token nt = new Token();
        Analyzer ca = new SmartChineseAnalyzer(true);
        Reader sentence = new StringReader(content);
        TokenStream ts = ca.tokenStream("sentence", sentence);

        nt = ts.next(nt);
        while (nt != null) {

            Pattern patten = Pattern.compile("^[,\\w\\s]*$");
            Matcher matcher = patten.matcher(nt.term());

            if (!matcher.find()) {
                text.append(nt.term());
            }

            nt = ts.next(nt);
            if (nt != null)
                text.append(" ");
        }
        ts.close();
        return text.toString();
    }
}
