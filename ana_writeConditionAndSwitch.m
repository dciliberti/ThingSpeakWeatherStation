% A very simple algorithm to perform local weather forecast. It is based on
% the readings of pressure and relative humidity.
% Source (in italian): https://www.meteogiuliacci.it/meteo/articoli/analisi/prevedere-il-tempo-mediante-la-pressione
% Read from the main channel and write to the support channel (to avoid
% timestamps duplicate or superpositioning, hence avoiding NaNs)

% Channel ID to read data from
ChannelIDRead = 000000; % replace 000000 with your public Channel ID
% Pressure and humidity field ID
pressureID = 3;
humidityID = 2;

% Channel Read API Key
% If your channel is private, then enter the read API
% Key between the '' below:
readAPIKeyStation = 'myReadAPIkey';  % replace myReadAPIkey with yours

% Aux channel Write API. Used later to REACT only at pressure change
ChannelIDWrite = 000000; % replace 000000 with your aux Channel ID
readAPIKeyAppo = 'myReadAPIkeyAppo';  % replace myReadAPIkeyAppo with yours (aux)
writeAPIKeyAppo = 'myWriteAPIkey§Appo';  % replace myWriteAPIkeyAppo with yours (aux)

% Read pressure data in the last 3 hours
pressureData = thingSpeakRead(ChannelIDRead,'Fields',pressureID, ...
    'NumMinutes', 180, 'ReadKey', readAPIKeyStation);
avgPressure = mean(pressureData,'omitnan');

% Read pressure data in the last 3 hours
humidityData = thingSpeakRead(ChannelIDRead,'Fields',humidityID, ...
    'NumMinutes', 180, 'ReadKey', readAPIKeyStation);
avgHumidity = mean(humidityData,'omitnan');

% We are only interested in pressure difference
% pressureChange = pressureData(end) - pressureData(1);

% linear regression
x = (1:numel(pressureData))';
X = [ones(numel(x),1) , x];
y = pressureData;
b = X\y;
array = X*b;
pressureChange = array(end) - array(1);

%% Perform weather forecast. Pressure readings in mbar (or hPa)
if pressureChange < -6
    conditionNumber = 1;
    % message = 'a thuderstorm is coming (or worsening)';
    
elseif pressureChange >= -6 && pressureChange < -2
    conditionNumber = 2;
    % message = 'weather worsen in next hours';
    
elseif pressureChange > 2
    conditionNumber = 3;
    % message = 'weather gets better';
    
elseif avgPressure <= 1000 && avgHumidity >= 70
    conditionNumber = 4;
    % message = 'probably bad weather';
    
elseif avgPressure >= 1025 && avgHumidity <= 60
    conditionNumber = 5;
    % message = 'probably good weather';
    
else
    conditionNumber = 6;
    % message = 'probably variable weather';
end

%% React to weather change

% Read previous condition
conditionNumberCheck = thingSpeakRead(ChannelIDWrite,'Fields',1,'ReadKey',readAPIKeyAppo);

% Check difference between actual and previous forecast. Used to update a
% field that will be read by REACT to post a weather forecast message on
% Twitter, so that forecast will be broadcasted only when weather change.
if (conditionNumberCheck - conditionNumber) == 0
    pressureChangeSwitch = 0;
else
    pressureChangeSwitch = 1;
end

% WARNING: it works only if there are at least 15 seconds between calls!
thingSpeakWrite(ChannelIDWrite,'Fields',[1,2],...
    'Values',[conditionNumber, pressureChangeSwitch], ...
    'WriteKey',writeAPIKeyAppo);