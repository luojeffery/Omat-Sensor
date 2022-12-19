/** NOTE:
 *  "input" and "output" are relative to the arudino:
 *  "input"  refers to   (mux)   -> (arduino) 
 *  "output" refers to (arduino) ->  (demux)
 **/

/* SETTINGS */
const int N = 1;  // number of rows/cols for the sensing array; [1-16]

/* control pins */
// output selector pins ['w' for "write"]
const byte w0 = 3; 
const byte w1 = 4;
const byte w2 = 5;
const byte w3 = 6;
const byte writeSelector[] = {w0, w1, w2, w3};  // array of selector pins for demux we write to
// input  selector pins ['r' for "read"]
const byte r0 = A0;  ////////////////////////////////////////
const byte r1 = A1;  // NOTE: here we use the analog input //
const byte r2 = A2;  // pins A1-A4 as digital output pins  //
const byte r3 = A3;  ////////////////////////////////////////
const byte readSelector[] = {r0, r1, r2, r3};  // array of selector pins for mux we read from

/* signal pins */
const byte out = 7;  // output signal pin
const byte  in = A4;  //  input signal pin
const byte green_led = 8;
const byte red_led = 9;

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

int minReading = 0;     // the minimum reading of the sensor
int maxReading = 1023;  // the maximum reading of the sensor
int inByte = 0;   // the byte to receive from Processing through the serial port
int outByte = 0;  // the byte to send to Processing through the serial port

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

  pinMode(green_led, OUTPUT);
  pinMode(red_led, OUTPUT);

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
  digitalWrite(green_led, HIGH);
  digitalWrite(red_led, HIGH);

/* Begin connecting to Processing */
  Serial.begin(115200);
  establishContact();

  digitalWrite(red_led, LOW);
}

void loop() {
  if (Serial.available() > 0) {
    inByte = Serial.read();
    if (inByte == 'A') {
      for (int i = 0; i < N; ++i) {
        writeToDemux(i);
        for (int j = 0; j < N; ++j) {
          int reading = readFromMux(j);
          // clamp the sensor value to the range [minReading, maxReading]
          /*
          if (reading > maxReading) {
            out = maxReading;
          } else if (outByte < minReading) {
            outByte = minReading;
          }
          */
          // scale the sensor value from 10 bits to 8 bits
          outByte = map(readFromMux(j), minReading, maxReading, 0, 255);
          // send to Processing
          Serial.write(outByte);
          digitalWrite(red_led, !digitalRead(red_led));
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

// establish contact with Processing
void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');  // send a capital A
    delay(250);
  }
}
