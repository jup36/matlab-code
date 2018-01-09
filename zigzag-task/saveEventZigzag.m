function saveEventZigzag(binFileList)
%SVAEVENTZIGZAG Reads IMEC binary data and makes event file
%   SAVEVENTZIGZAG(BFL) reads BF file and makes event file using bin file. It also
%   extracts BCS behavior record and synchronize with IMEC sync data. All
%   units are saved in seconds.

%   Dohoung Kim
%   Howard Hughes Medical Institute
%   Janelia Research Campus
%   19700 Helix Drive
%   Ashburn, Virginia 20147
%   kimd11@janelia.hhmi.org


% default data location
IMEC_DATA_PATH = 'E:\';
BCS_DATA_PATH = ['C:\Users\', getenv('USERNAME'), '\OneDrive - Howard Hughes Medical Institute\project\neozig\data_behavior\'];

%% Find bin data files
if nargin < 1 || isempty(binFileList) || ~iscell(binFileList)
    binList = dir(fullfile(IMEC_DATA_PATH, '*.ap.bin'));
    
    if isempty(binList)
        imecDataPath = uigetdir(IMEC_DATA_PATH);
        if ~ischar(imecDataPath); return; end
        binList = dir(fullfile(imecDataPath, '*.ap.bin'));
    else
        imecDataPath = IMEC_DATA_PATH;
    end
    
    nBin = length(binList);
    binFile = {};
    for iBin = 1:nBin
        if binList(iBin).bytes > 10^10
            binFile = [binFile; {fullfile(imecDataPath, binList(iBin).name)}];
        end
    end
else
    nBin = length(binFileList);
    binFile = {};
    for iBin = 1:nBin
        if exist(binFileList{iBin}, 'file')
            binFile = [binFile; binFileList{iBin}];
        end
    end
end

%% Save event data
nBin = length(binFile);
for iBin = 1:nBin
    % load event file
    meta = readOption(binFile{iBin});
    dataFile = replace(binFile{iBin}, '.bin', ['_imec3_opt', num2str(meta.imProbeOpt), '_data.mat']);
    
    if ~(exist(dataFile, 'file')==2)
        eventDataArray = readBin(binFile{iBin}, meta);
        saveImecEvent(dataFile, eventDataArray);
        saveBcsEvent(dataFile, BCS_DATA_PATH);
    else
        eventFileInfo = who('-file', dataFile);
        
        checkVariable1 = {'Sync', 'Lick', 'Trial'};
        if ~all(ismember(checkVariable1, eventFileInfo)) || batch==1
            doCalcImec = 'Yes';
        else
            doCalcImec = questdlg('Imec event file already exists. Do you want to overwrite?', 'Overwrite', 'No');
        end
        
        if strcmp(doCalcImec, 'Yes')
            eventDataArray = readBin(binFile, meta);
            saveImecEvent(dataFile, eventDataArray);
        end
        
        checkVariable2 = {'Vr'};
        if ~all(ismember(checkVariable2, eventFileInfo)) || batch==1
            doCalcBcs = 'Yes';
        else
            doCalcBcs = questdlg('BCS event file already exists. Do you want to overwrite?', 'Overwrite', 'No');
        end
        
        if strcmp(doCalcBcs, 'Yes')
            saveBcsEvent(dataFile, BCS_DATA_PATH);
        end
    end
end
slack('saveEvent done');


function meta = readOption(binFile)
% Parse ini file into cell entries C{1}{i} = C{2}{i}
fid = fopen(replace(binFile, '.bin', '.meta'), 'r');
C = textscan(fid, '%[^=] = %[^\r\n]');
fclose(fid);

% New empty struct
meta = struct();

% Convert each cell entry into a struct entry
for i = 1:length(C{1})
    tag = C{1}{i};
    if tag(1) == '~'
        % remake tag excluding first character
        tag = sprintf('%s', tag(2:end));
        meta.(tag) = C{2}{i};
    else
        valueTemp = str2double(strsplit(C{2}{i}, ','));
        if isnan(valueTemp)
            meta.(tag) = C{2}{i};
        else
            meta.(tag) = valueTemp;
        end
    end
end


function dataArray = readBin(binFile, meta)
% get file infomation
dataInfo = dir(binFile);
dataSize = dataInfo.bytes;
sampleNumber = dataSize / (2 * meta.nSavedChans);
if sampleNumber ~= floor(sampleNumber); error('Corrupted file'); end
offset = 2 * (meta.nSavedChans - 1);
disp(['Loading ', binFile]);
disp(['IMEC probe option: ', num2str(meta.imProbeOpt)]);
disp(['Sample number: ', num2str(sampleNumber)]);

% read file
tic;
fid = fopen(binFile, 'rb');
fseek(fid, offset, 'bof');
dataArray = fread(fid, sampleNumber, 'uint16', offset);
fclose(fid);
toc;


function saveImecEvent(dataFile, eventDataArray)
% 0: sync, 1: lick, 2: reward, 3: no reward, 4: reserved (laser)
syncEvent = [0; diff(double(bitget(eventDataArray, 1, 'uint16')))];
Sync.timeImec = find(syncEvent~=0)/30000;
Sync.typeImec = syncEvent(syncEvent~=0)==1;

lickEvent = [0; diff(double(bitget(eventDataArray, 2, 'uint16')))];
Lick.time = find(lickEvent~=0)/30000;
Lick.type = lickEvent(lickEvent~=0)==1;

trialCorrectEvent = [0; diff(double(bitget(eventDataArray, 3, 'uint16')))];
trialWrongEvent = [0; diff(double(bitget(eventDataArray, 4, 'uint16')))];

Trial.timeCorrect = find(trialCorrectEvent==1)/30000;
Trial.timeWrong = find(trialWrongEvent==1)/30000;
Trial.timeStartImec = find(trialCorrectEvent==-1 | trialWrongEvent==-1)/30000;

Trial.nCorrect = length(Trial.timeCorrect);
Trial.nWrong = length(Trial.timeWrong);
Trial.nTrial = Trial.nCorrect + Trial.nWrong;

timeResult = [Trial.timeCorrect; Trial.timeWrong];
[Trial.timeResult, trialIndex] = sort(timeResult);
Trial.result = trialIndex <= Trial.nCorrect;

disp(['Saving IMEC data to ', dataFile]);
if exist(dataFile, 'file')==2
    save(dataFile, 'Sync', 'Lick', 'Trial', '-append');
else
    save(dataFile, 'Sync', 'Lick', 'Trial');
end


function dataFile = saveBcsEvent(dataFile, bcsPath)
% sync with bcs data

% find bcs file
[~, eventName] = fileparts(dataFile);
fileInfo = strsplit(eventName, '_');
binTemp = strsplit(dataFile, '_imec3_opt');
binDir = dir([binTemp{1}, '.bin']);
dataDir = dir([bcsPath, fileInfo{1},'_',fileInfo{2},'_*.mat']);
nFile = length(dataDir);
timeDiff = zeros(nFile, 1);
for iFile = 1:nFile
    timeDiff(iFile) = abs(dataDir(iFile).datenum - binDir.datenum);
end
[minTimeDiff, indexTimeDiff] = min(timeDiff);
if minTimeDiff < 2/24/60 % 2 minite diff
    sessionPath = bcsPath;
    sessionFile = dataDir(indexTimeDiff).name;
else
    [sessionFile, sessionPath] = uigetfile([bcsPath, fileInfo{1},'_',fileInfo{2},'_*.mat'], 'Choose session file');
    if sessionFile==0; return; end
end

% load bcs mat file
load(fullfile(sessionPath, sessionFile), 'data');
load(dataFile, 'Sync', 'Trial');

% sync check
nSyncImec = length(Sync.typeImec);
nSyncBcs = length(data.syncType);
nSync = min(nSyncImec, nSyncBcs);

disp(['IMEC sync pulse: ', num2str(nSyncImec),', BCS sync pulse: ', num2str(nSyncBcs)]);
if all(Sync.typeImec(1:nSync)==data.syncType(1:nSync))
    disp('Correct Sync!');
    Sync.timeImec = Sync.timeImec(1:nSync);
    Sync.typeImec = Sync.typeImec(1:nSync);
    Sync.timeBcs = data.syncTime(1:nSync);
    Sync.typeBcs = data.syncType(1:nSync);
elseif all(Sync.typeImec(2:nSync+1)==data.syncType(1:nSync))
    disp('Slided sync');
    Sync.timeImec = Sync.timeImec(2:nSync+1);
    Sync.typeImec = Sync.typeImec(2:nSync+1);
    Sync.timeBcs = data.syncTime(1:nSync);
    Sync.typeBcs = data.syncType(1:nSync);
else
    error('Disrupted Sync!');
end

% check time overflow
Sync.timeBcs = double(Sync.timeBcs);
subplot(2, 2, 1); plot(Sync.timeBcs);
syncOverflow = find(diff(Sync.timeBcs) < -4E9) + 1;
if ~isempty(syncOverflow)
    disp(['Sync overflow at ', num2str(syncOverflow')]);
    for iS = 1:length(syncOverflow)
        Sync.timeBcs(syncOverflow(iS):end) = Sync.timeBcs(syncOverflow(iS):end) + double(intmax('uint32'));
    end
end
Sync.timeBcs = Sync.timeBcs / 10^6;
subplot(2, 2, 2); plot(Sync.timeBcs);

Vr.timeBcs = double(data.timeStamp(:, 1));
subplot(2, 2, 3); plot(Vr.timeBcs);
timeOverflow = find(diff(Vr.timeBcs) < -4E9) + 1;
if ~isempty(timeOverflow)
    disp(['Time overflow at ', num2str(timeOverflow')]);
    for iT = 1:length(timeOverflow)
        Vr.timeBcs(timeOverflow(iT):end) = Vr.timeBcs(timeOverflow(iT):end) + double(intmax('uint32'));
    end
end
Vr.timeBcs = Vr.timeBcs / 10^6;
subplot(2, 2, 4); plot(Vr.timeBcs);

Vr.timeImec = interp1(Sync.timeBcs, Sync.timeImec, Vr.timeBcs, 'linear', 'extrap');
Vr.position = double(data.position(:,1:2))/100; % in centimeter
Vr.speed = double(data.velocity)/100; % cm/s
Vr.ballVelocity = data.ballvelocity; % cm/s
Vr.roll = data.roll;
Vr.pitch = data.pitch;
Vr.yaw = data.yaw;
Vr.event = data.event;

trialTime = double(data.trialTime);
trialOverflow = find(diff(trialTime) < -2E9) + 1;
if ~isempty(trialOverflow)
    disp(['Trial time overflow at ', num2str(trialOverflow')]);
    for iT = 1:length(trialOverflow)
        trialTime(trialOverflow(iT):end) = trialTime(trialOverflow(iT):end) + double(intmax('uint32'));
    end
end
trialTime = trialTime / 10^6;

inTrial = data.trial(:, 1)==1;
timeStart = trialTime(inTrial);
Trial.timeStartBcs = interp1(Sync.timeBcs, Sync.timeImec, timeStart(1:Trial.nTrial), 'linear', 'extrap');


% ===============================================
% trial analysis: could be different by task type
% ===============================================

% calculate choice
inTrial = data.trial(:, 1) >= 2;
cueTemp = data.trial(inTrial, 3);
Trial.cue = cueTemp(1:Trial.nTrial);

%% Exclude bad trials
% 20171226
% Since there are trials which mouse made late decision or variable
% trajectory, trials that is longer than several seconds and trials without
% definitive decision will be excluded.

% Task variables
STARTING_POINT = [0, -30; % left door
    120, -30; % right door
    60, -30] - [-103.756, -128.442]; % center door
BORDER_LEFT = -7.5; % border between left and center
BORDER_RIGHT = 7.5; % border between center and right
TIME_LIMIT = 3;

% Trial start time is defined by the time point that y position of the
% mouse were reseted to the starting point. Outcome time is defined by the
% point that mouse touched sensors in the VR. The outcome sensors usually
% have names like 'c' or 'w' which menas correct and wrong, respectively.

startIndex = find(diff(Vr.position(:, 2)) < -80) + 1;
outcomeIndex = find([0; diff(cellfun(@(x) ~isempty(regexp(x, '[cw]', 'once')), Vr.event))] == 1);

Trial.inTrial = false(Trial.nTrial, 1);
endIndex = zeros(Trial.nTrial, 1);
for iT = find(Trial.result)'
    outcomeCurrentIndex = find(outcomeIndex > startIndex(iT), 1, 'first');
    endIndex(iT) = outcomeIndex(outcomeCurrentIndex);
    
    tPos = Vr.timeBcs(startIndex(iT):endIndex(iT)) - Vr.timeBcs(startIndex(iT));
    xPos = Vr.position(startIndex(iT):endIndex(iT), 1) - STARTING_POINT(Trial.cue(iT), 1);
    yPos = Vr.position(startIndex(iT):endIndex(iT), 2) - STARTING_POINT(Trial.cue(iT), 2);
    
    switch Trial.cue(iT)
        case 1 % left
            if any(xPos >= BORDER_RIGHT); continue; end
            if tPos(find(xPos <= BORDER_LEFT, 1, 'first')) > TIME_LIMIT; continue; end
        case 2 % right
            if any(xPos <= BORDER_LEFT); continue; end
            if tPos(find(xPos >= BORDER_RIGHT, 1, 'first')) > TIME_LIMIT; continue; end
        case 3 % center
            if any(xPos >= BORDER_RIGHT | xPos <= BORDER_LEFT); continue; end
    end
    
    Trial.inTrial(iT) = true;
end

disp(['Saving BCS data to ', dataFile]);
if exist(dataFile, 'file')==2
    save(dataFile, 'Sync', 'Vr', 'Trial', '-append');
else
    save(dataFile, 'Sync', 'Vr', 'Trial');
end

