import processing.serial.*;

enum Measure {NA, VOLTAGE, RESISTANCE};

/* SETTINGS */
final int N = 5;  // number of rows(==cols) for sensing array
final int SERIAL_PORT = 2;       // which serial port is the Arduino connected to?
final int SERIAL_BAUD = 115200;  // what is the baud rate of the serial port?
final float V_IN = 5;    // supply voltage (V)
final float R_RF = 1;    // reference resistance (kOhms)
final float R_TH = 100;  // threshold resistance (kOhms), consider anything above to be overload
Measure display = Measure.RESISTANCE;  // display voltage or resistance?

/* GLOBAL VARIABLES */
Serial port;
int numSensorReadings = 0;
int[]  sensorReadings = new int[N*N];
boolean firstContact = false;
boolean shouldRender = false;


void setup()
{
  size(960, 960);
  
  // interface configuration
  rectMode(CENTER);
  textAlign(CENTER);
  textSize(width/5/N);
  
  // serial port configuration
  printArray(Serial.list());
  port = new Serial(this, Serial.list()[SERIAL_PORT], SERIAL_BAUD);
}

void draw()
{
  if (!shouldRender) return;
  background(0);  // clear canvas
  
  int s = width/N;
  int h = s/2;
  
  for (int i = 0; i < N; ++i) {
  for (int j = 0; j < N; ++j) {
    // compute voltage and resistance
    float v_out = sensorReadings[i*N+j] * (V_IN / 255.0);
    float v_sensor = V_IN - v_out;
    float r_sensor = R_RF * v_sensor / v_out;
    
    // display in interface
    fill(sensorReadings[i*N+j], 0, 0);
    rect(i*s+h, j*s+h, s, s);
    fill(255);
    if (display == Measure.VOLTAGE) {
      text(String.format("%.2f V", v_sensor), i*s+h, j*s+h);
    }
    else if (display == Measure.RESISTANCE) {
      if (r_sensor > R_TH)
        text("OL", i*s+h, j*s+h);
      else
        text(String.format("%.2f k\u2126", r_sensor), i*s+h, j*s+h);
    }
  }
  }
  shouldRender = false;
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
      return;
    }
  }

  sensorReadings[numSensorReadings++] = inByte;
  
  // once we have all N*N individual readings, ask for new sensor readings
  if (numSensorReadings == N*N) {
    printArray(sensorReadings);
    shouldRender = true;
    port.write('A');
    numSensorReadings = 0;
  }
}

void keyPressed()
{
  swapMeasurement();
}

void swapMeasurement()
{
  if      (display == Measure.VOLTAGE)    display = Measure.RESISTANCE;
  else if (display == Measure.RESISTANCE) display = Measure.VOLTAGE;
}
