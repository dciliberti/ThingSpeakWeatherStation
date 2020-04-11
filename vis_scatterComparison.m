% Read temperature and humidity from a ThingSpeak channel and visualize the 
% relationship between them using the SCATTER plot 

% Channel ID to read data from 
readChannelID = 000000; 
% Temperature Field ID 
TemperatureFieldID = 1; 
% Humidity Field ID 
HumidityFieldID = 2; 

% Channel Read API Key   
% If your channel is private, then enter the read API 
% Key between the '' below:   
readAPIKey = ''; 

% Read Temperature and Humidity Data. Learn more about the THINGSPEAKREAD function by 
% going to the Documentation tab on the right side pane of this page. 

data = thingSpeakRead(readChannelID,'Fields',[TemperatureFieldID HumidityFieldID], ...
                                               'NumDays',1, ...
                                               'ReadKey',readAPIKey); 

temperatureData = data(:,1);

% Read Humidity Data 
humidityData = data(:,2);

% Visualize the data
scatter(temperatureData,humidityData);
xlabel('Temperature');
ylabel('Humidity'); 