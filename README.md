# Omat-Sensor

This repo houses code for a 5 x 5 grid of resistive pressure sensors.

Each grid square lights up with different intensities and displays a value in the range [0, 255] corresponding to the pressure at that location. The values represent how much voltage the Arduino's analog pins receive, as shown below:

![image](https://user-images.githubusercontent.com/67873222/142481914-89fea856-ecbf-4bec-9506-4303a3ed938e.png)

This code will log the data into a file in the `Omat-Sensor/omat_processing/` directory. Each line is prepended with a timestamp in `MM/DD/YY Hours:Minutes:Seconds:Milliseconds` format, and a snapshot of all the voltage values are displayed on that line, in row major order.

## How to Run

In order to run this code, first download this repository to your computer (Code > Download ZIP). Extract the ZIP file, and open `Omat-Sensor/omat_arduino/omat_arduino.ino` with the Arduino IDE. Connect the Arduino to your computer. Make sure to select the correct port (Tools > Port). Once that is done, upload and run the code.

Wait a few seconds before opening and running `Omat-Sensor/omat_processing/omat_processing.pde`. Now, there should be a popup window showing a grid of values. You should be able to see the grid light up when pressure is applied to the sensing array. 

<!---
The Arduino sends serial data into a port in the computer, which triggers Processing's serialEvent(), from which we can display the locations and magnitudes of pressure. 
--->
