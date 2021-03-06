import processing.serial.*;
import processing.opengl.*;
import java.util.*;

/* SETTINGS */
int N = 5;  // number of rows/cols for the sensing array; [1-16]

int s;  // side length of each square, assuming width==height
int h;  // half the side length, so integer coordinates represent the centers of the squares
Serial port;
Serial force_port;
boolean firstContact = false;
int[] sensorReadings = new int[N*N];
int numSensorReadings = 0;
boolean render = false;
PrintWriter output;

String filename = "log_resistance";
String file_time = " " + month() + "-" + day() + "-" + year() + " " + hour() + "-" + minute() + "-" + second();
String full_name = "log" + File.separator + filename + file_time + ".csv";


void setup() {
  // set up the Processing canvas
  size(900, 900);
  rectMode(CENTER);
  textAlign(CENTER);
  textSize(32);
  s = width/N;
  h = s/2;
  // set up the serial port
  port = new Serial(this, Serial.list()[0], 115200);
  // force_port = new Serial(this, Serial.list()[1],115200); 
  printArray(Serial.list());

  
  output = createWriter(full_name);
  
  println(full_name);
}
void draw() {
  background(0);
  if (render) {
    String line = month() + "/" + day() + "/" + year() + " " +
                    hour() + ":" + minute() + ":" + second() + ":" + millis() + " "; // prepended timestamp
    for (int i = 0; i < N; ++i) {
      for (int j = 0; j < N; ++j) {
        try {
          // force_port.write("?\r");
          // String forces = force_port.readString();
          // println(forces);
        }
        catch (Exception e) {
          println("Serial Port Exception.");
          e.printStackTrace();
        }
        float voltage = sensorReadings[i*N+j] * (5.0 / 255);
        float resistance = ((5.0 / voltage) - 1.0); // resistance is in kiloohms
        fill(sensorReadings[i*N+j], 0, 0);  // Fill the next shape with variable intensity of red
        rect(i*s+h, j*s+h, s, s);  // Create a square of length s at this index
        fill(255);  // Fill the next shape with white
        if (Float.isInfinite(resistance))
          text("Inf k\u2126", i*s+h, j*s+h);
        else {
        //%.2fk\u2126
          text(String.format("%.2fk\u2126", resistance), i*s+h, j*s+h);  // Display the sensor reading at this index
        //line += String.format("%1$-3s", 1000 * resistance + ","); // formats the sensor reading as a right-padded three digit number
        }
      }
    }
    output.println(line);
    output.flush();
    render = false;
  }
  delay(100);
}

void serialEvent(Serial port) {
  int inByte = port.read();
  // establish contact with the Arduino
  if (!firstContact) {
    if (inByte == 'A') {
      port.clear();
      firstContact = true;
      port.write('A');
    }
  } else {
    sensorReadings[numSensorReadings++] = inByte;
    // once we have all N*N individual readings, ask for new sensor readings
    if (numSensorReadings >= N*N) {
      port.write('A');
      numSensorReadings = 0;
      render = true;
    }
  }
}

void stop() {
  output.close();
}
