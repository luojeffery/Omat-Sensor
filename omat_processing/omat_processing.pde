import processing.serial.*;
import processing.opengl.*;

int n = 5;  // the size of the sensing grid
int s;  // side length of each square, assuming width==height
int h;  // half the side length, so integer coordinates represent the centers of the squares
Serial port;
boolean firstContact = false;
int[] sensorReadings = new int[n*n];
int numSensorReadings = 0;
boolean render = false;

void setup() {
  // set up the Processing canvas
  size(512, 512);
  rectMode(CENTER);
  textAlign(CENTER);
  textSize(32);
  s = width/n;
  h = s/2;
  // set up the serial port
  port = new Serial(this, Serial.list()[0], 115200);
}

void draw() {
  background(0);
  if (render) {
    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < n; ++j) {
        fill(sensorReadings[i*n+j], 0, 0); // Fill the next shape with variable intensity of red
        rect(i*s+h, j*s+h, s, s); // Creates a square of length s at this index
        fill(255); // FIll the next shape with white
        text(sensorReadings[i*n+j], i*s+h, j*s+h); // Display the sensor reading at this index
      }
    }
    
    render = false;
  }
  delay(100);
}

void serialEvent(Serial port) {
  int inByte = port.read();
  // establish contact the Arduino and Processing
  if (!firstContact) {
    if (inByte == 'A') {
      port.clear();
      firstContact = true;
      port.write('A');
    }
  } else {
    sensorReadings[numSensorReadings++] = inByte;
    // once we have all 5*5 individual readings, ask for new sensor readings
    if (numSensorReadings >= n*n) {
      port.write('A');
      numSensorReadings = 0;
      render = true;
    }
  }
}
