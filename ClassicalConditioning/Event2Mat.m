function Event2Mat(sessionFolder)
% Event2Mat Converts data from Neuralynx NEV files to Matlab mat files

% 주어진 sessionFolder 안에 있는 nev file의 목록을 만든다
narginchk(0, 1);
if nargin == 0
    eventFiles = FindFiles('Events.nev','CheckSubdirs',0);
elseif nargin == 1
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        eventFiles = FindFiles('Events.nev','CheckSubdirs',0);
    else
        nFolder = length(sessionFolder);
        eventFiles = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder},'dir')
                cd(sessionFolder{iFolder});
                eventFiles = [eventFiles;FindFiles('Events.nev','CheckSubdirs',1)];
            end
        end
    end
end
if isempty(eventFiles)
    disp('Event file does not exist!');
    return;
end

nFile = length(eventFiles);
for iFile = 1:nFile
    disp(['Analyzing ',eventFiles{iFile}]);
    cd(fileparts(eventFiles{iFile}));
    
    [timeStamp, eventString] = Nlx2MatEV(eventFiles{iFile}, [1 0 0 0 1], 0, 1, []);
    timeStamp = timeStamp'/1000; % unit: msec
    
    % epoch
    recStart = find(strcmp(eventString,'Starting Recording'));
    recEnd = find(strcmp(eventString,'Stopping Recording'));
    baseTime = timeStamp([recStart(1),recEnd(1)]);
    taskTime = timeStamp([recStart(2),recEnd(2)]);
    
    % lick time
    lickITIThreshold = 1000/20; % 20 Hz (50 ms)보다 높으면 제거
    lickOnsetIndex = strcmp(eventString, 'Sensor');
    lickOnsetTime = timeStamp(lickOnsetIndex);
    lickOut = [false; (diff(lickOnsetTime(:,1)) < lickITIThreshold)];
    lickOnsetTime(lickOut,:) = [];
    
    % trial
    trialOffsetIndex = find(strcmp(eventString, 'Baseline'));
    nTrial = length(trialOffsetIndex) - 1;
    
    eventTime = NaN(nTrial, 6);
    cue = NaN(nTrial, 1);
    reward = NaN(nTrial, 1);
    modulation = NaN(nTrial, 1);
    for iTrial = 1:nTrial
        inTrial = (timeStamp>=timeStamp(trialOffsetIndex(iTrial)) & timeStamp<timeStamp(trialOffsetIndex(iTrial+1)));
        
        trialOnsetIndex = strncmp(eventString, 'Cue', 3) & inTrial;
        offsetTemp = find(strncmp(eventString, 'TTL Input on AcqSystem1_0 board 0 port 2', 40) & inTrial);
        rewardIndex = (strcmp(eventString, 'Reward') | strcmp(eventString, 'Non-reward')) & inTrial;
        modulationIndex = strcmp(eventString, 'Red') & inTrial;
        
        if length(offsetTemp)~=3; continue; end;
        if ~any(trialOnsetIndex); continue; end;
        if ~any(rewardIndex); continue; end;
        eventTime(iTrial,1) = timeStamp(trialOnsetIndex);
        eventTime(iTrial, [2:3 5]) = timeStamp(offsetTemp);
        eventTime(iTrial,4) = timeStamp(rewardIndex);
        eventTime(iTrial,6) = timeStamp(trialOffsetIndex(iTrial+1));
        
        cue(iTrial) = str2double(eventString{trialOnsetIndex}(4));
        modulation(iTrial) = any(modulationIndex);
        reward(iTrial) = any(strcmp(eventString, 'Reward') & inTrial);
    end
    eventTime(isnan(eventTime(:,1)),:) = [];
    nTrial = size(eventTime,1);
    
    % trial summary
    trialIndex = false(nTrial,16);
    cueIndex = false(nTrial,4);
    for iCue = 1:4
        cueIndex(:,iCue) = cue==iCue;
        for iReward = 1:2
            for iModulation = 1:2
                iCol = (iCue-1)*4 + (iReward-1)*2 + iModulation;
                trialIndex(:,iCol) = (cue==iCue) & (reward==(2-iReward)) & (modulation==(iModulation-1));
            end
        end
    end
    
    cueResult = sum(cueIndex);
    trialResult = sum(trialIndex);
    
    % find first lick time
    rewardCheckingTime = zeros(nTrial,1);
    for iTrial = 1:nTrial
        rewardTempTime = find(lickOnsetTime>=eventTime(iTrial,4) & lickOnsetTime<eventTime(iTrial,6),1,'first');
        if ~isempty(rewardTempTime)
            rewardCheckingTime(iTrial) = timeStamp(rewardTempTime);
        else
            rewardCheckingTime(iTrial) = NaN;
        end
    end
    
    % tagging
    tagIndex = timeStamp > taskTime(2);
    blueOnsetIndex = strcmp(eventString, 'Blue') & tagIndex;
    redOnsetIndex = strcmp(eventString, 'Red') & tagIndex;
    blueOnsetTime = timeStamp(blueOnsetIndex);
    redOnsetTime = timeStamp(redOnsetIndex);
    
    save('Events.mat', ...
        'baseTime', 'taskTime', ...
        'lickOnsetTime', ...
        'nTrial', 'cue', 'reward', 'modulation', ...
        'eventTime', 'trialIndex', 'cueIndex', 'cueResult', 'trialResult', 'rewardCheckingTime', ...
        'blueOnsetTime', 'redOnsetTime');   
end
disp('Done!');