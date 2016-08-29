function Event2Mat(sessionFolder,modOff,noLickOut)
% Event2Mat Converts data from Neuralynx NEV files to Matlab mat files

lickWindow = 1000;
if nargin < 1
    sessionFolder = {};
end
if nargin < 2
    modOff = 0;
end
if nargin < 3
    noLickOut = 0;
end

[eData, eList] = eLoad(sessionFolder);

nFile = length(eList);
for iFile = 1:nFile
    disp(['Analyzing ',eList{iFile}]);
    cd(fileparts(eList{iFile}));
    
    timeStamp = eData(iFile).t;
    eventString = eData(iFile).s;
    
    % epoch
    recStart = find(strcmp(eventString,'Starting Recording'));
    recEnd = find(strcmp(eventString,'Stopping Recording'));
    baseTime = timeStamp([recStart(1),recEnd(1)]);
    taskTime = timeStamp([recStart(2),recEnd(2)]);
    tagTime = timeStamp([recStart(3),recEnd(3)]);
    
    % lick time
    lickITIThreshold = 1000/20; % lick intervals shorter than 20 Hz (50 ms) are usually artifacts.
    lickOnsetIndex = strcmp(eventString, 'Sensor');
    lickOnsetTime = timeStamp(lickOnsetIndex);
    lickOut = [false; (diff(lickOnsetTime(:,1)) < lickITIThreshold)];
    lickOnsetTime(lickOut,:) = [];
    
    % trial
    trialStartIndex = find(strcmp(eventString, 'Baseline'));
    nTrial = length(trialStartIndex) - 1;
    
    eventTime = NaN(nTrial, 6);
    modTime = NaN(nTrial, 2);
    cue = NaN(nTrial, 1);
    reward = NaN(nTrial, 1);
    punishment = NaN(nTrial, 1);
    modulation = NaN(nTrial, 1);
    rewardLickTime = NaN(nTrial,1);
    lickYes = NaN(nTrial,1);
    punishYes = any(strcmp(eventString, 'Punishment'));
    for iTrial = 1:nTrial
        inTrial = (timeStamp>=timeStamp(trialStartIndex(iTrial)) & timeStamp<(timeStamp(trialStartIndex(iTrial+1))-1));
        
        % cue
        cueIndex = strncmp(eventString, 'Cue', 3) & inTrial;
        if ~any(cueIndex); continue; end;
        
        % reward
        rewardIndex = (strcmp(eventString, 'Reward') | strcmp(eventString, 'Non-reward') | strcmp(eventString, 'Punishment')) & inTrial;
        if ~any(rewardIndex); continue; end;

        % TTL off (1. cue onset, 2. delay onset, 3. reward offset)
        offsetTemp = find(strncmp(eventString, 'TTL Input on AcqSystem1_0 board 0 port 2', 40) & inTrial);
        if length(offsetTemp)~=3; continue; end;
        
        % modulation
        modOnsetIndex = find(strcmp(eventString, 'Red') & inTrial);
        if ~isempty(modOnsetIndex)
            modTime(iTrial, 1) = timeStamp(modOnsetIndex);
        
            modOffsetIndex = find((strcmp(eventString, 'TTL Input on AcqSystem1_0 board 0 port 3 value (0x0000).') | ...
                strcmp(eventString, 'TTL Input on AcqSystem1_0 board 0 port 3 value (0x0001).')) & inTrial);
            if ~isempty(modOffsetIndex)
                modOffsetIndexIndex = find(modOffsetIndex > modOnsetIndex, 1, 'first');
                modTime(iTrial, 2) = timeStamp(modOffsetIndex(modOffsetIndexIndex));
            end
        end
        
        % time variables
        % col1: baseline
        % col2: cue onset
        % col3: delay onset
        % col4: reward onset
        % col5: reward offset
        % col6: trial end
        eventTime(iTrial,1) = timeStamp(cueIndex);
        eventTime(iTrial, [2:3 5]) = timeStamp(offsetTemp);
        eventTime(iTrial,4) = timeStamp(rewardIndex);
        eventTime(iTrial,6) = timeStamp(trialStartIndex(iTrial+1));
        
        % trial variables
        cue(iTrial) = str2double(eventString{cueIndex}(4));
        reward(iTrial) = any(strcmp(eventString, 'Reward') & inTrial);
        punishment(iTrial) = any(strcmp(eventString, 'Punishment') & inTrial);
        % modulation
        % 1: cue period, 2: reward period, 3: total period, 0: none
        if isnan(modTime(iTrial, 1))
            modulation(iTrial) = 0;
        elseif modTime(iTrial, 1) - eventTime(iTrial,1) <= 500
            if diff(modTime(iTrial, :)) <= 3000
                modulation(iTrial) = 1;
            else
                modulation(iTrial) = 3;
            end
        elseif modTime(iTrial, 1) - eventTime(iTrial,1) >= 1500
            modulation(iTrial) = 2;
        else
            modulation(iTrial) = 9;
        end
        
        % find first lick after reward presentation time
        if punishYes && cue(iTrial) == 4
            rewardLickTime(iTrial) = eventTime(iTrial,4);
            lickYes(iTrial) = 1;
        else
            rewardTempTime = find(lickOnsetTime>=eventTime(iTrial,4) & lickOnsetTime<(eventTime(iTrial,4)+lickWindow),1,'first');
            if ~isempty(rewardTempTime)
                rewardLickTime(iTrial) = lickOnsetTime(rewardTempTime);
            end
            
            lickYesTemp = find(lickOnsetTime>=eventTime(iTrial,1) & lickOnsetTime<eventTime(iTrial,6));
            if ~isempty(lickYesTemp)
                lickYes(iTrial) = 1;
            end
        end
    end
    if noLickOut == 1
        errorTrial = isnan(cue) | isnan(reward) | isnan(modulation) | isnan(eventTime(:,1)) | isnan(lickYes);
    else
        errorTrial = isnan(cue) | isnan(reward) | isnan(modulation) | isnan(eventTime(:,1));
    end
    errorTrialNum = sum(errorTrial);
    
    eventTime(errorTrial,:) = [];
    cue(errorTrial) = [];
    reward(errorTrial) = [];
    punishment(errorTrial) = [];
    modulation(errorTrial) = [];
    rewardLickTime(errorTrial) = [];
    
    % Extract non-valid trials
    % If reward is not taken during current trial, it is not valid
    % trial until mouse licks.
    notValidTrial = false(nTrial,1);
    notValidIndex = find(isnan(rewardLickTime) & reward==1)';
    for jTrial = notValidIndex
        [~,notValidUntil] = histc(lickOnsetTime(find(lickOnsetTime>=eventTime(jTrial,4),1,'first')),eventTime(:,6));
        if isempty(notValidUntil); continue; end;
        notValidTrial(jTrial:(notValidUntil+1)) = true;
    end

    notValidTrialNum = sum(notValidTrial);
    
    eventTime(notValidTrial,:) = [];
    cue(notValidTrial) = [];
    reward(notValidTrial) = [];
    punishment(notValidTrial) = [];
    modulation(notValidTrial) = [];
    rewardLickTime(notValidTrial) = [];
    
    if modOff==1
        modulation(modulation==1)=0;
    end
       
    nTrial = size(eventTime,1);
    nTrialRw = sum(~isnan(rewardLickTime));
    trialDuration = eventTime(:,6) - eventTime(:,1);
    maxTrialDuration = round(max(trialDuration)/1000);
    
    eventDuration = round(mean(eventTime - repmat(eventTime(:,2),1,6))/500)/2;

    % trial summary
    cueIndex = false(nTrial,8); % [CueA&noMod CueA&Mod ...]
    trialIndex = false(nTrial,16);% [CueA&noMod&Reward CueA&Mod&Reward CueA&noMod&noReward CueA&Mod&noReward ...]
    for iCue = 1:4
        for iModulation = 1:2
            cueIndex(:,(iCue-1)*2 + iModulation) = (cue==iCue) & (modulation==(iModulation-1));
            for iReward = 1:2
                iCol = (iCue-1)*4 + (iReward-1)*2 + iModulation;
                trialIndex(:,iCol) = (cue==iCue) & ((reward+punishment)==(2-iReward)) & (modulation==(iModulation-1));
            end
        end
    end
    cueResult = sum(cueIndex);
    trialResult = sum(trialIndex);
    
    % tagging
    tagIndex = timeStamp > taskTime(2);
    blueOnsetIndex = strcmp(eventString, 'Blue') & tagIndex;
    redOnsetIndex = strcmp(eventString, 'Red') & tagIndex;
    blueOnsetTime = timeStamp(blueOnsetIndex);
    redOnsetTime = timeStamp(redOnsetIndex);
    
    save('Events.mat', ...
        'baseTime', 'taskTime', 'tagTime', 'lickOnsetTime', 'rewardLickTime', ...
        'eventTime', 'cue', 'reward', 'punishment', 'modulation', 'modTime', ...
        'nTrial', 'nTrialRw', 'errorTrialNum', 'notValidTrialNum', 'maxTrialDuration', 'eventDuration', ...
        'cueIndex', 'cueResult', 'trialIndex', 'trialResult', ...
        'blueOnsetTime', 'redOnsetTime');   
end
disp('Done!');