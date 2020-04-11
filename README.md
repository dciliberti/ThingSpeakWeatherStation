# ThingSpeak Weather Station
A simple weather station broadcasting data on ThingSpeak with an ESP8266-01 micro-controller, a DHT22 and a BMP085 sensors. Reads temperature, relative humidity and pressure. Calculates dew point, heat index and comfort level. Weather forecast, alert and tweets are made on ThingSpeak.

My channel is on [https://thingspeak.com/channels/665940](https://thingspeak.com/channels/665940)

## Notes
The weather station will work with the specified hardware and a ThingSpeak account.

All MATLAB scripts are not necessary for the operations of the weather station. They are useful as example to perform data analysis and visualization on the data collected by the weather station and stored on ThingSpeak. Weather forecast calculation and tweet alerts are made with MATLAB.

### Nomenclature for MATLAB files:
- prefix `ana_` stands for script to be loaded into MATLAB Analysis App
- prefix `vis_` stands for script to be loaded into MATLAB Visualization App

### TODO
Describe how the logic of the ThingSpeak setup, where to put the MATLAB files, the auxiliary channel.
Add photo and description of the electronic circuits.