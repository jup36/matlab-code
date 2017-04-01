spikeRate = 10; % spike rate 10 Hz
recordingDuration = 60*5; % recording for 5 min
lightFrequency = 2; % light stimulation at 2 Hz
testRange = 50; % in ms
baseRange = [-400, 0]; % in ms
dt = 0.5;

onsetTime = 1000*(1/lightFrequency:1/lightFrequency:recordingDuration)'; % light stimulation in ms
spikeDataNoResponse = sort(rand(spikeRate*recordingDuration, 1)*1000*recordingDuration); % spike data in ms
spikeLight = randsample((randn(600, 1)*2+3)+onsetTime, 400);
spikeDataResponse = sort([spikeDataNoResponse;spikeLight]); % spike data in ms

timeNoResponse = tagDataLoad(spikeDataNoResponse, onsetTime, testRange, baseRange);
timeResponse = tagDataLoad(spikeDataResponse, onsetTime, testRange, baseRange);

pNoResponse = saltTest(timeNoResponse, testRange, dt);
pResponse = saltTest(timeResponse, testRange, dt);