% React to weather forecast. Reads data from my channel and broadcast a
% message on Twitter. It should be used with REACT on ThingSpeak to
% broadcast forecast only when they change.
% Data is read from the support channel

% Aux channel ID and read API keys
ChannelID = 000000; % replace 000000 with your aux Channel ID
readAPIKey = 'myReadAPIkey';  % replace myReadAPIkey with yours (aux)
thingTweetAPIKey = 'myThingTweetAPIKey'; % replace myThingTweetAPIKey with yours (need Twitter account)

conditionNumber = thingSpeakRead(ChannelID,'Fields',1,'ReadKey', readAPIKey);

% Broadcast weather forecast on twitter
switch conditionNumber
    case 1
        message = 'tempesta in arrivo (o in peggioramento)';
    case 2
        message = 'il tempo peggioa nelle prossime ore';
    case 3
        message = 'il tempo migliora nelle prossime ore';
    case 4
        message = 'probabilmente maltempo';
    case 5
        message = 'probabilmente bel tempo';
    case 6
        message = 'tempo variabile';
    otherwise
        message = ' ';
end

tweetStatus = ['TEST previsioni meteo: ', message];

webwrite('https://api.thingspeak.com/apps/thingtweet/1/statuses/update', ...
    'api_key', thingTweetAPIKey, ...
    'status', tweetStatus);