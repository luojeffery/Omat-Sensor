/** NOTE:
 *  "input" and "output" are relative to the arudino:
 *  "input"  refers to   (mux)   -> (arduino) 
 *  "output" refers to (arduino) ->  (demux)
 **/

/* control pins */
// output selector pins ['w' for "write"]
const byte w0 = 6; 
const byte w1 = 5;
const byte w2 = 4;
const byte w3 = 3;
const byte writeSelector[] = {w0, w1, w2, w3};  // array of selector pins for demux we write to
// input  selector pins ['r' for "read"]
const byte r0 = A4;  ////////////////////////////////////////
const byte r1 = A3;  // NOTE: here we use the analog input //
const byte r2 = A2;  // pins A1-A4 as digital output pins  //
const byte r3 = A1;  ////////////////////////////////////////
const byte readSelector[] = {r0, r1, r2, r3};  // array of selector pins for mux we read from

/* signal pins */
const byte out = 2;  // output signal pin
const byte in = 0;  // input  signal pin

/* selector bits for each channel of mux/demux */
const boolean channelSelector[16][4] = {
  {0,0,0,0},  // channel 0
  {1,0,0,0},  // channel 1
  {0,1,0,0},  // channel 2
  {1,1,0,0},  // channel 3
  {0,0,1,0},  // channel 4
  {1,0,1,0},  // channel 5
  {0,1,1,0},  // channel 6
  {1,1,1,0},  // channel 7
  {0,0,0,1},  // channel 8
  {1,0,0,1},  // channel 9
  {0,1,0,1},  // channel 10
  {1,1,0,1},  // channel 11
  {0,0,1,1},  // channel 12
  {1,0,1,1},  // channel 13
  {0,1,1,1},  // channel 14
  {1,1,1,1},  // channel 15
};

int minReading = 255;  // the minimum reading of the sensor
int minCalibration[5][5];  // stores the minimum value for each of the 16*16 sensors.
int maxReading = 1023;  // the maximum reading of the sensor; set to 0 if calibration of the maximum value is implemented.
// int maxCalibration[5][5];  // stores the maximum value for each of the 16*16 sensors.
int inByte = 0;
int outByte = 0;

void setup() {
/* configure control pins */
  pinMode(w0, OUTPUT);
  pinMode(w1, OUTPUT);
  pinMode(w2, OUTPUT);
  pinMode(w3, OUTPUT);
  pinMode(r0, OUTPUT);
  pinMode(r1, OUTPUT);
  pinMode(r2, OUTPUT);
  pinMode(r3, OUTPUT);

/* configure signal pins */
  pinMode(out, OUTPUT);
  // analog input pins (A0-A5) only input analog signals; no need to set pinMode() for them

/* initialize input and output control pins to channel 0 */
  digitalWrite(w0, LOW);
  digitalWrite(w1, LOW);
  digitalWrite(w2, LOW);
  digitalWrite(w3, LOW);
  digitalWrite(r0, LOW);
  digitalWrite(r1, LOW);
  digitalWrite(r2, LOW);
  digitalWrite(r3, LOW);
/* output signal pin will always be HIGH */
  digitalWrite(out, HIGH);

  Serial.begin(115200);
  Serial.println("Calibrating...");

/* calibration process */
  // initialize the calibration array to 0s
  for (int i = 0; i < 5; ++i) {
    writeToDemux(i);
    for (int j = 0; j < 5; ++j) {
      minCalibration[i][j] = 0;
    }
  }
  // take the average over 50 readings and calculate the minimum reading
  for (int k = 0; k < 50; ++k) {
    for (int i = 0; i < 5; ++i) {
      writeToDemux(i);
      for (int j = 0; j < 5; ++j) {
        minCalibration[i][j] += readFromMux(j);
      }
    }
  }
  for (int i = 0; i < 5; ++i) {
    for (int j = 0; j < 5; ++j) {
      if (minCalibration[i][j] < minReading) {
        minReading = minCalibration[i][j];
      }
      // print the average minimum readings
      Serial.print(minCalibration[i][j]);
      Serial.print("\t");
    }
    Serial.println();
  }

  Serial.println();
  Serial.print("Minimum value: ");
  Serial.print(minReading);
  Serial.println();

  establishContact();
}

void loop() {
  // put your main code here, to run repeatedly:
  if (Serial.available() > 0) {
    inByte = Serial.read();
    if (inByte == 'A') {
      for (int i = 0; i < 5; ++i) {
        writeToDemux(i);
        for (int j = 0; j < 5; ++j) {
          outByte = readFromMux(j);
          // clamp the sensor value to the range [minReading, maxReading]
          if (outByte > maxReading) {
            outByte = maxReading;
          } else if (outByte < minReading) {
            outByte = minReading;
          }
          // scale the sensor value from 10 bits to 8 bits
          outByte = map(readFromMux(j), minReading, maxReading, 0, 255);
          // send to processing
          Serial.write(outByte);
        }
      }
    }
  }
}

// write HIGH to selected demux channel
void writeToDemux(byte channel) {
  for (int i = 0; i < 4; ++i) {
    digitalWrite(writeSelector[i], channelSelector[channel][i]);
  }
  // output pin is always on HIGH, so no need to use digitalWrite()
}

// read input from selected mux channel
int readFromMux(byte channel) {
  for (int i = 0; i < 4; ++i) {
    digitalWrite(readSelector[i], channelSelector[channel][i]);
  }
  return analogRead(in);
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');  // send a capital A
    delay(250);
  }
}
