# Omat-Sensor

This repo houses code for a 5 x 5 grid of resistive pressure sensors.
In order to run this code, first connect the Arduino to the machine on which the sketches are running on. Make sure to select the correct port where the Arduino is connected inside the IDE where the Arduino sketch is in /omat_arduino. Once that is done, upload and run the code. Wait a few seconds and run the Processing file in /omat_processing. 

Now, there should be a popup window showing a grid of values. When pressure is applied to the pressure sensing mat, each grid square in the corresponding space where pressure was applied will light up in red with different intensities. 