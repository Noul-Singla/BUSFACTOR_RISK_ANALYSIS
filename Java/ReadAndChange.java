import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ReadAndChange {
	
	private static String outputFolder = "C:\\DS6050\\Processed\\";
	public static int count = 0;
	
    private static void readFolder(String fileName) {
        File folder = new File(fileName);
        File[] listOfFiles = folder.listFiles();

        for (File file : listOfFiles) {
            if (file.isFile()) {
                readFiles(file.getName());
            }
        }
    }


    private static void readFiles(String inputFileName) {
        BufferedReader br = null;
        FileReader fr = null;
		String header = "";
        List<String> commits = new ArrayList<>();

        String pattern = "[^\\S ]";
        Pattern r = Pattern.compile(pattern);

        try {

            fr = new FileReader("C:\\DS6050\\Process\\" + inputFileName);
            br = new BufferedReader(fr);

            String sCurrentLine;

            while ((sCurrentLine = br.readLine()) != null) {
                if (sCurrentLine.length() == 0) {
                    process(header, commits, inputFileName);
                    header = "";
                    commits.clear();
                }
                Matcher m = r.matcher(sCurrentLine);

                if (m.find()) {
                    commits.add(sCurrentLine);
                } else {
                    header = sCurrentLine;
                }
            }
			count++;
			System.out.print(count);
			System.out.println(" " + inputFileName);

        } catch (IOException e) {

            e.printStackTrace();

        } finally {

            try {

                if (br != null)
                    br.close();

                if (fr != null)
                    fr.close();

            } catch (IOException ex) {

                ex.printStackTrace();

            }

        }
    }

    private static void process(String header, List<String> commits, String outputFileName) {
        BufferedWriter bw = null;
        FileWriter fw = null;

        File f = new File(outputFolder + outputFileName);

        try {

            fw = new FileWriter(outputFolder + outputFileName, true);
            bw = new BufferedWriter(fw);
			int temp_cnt = 0;

            for (String commit : commits) {
				temp_cnt = commit.indexOf("\t",commit.indexOf("\t")+1);
				temp_cnt = (temp_cnt==-1)?commit.length():temp_cnt;
                bw.write( f.getName().replace(".list","") + "," + header + "," + commit.replace("\t",",").substring(0,temp_cnt) +  "\n");
            }

        } catch (IOException e) {

            e.printStackTrace();

        } finally {

            try {

                if (bw != null)
                    bw.close();

                if (fw != null)
                    fw.close();

            } catch (IOException ex) {

                ex.printStackTrace();

            }

        }
    }

    public static void main(String[] args) {
        readFolder("C:\\DS6050\\Process");

    }
}
