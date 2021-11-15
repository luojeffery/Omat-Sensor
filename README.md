# Omat-Sensor

This repo houses code for a 5 x 5 grid of resistive pressure sensors.
In order to run this code, first download this repository to your computer (Code > Download ZIP). Extract the ZIP file, and open `Omat-Sensor/omat_arduino/omat_arduino.ino` with the Arduino IDE. Connect the Arduino to your computer. Make sure to select the correct port (Tools > Port). Once that is done, upload and run the code. Wait a few seconds before opening and running `Omat-Sensor/omat_processing/omat_processing.pde`.

Now, there should be a popup window showing a grid of values. When pressure is applied to the pressure sensing mat, each grid square in the corresponding space where pressure was applied will light up in red with different intensities. Each square will display a value in the range [0, 255] corresponding to the amount of pressure that was applied to the pressure sensing mat. Every number represents the voltage values that are passed into the analog pins of the Arduino.

The Arduino sends serial data into a port in the computer, which triggers Processing's serialEvent(), from which we can display the locations and magnitudes of pressure.
