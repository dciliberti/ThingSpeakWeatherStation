% Read min, max, and average temperature data from a ThingSpeak channel
% from a given start date until today.
% Visualize the data in a single plot using the PLOT function. 

% Channel ID to read data from 
readChannelID = 000000; 
% Field ID 
FieldID = 1; 

% Channel Read API Key 
% If your channel is private, then enter the read API 
% Key between the '' below: 
readAPIKey = ''; 

% Define date range
startDate = datetime(2019,12,30);
endDate = datetime('today');
nDays = days(endDate - startDate) + 1;
timeline = datetime(startDate):datetime(endDate);

% Initialize arrays
minField = zeros(1,nDays);
maxField = zeros(1,nDays);
avgField = zeros(1,nDays);

% Read field data and calculate daily statistics
for i = 1:nDays
    singleDayData = thingSpeakRead(readChannelID,'Fields',FieldID, ...
        'dateRange', [startDate+i-1, startDate+i], 'ReadKey',readAPIKey);
    minField(i) = min(singleDayData);
    maxField(i) = max(singleDayData);
    avgField(i) = mean(singleDayData,'omitnan');
end

% Visualize the data
hold on
plot(timeline,minField,'LineWidth',2)
plot(timeline,maxField,'LineWidth',2)
plot(timeline,avgField,'LineWidth',2)
hold off
legend({'Min','Max','Avg','Location','Best'});
xlabel('Date');
ylabel('Temperature, C');
title('Daily Temperature Comparison');