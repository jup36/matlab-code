function jeLoad()
clc; clearvars; close all;
rtdir = pwd;

% variable
nChannel = 277;
offset = 2*(nChannel-1);

% load event file
dataPath = 'C:\SGL_DATA';
cd(dataPath);
[dataFile, dataPath] = uigetfile('*.bin', 'Choose binary data file');

% save file name
[~, dataFileName] = fileparts(dataFile);
eventFileName = fullfile(dataPath,[dataFileName, '_imec3_opt4_event.mat']);

% get file infomation
dataFileName = fullfile(dataPath, dataFile);
dataInfo = dir(dataFileName);
dataSize = dataInfo.bytes;
sampleNumber = dataSize / (2 * nChannel);
if sampleNumber ~= floor(sampleNumber); error('Corrupted file'); end

% read file
tic;
fid = fopen(dataFileName, 'rb');
fseek(fid, offset, 'bof');
dataArray = fread(fid, sampleNumber, 'uint16', offset);
fclose(fid);
toc;

changes = [0; diff(dataArray)];
eventTime = find(changes~=0);
eventType = changes(changes~=0);

% 0: sync, 1: lick, 2: reward, 3: no reward, 4: reserved (laser)
syncTime = eventTime(logical(bitget(abs(eventType), 1, 'uint8')));
syncType = sign(eventType(logical(bitget(abs(eventType), 1, 'uint8'))));

lickTime = eventTime(logical(bitget(abs(eventType), 2, 'uint8') & eventType<0));
lickOffTime = eventTime(logical(bitget(abs(eventType), 2, 'uint8') & eventType>0));

trialStartTime = eventTime(logical((bitget(abs(eventType), 3, 'uint8') | bitget(abs(eventType), 4, 'uint8')) & eventType<0));
correctTime = eventTime(logical(bitget(abs(eventType), 3, 'uint8') & eventType>0));
wrongTime = eventTime(logical(bitget(abs(eventType), 4, 'uint8') & eventType>0));

save(eventFileName, 'eventTime', 'eventType', ...
    'syncTime', 'lickTime', 'lickOffTime', ...
    'trialStartTime', 'correctTime', 'wrongTime');


% sync with bcs data
sessionPath = 'C:\Users\kimd11\OneDrive - Howard Hughes Medical Institute\src\vr\matlab\data\';
cd(sessionPath);
[sessionFile, sessionPath] = uigetfile('*.mat', 'Choose session file');
load(fullfile(sessionPath, sessionFile), 'data');

% sync check
if length(syncTime)~=length(data.syncTime)
    error('Disrupted Sync!');
else
    disp('Correct Sync!');
end

% check time overflow
syncBCS = double(data.syncTime);
syncOverflow = find(diff(syncBCS) < 0, 1, 'first') + 1;
if ~isempty(syncOverflow)
    disp('Sync overflow');
    syncBCS(syncOverflow:end) = syncBCS(syncOverflow:end) + double(intmax('uint32'));
end

timeBCS = double(data.timeStamp(:, 1));
timeOverflow = find(diff(timeBCS) < 0, 1, 'first') + 1;
if ~isempty(timeOverflow)
    disp('Time overflow');
    timeBCS(timeOverflow:end) = timeBCS(timeOverflow:end) + double(intmax('uint32'));
end

syncFit = fit(syncBCS, syncTime, 'linearinterp');
timeStamp = feval(syncFit, timeBCS);

save(eventFileName, 'syncFit', 'timeStamp', 'syncBCS', 'timeBCS', 'data', '-append');