/*
  A simple weather station broadcasting data on ThingSpeak with an ESP8266 micro-controller, a DHT22 and a BMP085 sensors.
  Reads temperature, relative humidity and pressure. Calculates dew point, heat index and comfort level.
  Weather forecast, alert and tweets are made on ThingSpeak. My channel is https://thingspeak.com/channels/665940
*/

#include "ThingSpeak.h"
#include "secrets.h"
#include <ESP8266WiFi.h>
#include "DHTesp.h"

// Your sketch must #include this library, and the Wire library.
// (Wire is a standard library included with Arduino.):

#include <SFE_BMP180.h>
#include <Wire.h>

// You will need to create an SFE_BMP180 object, here called "pressure":

SFE_BMP180 pressure;

#define ALTITUDE 125.0 // Altitude to calculate sea level barometric pressure in meters


char ssid[] = SECRET_SSID;   // your network SSID (name) 
char pass[] = SECRET_PASS;   // your network password
int keyIndex = 0;            // your network key Index number (needed only for WEP)
WiFiClient  client;

DHTesp dht;   // library optimized for ESP8266

unsigned long myChannelNumber = SECRET_CH_ID;
const char * myWriteAPIKey = SECRET_WRITE_APIKEY;

// Declare and initialize global variables
float temperature;
float humidity;
int seaLevelPressure;
float dewPoint;
float heatIndex;
float comfort;
byte perception;
int counter = 0;        // used to display header every 10 lines on the Serial Monitor
String myStatus = "";   // used to display device status on ThingSpeak


void setup() {
  Serial.begin(115200);  // Initialize serial
  Wire.begin(1,3);       // Use GPIO pins 1 and 3 for SDA and SCL

  WiFi.mode(WIFI_STA); 
  ThingSpeak.begin(client);  // Initialize ThingSpeak
  
  dht.setup(2, DHTesp::DHT22); // Connect DHT sensor to GPIO 2

  if (pressure.begin())
    Serial.println("BMP180 init success");
  else
  {
    // Oops, something went wrong, this is usually a connection problem,
    // see the comments at the top of this sketch for the proper connections.

    Serial.println("BMP180 init fail\n\n");
    while(1); // Pause forever.
  }
}


void loop() {

  // Connect or reconnect to WiFi
  if(WiFi.status() != WL_CONNECTED){
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(SECRET_SSID);
    while(WiFi.status() != WL_CONNECTED){
      WiFi.begin(ssid, pass);  // Connect to WPA/WPA2 network. Change this line if using open or WEP network
      Serial.print(".");
      delay(5000);     
    } 
    Serial.println("\nConnected.");
    
    Serial.println("Status\tHumidity (%)\tTemperature (C)\tHeatIndex (C)");
    counter = 0;
  }

  // get temperature and relative humidity
  humidity = dht.getHumidity();
  temperature = dht.getTemperature();

  // calculates dew point, heat index, comfort and perception level
  dewPoint = dht.computeDewPoint(temperature, humidity, false);
  heatIndex = dht.computeHeatIndex(temperature, humidity, false);
  // comfort = dht.getComfortRatio(temperature, humidity, false);
  perception = dht.computePerception(temperature, humidity, false);

  if (counter > 10){
    Serial.println("Status\tHumidity (%)\tTemperature (C)\tDew Point (C)\tHeatIndex (C)");
    counter = 0;
  }

  myStatus = dht.getStatusString();

  Serial.print(myStatus);
  Serial.print("\t");
  Serial.print(humidity, 1);
  Serial.print("\t\t");
  Serial.print(temperature, 1);
  Serial.print("\t\t");
  Serial.println(dewPoint, 1);
  Serial.print("\t\t");
  Serial.println(heatIndex, 1);


  // get pressure readings
  char status;
  double T,P,p0;  // variables used by pressure sensor
  
  Serial.println();
  Serial.print("provided altitude: ");
  Serial.print(ALTITUDE,0);
  Serial.print(" meters, ");
  Serial.print(ALTITUDE*3.28084,0);
  Serial.println(" feet");
  
  // Start a temperature measurement to enable pressure readings:
  // If request is successful, the number of ms to wait is returned.
  // If request is unsuccessful, 0 is returned.

  status = pressure.startTemperature();
  if (status != 0)
  {
    // Wait for the measurement to complete:
    delay(status);

    // Retrieve the completed temperature measurement:
    // Note that the measurement is stored in the variable T.
    // Function returns 1 if successful, 0 if failure.

    status = pressure.getTemperature(T);
    if (status != 0)
    {
      // Print out the measurement:
      Serial.print("temperature: ");
      Serial.print(T,2);
      Serial.print(" deg C, ");
      Serial.print((9.0/5.0)*T+32.0,2);
      Serial.println(" deg F");
      
      // Start a pressure measurement:
      // The parameter is the oversampling setting, from 0 to 3 (highest res, longest wait).
      // If request is successful, the number of ms to wait is returned.
      // If request is unsuccessful, 0 is returned.

      status = pressure.startPressure(3);
      if (status != 0)
      {
        // Wait for the measurement to complete:
        delay(status);

        // Retrieve the completed pressure measurement:
        // Note that the measurement is stored in the variable P.
        // Note also that the function requires the previous temperature measurement (T).
        // (If temperature is stable, you can do one temperature measurement for a number of pressure measurements.)
        // Function returns 1 if successful, 0 if failure.

        status = pressure.getPressure(P,T);
        if (status != 0)
        {
          // Print out the measurement:
          Serial.print("absolute pressure: ");
          Serial.print(P,2);
          Serial.print(" mb, ");
          Serial.print(P*0.0295333727,2);
          Serial.println(" inHg");

          // The pressure sensor returns abolute pressure, which varies with altitude.
          // To remove the effects of altitude, use the sealevel function and your current altitude.
          // This number is commonly used in weather reports.
          // Parameters: P = absolute pressure in mb, ALTITUDE = current altitude in m.
          // Result: p0 = sea-level compensated pressure in mb

          p0 = pressure.sealevel(P,ALTITUDE);
          Serial.print("relative (sea-level) pressure: ");
          Serial.print(p0,2);
          Serial.print(" mb, ");
          Serial.print(p0*0.0295333727,2);
          Serial.println(" inHg");
        }
        else Serial.println("error retrieving pressure measurement\n");
      }
      else Serial.println("error starting pressure measurement\n");
    }
    else Serial.println("error retrieving temperature measurement\n");
  }
  else Serial.println("error starting temperature measurement\n");

  // I need to cast sea level pressure from double to float (rounded to first decimal)
  // seaLevelPressure =  round(p0*10) / 10.0;
  seaLevelPressure =  round(p0);

  // set the fields with the values
  ThingSpeak.setField(1, temperature);
  ThingSpeak.setField(2, humidity);
  ThingSpeak.setField(3, seaLevelPressure);
  ThingSpeak.setField(4, dewPoint);
  ThingSpeak.setField(5, heatIndex);
  ThingSpeak.setField(6, perception);
  
  // set the status
  ThingSpeak.setStatus(myStatus);
  
  // write to the ThingSpeak channel (with at least 15 seconds delay between calls!)
  int x = ThingSpeak.writeFields(myChannelNumber, myWriteAPIKey);
  if(x == 200){
    // Serial.println("Channel update successful.");
  }
  else{
    Serial.println("Problem updating channel. HTTP error code " + String(x));
  }

  counter++;
  delay(10*60*1000); // Wait 10 minutes to update the channel again
}
