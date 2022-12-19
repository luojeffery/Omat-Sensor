# Omat-Sensor

> ## Table of Conents
> 1. [Introduction](#introduction)
> 1. [Demo](#demo)
> 1. [Details](#details)
> 1. [How to Run](#how-to-run)
> 1. [References](#references)

## Introduction

The O-mat sensor is designed to support flexible and scalable pressure sensors. Using our circuit and code, you can plug in a sensing grid and get a visual representation and log of recorded voltages and resistances.

<p align="middle">
    <img src="res/circuit1.jpg" width="250px">
    <img src="res/circuit2.jpg" width="250px">
    <img src="res/grid1.jpg" width="250px">
</p>

<br>

## Demo

<p align="middle">
    <img src="res/demo1.jpg" width="250px">
    <img src="res/demo2.jpg" width="250px">
    <img src="res/demo3.jpg" width="250px">
</p>

<br>

## Details

The voltage displayed on each grid point is the voltage across each intersection point between the rows and columns. According to our testing, the margin of error from a multimeter reading is &#xB1;0.5V, so keep that in mind if you are using the O-mat sensor for measurement-sensitive applications. Also note that resistance is calculated directly from the voltage reading with respect to a reference resistor, which in our case is 1000&#8486;. Set the `R_RF` variable in Processing if you are using a different reference resistance.

### Logging

Logs are stored at `Omat-Sensor/omat_processing/logs/`. Voltage logs are stored as `voltage-log_XXX.csv` and resistance logs are stored as `resistance-log_XXX.csv`, where `XXX` is the starting timestamp of the log in `YEAR-MONTH-DAY_HOUR-MINUTE-SECOND` format.

The formatting can be adjusted in `logging.pde`, by changing the variables `TIME_FMT` and `TIME_FMT_F` according to Java's [DateTimeFormatter](https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html). By default, the times recorded inside the logs are in `HOUR:MINUTE:SECOND.MILLISECOND` format.

The matrix of readings needs to be converted to a vector when logged, so the first reading corresponds to row `1`, column `1`, the second reading corresponds to row `1`, column `2`, and so on. In general, if you have `N` rows/columns, the reading at row `i`, column `j` will be the `(N*(i-1) + (j-1) + 1)`-th reading in the log.

## How to Run

### Building the Circuit

Our design is modified slightly from the original (which you can find [here](https://www.instructables.com/O-mat/)), but we include a diagram nonetheless. You can use the images above to help you wire the circuit compactly.

[](res/circuit.png)

### Configuring the Code

Once you have the circuit and sensing grid ready, clone or download this repository to your computer (Code > Download ZIP). Extract the ZIP file. Open the Arduino and Processing files inside the extracted `Omat-Sensor/` folder:
* `omat_arduino/omat_arduino.ino` (using the [Arduino IDE](https://www.arduino.cc/en/software))
* `omat_processing/omat_processing.pde` (using [Processing](https://processing.org/download))

**Before doing anything else,** change the variable `N` in both  files to the number of rows/columns in your sensor. Currently, we only support square grids; i.e. # rows = # columns.

Connect the Arduino to your computer, and in the Arduino IDE, select the port (Tools > Port) that your Arudino is connected to; it is the one that looks like `COM# (Arduino Uno)`. Remember the `COM#`. Once that is done, upload the code to the Arduino board.

Now switch over to Processing and run the code. If the grid window appears shows up and starts updating, it works, and you can see the real-time visualization and check the logs! However, if it comes up blank or an error pops up, you should check the terminal output at the bottom of the Processing code window. It prints out a list of serial ports in the format `[#] "COM#"`. Change the `SERIAL_PORT` variable at the top to the `#` that matches your `COM#`. Re-run the code, and it should work.

```
Warning: Clicking the stop button on Processing causes the serial connection to unexpectedly terminate. Unplug and replug the USB cable to make sure the readings are aligned to the grid.
```

## References

* [Original O-mat design](https://www.instructables.com/O-mat/)

<!---
The Arduino sends serial data into a port in the computer, which triggers Processing's serialEvent(), from which we can display the locations and magnitudes of pressure. 
--->
