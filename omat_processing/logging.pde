import java.time.*;
import java.time.format.*;

public class Logger
{  
  private Measure measure;
  private PrintWriter output;
  private String line;
  private String workingDirectory = "C:\\dev\\_federick\\Omat-Sensor\\omat_processing\\";
  
  public Logger(Measure measure)
  {
    this.measure = measure;
    
    String filename; 
    if (measure == Measure.VOLTAGE)
      filename = "voltage";
    else
      filename = "resistance";
    filename += "-log_" + currentTimeF() + ".csv";
    
    String path = workingDirectory + "log" + File.separator + filename;
    output = createWriter(path);
    println(path);
  }
  
  public void log(float value)
  {
    if (measure == Measure.VOLTAGE)
      line += String.format("%1.3f", value) + ",";
    else
      line += String.format("%3.2f", value) + ",";
  }
  
  public void beginLine()
  {
    line = currentTime() + ","; 
  }
  
  public void endLine()
  {
    output.println(line);
    output.flush();
    line = "";
  }
  
  private String currentTime()
  {
    return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss:SSS"));
  }
  
  // return a string compatible with file names
  private String currentTimeF()
  {
    return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss"));
  } 
}
