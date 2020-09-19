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
startDate = datetime(2020,01,01);
endDate = datetime('today');
nDays = days(endDate - startDate) + 1;
nWeeks = ceil(nDays/7);
timeline = datetime(startDate):7:datetime(endDate);

% Initialize arrays
minField = zeros(1,nWeeks);
maxField = zeros(1,nWeeks);
avgField = zeros(1,nWeeks);

% Read field data and calculate weekly statistics
for i = 1:nWeeks
    % disp(['week ',num2str(i)])
    singleDayData = thingSpeakRead(readChannelID,'Fields',FieldID, ...
        'dateRange', [startDate+7*(i-1), startDate+7*i], 'ReadKey',readAPIKey);
    if isempty(singleDayData) % avoid errors when there are no data
        minField(i) = NaN;
        maxField(i) = NaN;
    else
        minField(i) = min(singleDayData);
        maxField(i) = max(singleDayData);
    end
    avgField(i) = mean(singleDayData,'omitnan');
end

% Visualize the data
hold on
plot(timeline,minField,'LineWidth',2)
plot(timeline,maxField,'LineWidth',2)
plot(timeline,avgField,'LineWidth',2)
hold off
grid on
legend({'Min','Max','Avg'},'Location','Best');
xlabel('Date');
ylabel('Temperature, C');
title('Weekly Temperature Comparison');