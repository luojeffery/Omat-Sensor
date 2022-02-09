import processing.serial.*;
import processing.opengl.*;

/* SETTINGS */
int N = 5;  // number of rows/cols for the sensing array; [1-16]

int s;  // side length of each square, assuming width==height
int h;  // half the side length, so integer coordinates represent the centers of the squares
Serial port;
boolean firstContact = false;
int[] sensorReadings = new int[N*N];
int numSensorReadings = 0;
boolean render = false;
PrintWriter output;

void setup() {
  // set up the Processing canvas
  size(512, 512);
  rectMode(CENTER);
  textAlign(CENTER);
  textSize(32);
  s = width/N;
  h = s/2;
  // set up the serial port
  port = new Serial(this, Serial.list()[0], 115200);  // may need to change this
  output = createWriter("log.txt");
}

void draw() {
  background(0);
  if (render) {
    String line = month() + "/" + day() + "/" + year() + " " + 
                    hour() + ":" + minute() + ":" + second() + ":" + millis() + " "; // prepended timestamp
    for (int i = 0; i < N; ++i) {
      for (int j = 0; j < N; ++j) {
        float voltage = sensorReadings[i*N+j] * (5.0 / 255);
        fill(sensorReadings[i*N+j], 0, 0);  // Fill the next shape with variable intensity of red
        rect(i*s+h, j*s+h, s, s);  // Create a square of length s at this index
        fill(255);  // Fill the next shape with white
        text(String.format("%.2f", voltage), i*s+h, j*s+h);  // Display the sensor reading at this index
        line += String.format("%1$-3s", voltage + " "); // formats the sensor reading as a right-padded three digit number
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
