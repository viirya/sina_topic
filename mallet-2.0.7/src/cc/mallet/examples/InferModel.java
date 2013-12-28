package cc.mallet.examples;

import cc.mallet.util.*;
import cc.mallet.types.*;
import cc.mallet.pipe.*;
import cc.mallet.pipe.iterator.*;
import cc.mallet.topics.*;

import java.util.*;
import java.util.regex.*;
import java.io.*;

public class InferModel {

    ArrayList docIds = new ArrayList(); 

    String fileName;
    String encoding = "utf8";

    String inferencerFile;
    String docTopicsFile;

    int topN = 10000;
 
	public static void main(String[] args) throws Exception {


        if (args.length < 3) {
            System.out.println("Usage: InferModel inputFile inferencerFile outputFile <topN>");
            System.exit(0);
        }
 
        InferModel infermodel = new InferModel();
        infermodel.parseArgs(args);
        //infermodel.test();
        infermodel.doInference();
 
    }

    public void parseArgs(String[] args) {

        fileName = args[0];
        inferencerFile = args[1];
        docTopicsFile = args[2];

        if (args.length == 4) {
            topN = Integer.parseInt(args[3]);
        }
    }
 
    public void test() throws Exception {

            ParallelTopicModel model = ParallelTopicModel.read(new File(inferencerFile));
            TopicInferencer inferencer = model.getInferencer();

            ArrayList<Pipe> pipeList = new ArrayList<Pipe>();
            pipeList.add( new CharSequence2TokenSequence(Pattern.compile("\\p{L}\\p{L}+")) );
            pipeList.add( new TokenSequence2FeatureSequence() );
        
            InstanceList instances = new InstanceList(new SerialPipes(pipeList));
            Reader fileReader = new InputStreamReader(new FileInputStream(new File(fileName)), "UTF-8");
            instances.addThruPipe(new CsvIterator (fileReader, Pattern.compile("^(\\S*)[\\s,]*(\\S*)[\\s,]*(.*)$"),
                                                3, 2, 1)); // data, label, name fields
            double[] testProbabilities = inferencer.getSampledDistribution(instances.get(1), 10, 1, 5);
            for (int i = 0; i < 1000; i++)
                System.out.println(i + ": " + testProbabilities[i]);

    }
 
    public void doInference() {    

        try {

            ParallelTopicModel model = ParallelTopicModel.read(new File(inferencerFile));
            TopicInferencer inferencer = model.getInferencer();

            //TopicInferencer inferencer =
            //    TopicInferencer.read(new File(inferencerFile));

            //InstanceList testing = readFile();
            readFile();
            InstanceList testing = generateInstanceList(); //readFile();

            for (int i = 0; i < testing.size(); i++) {

                StringBuilder probabilities = new StringBuilder();
                double[] testProbabilities = inferencer.getSampledDistribution(testing.get(i), 10, 1, 5);

                ArrayList probabilityList = new ArrayList();

                for (int j = 0; j < testProbabilities.length; j++) {
                    probabilityList.add(new Pair<Integer, Double>(j, testProbabilities[j]));
                }

                Collections.sort(probabilityList, new CustomComparator());

                for (int j = 0; j < testProbabilities.length && j < topN; j++) {
                    if (j > 0)
                        probabilities.append(" ");
                    probabilities.append(((Pair<Integer, Double>)probabilityList.get(j)).getFirst().toString() + "," + ((Pair<Integer, Double>)probabilityList.get(j)).getSecond().toString());
                }

                System.out.println(docIds.get(i) + "," + probabilities.toString());
            }
 
    
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }

	}

    private InstanceList generateInstanceList() throws Exception {
 
        ArrayList<Pipe> pipeList = new ArrayList<Pipe>();
        pipeList.add( new CharSequence2TokenSequence(Pattern.compile("\\p{L}\\p{L}+")) );
        pipeList.add( new TokenSequence2FeatureSequence() );
 
        Reader fileReader = new InputStreamReader(new FileInputStream(new File(fileName)), "UTF-8");
        InstanceList instances = new InstanceList(new SerialPipes(pipeList));
        instances.addThruPipe(new CsvIterator (fileReader, Pattern.compile("^(\\S*)[\\s,]*(\\S*)[\\s,]*(.*)$"),
                                                3, 2, 1)); // data, label, name fields

        return instances;
    }

    private InstanceList readFile() throws IOException {

        String NL = System.getProperty("line.separator");
        Scanner scanner = new Scanner(new FileInputStream(fileName), encoding);

        ArrayList<Pipe> pipeList = new ArrayList<Pipe>();
        pipeList.add( new CharSequence2TokenSequence(Pattern.compile("\\p{L}\\p{L}+")) );
        pipeList.add( new TokenSequence2FeatureSequence() );
        
        InstanceList testing = new InstanceList(new SerialPipes(pipeList));

        try {
            while (scanner.hasNextLine()) {

                String text = scanner.nextLine();
                text = text.replaceAll("\\x0d", "");

                Pattern patten = Pattern.compile("^(.*?),(.*?),(.*)$");
                Matcher matcher = patten.matcher(text);

                if (matcher.find()) {
                    docIds.add(matcher.group(1));
                    testing.addThruPipe(new Instance(matcher.group(3), null, "test instance", null));
                }

            }
        }
        finally{
            scanner.close();
        }

        return testing;
    }

     class Pair<A, B> {

        private A first;
        private B second;
        
        public Pair(A first, B second) {
            this.first = first;
            this.second = second;
        }
        
        public String toString() {
               return "(" + first + ", " + second + ")"; 
        }
        
        public A getFirst() {
            return first;
        }
        
        public void setFirst(A first) {
            this.first = first;
        }
        
        public B getSecond() {
            return second;
        }
        
        public void setSecond(B second) {
            this.second = second;
        }
    }

    class CustomComparator implements Comparator<Pair<Integer, Double>> {
        @Override
        public int compare(Pair<Integer, Double> o1, Pair<Integer, Double> o2) {
            if (o1.getSecond() > o2.getSecond())
                return -1;
            else if (o1.getSecond() < o2.getSecond())
                return 1;
            else
                return 0;
        }
    } 
}

