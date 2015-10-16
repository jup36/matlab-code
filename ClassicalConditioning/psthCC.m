function psthCC(sessionFolder)
% psthCC Converts data from MClust t files to Matlab mat files

% 1. raster, psth aligned with cue start
% 2. raster, psth aligned with reward lick onset
% 3. save raw data for later use: spikeTime{trial}
% 4. tagging data under blue or red light

narginchk(0, 2);

% Task variables
binSize = 10; % unit: msec, = 10 msec
resolution = 10; % sigma = resolution * binSize = 100 msec
winRw = [-2 4]*10^3;

% Tag variables
winBlueTag = [-20 100]; % unit: msec
binSizeBlueTag = 2;

winRedTag = [-500 2000]; % unit: msec
binSizeRedTag = 20;

% Find files
if nargin == 0
    ttFile = FindFiles('T*.t','CheckSubdirs',0); 
else
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        ttFile = FindFiles('T*.t','CheckSubdirs',1);
    else
        nFolder = length(sessionFolder);
        ttFile = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder})==7 
                cd(sessionFolder{iFolder});
                ttFile = [ttFile;FindFiles('T*.t','CheckSubdirs',1)];
            elseif strcmp(sessionFolder{iFolder}(end-1:end),'.t') 
                ttFile = [ttFile;sessionFolder{iFolder}];
            end
        end
    end
end
if isempty(ttFile)
    disp('TT file does not exist!');
    return;
end
ttData = LoadSpikes(ttFile,'tsflag','ts','verbose',0);

nCell = length(ttFile);
for iCell = 1:nCell
    disp(['### Analyzing ',ttFile{iCell},'...']);
    [cellPath,cellName,~] = fileparts(ttFile{iCell});
    cd(cellPath);

    % Load event variables
    load('Events.mat');
    win = [-1 maxTrialDuration]*10^3; % unit: msec, window for binning
    
    % Load spike data
    spikeData = Data(ttData{iCell})/10; % unit: msec
    
    % Firing rate
    fr_base = sum(histc(spikeData,baseTime))/diff(baseTime/1000);
    fr_task = sum(histc(spikeData,taskTime))/diff(taskTime/1000);
    
    % spike data aligned to events
    spikeTime = spikeWin(spikeData, eventTime(:,1), win);
    spikeTimeRw = spikeWin(spikeData, rewardLickTime, winRw);

    % Making raster points.  unit of xpt is sec. unit of ypt is trial.
    [xpt, ypt, psthtime, ~, psthconv, psthconvz] = rasterPSTH(spikeTime,trialIndex,win,binSize,resolution);
    xpt = cellfun(@(x) x/1000, xpt, 'UniformOutput', false); psthtime = psthtime/10^3;
    [xptRw, yptRw, psthtimeRw, ~, psthconvRw, psthconvzRw] = rasterPSTH(spikeTimeRw,trialIndex,win,binSize,resolution);
    xptRw = cellfun(@(x) x/1000, xptRw, 'UniformOutput', false); psthtimeRw = psthtimeRw/10^3;

    save([cellName,'.mat'],...
        'fr_base','fr_task',...
        'spikeTime','spikeTimeRw',...
        'win','xpt','ypt','psthtime','psthconv','psthconvz',...
        'winRw','xptRw','yptRw','psthtimeRw','psthconvRw','psthconvzRw');
    
    % Tagging
    spikeTimeBlueTag = spikeWin(spikeData, blueOnsetTime, winBlueTag);
    spikeTimeRedTag = spikeWin(spikeData, redOnsetTime, winRedTag);
    
    [xptBlueTag, yptBlueTag, psthtimeBlueTag,psthBlueTag,~,~] = rasterPSTH(spikeTimeBlueTag,true(size(blueOnsetTime)),winBlueTag,binSizeBlueTag,resolution);
    [xptRedTag, yptRedTag, psthtimeRedTag,psthRedTag,~,~] = rasterPSTH(spikeTimeRedTag,true(size(redOnsetTime)),winRedTag,binSizeRedTag,resolution);
    
    save([cellName,'.mat'],...
        'spikeTimeBlueTag','xptBlueTag','yptBlueTag','psthtimeBlueTag','psthBlueTag',...
        'spikeTimeRedTag','xptRedTag','yptRedTag','psthtimeRedTag','psthRedTag','-append');
end
disp('### Making Raster, PSTH is done!');

function spikeTime = spikeWin(spikeData, eventTime, win)
%spikeWin makes raw spikeData into eventTime aligned data
%   spikeData: raw data from MClust. Unit must be ms.
%   eventTime: each output cell will be eventTime aligned spike data. unit must be ms.
%   win: spike within windows will be included. unit must be ms.
narginchk(3, 3);

if isempty(eventTime); spikeTime = []; return; end;
nEvent = size(eventTime);
spikeTime = cell(nEvent);
for iEvent = 1:nEvent(1)
    for jEvent = 1:nEvent(2)
        timeIndex = [];
        if isnan(eventTime(iEvent,jEvent)); continue; end;
        [~,timeIndex] = histc(spikeData,eventTime(iEvent,jEvent)+win);
        if isempty(timeIndex); continue; end;
        spikeTime{iEvent,jEvent} = spikeData(logical(timeIndex))-eventTime(iEvent,jEvent);
    end
end

function [xpt,ypt,spikeBin,spikeHist,spikeConv,spikeConvZ] = rasterPSTH(spikeTime, trialIndex, win, binSize, resolution)
%rasterPSTH converts spike time into raster plot
%   spikeTime: cell array. each cell contains vector array of spike times per each trial. unit is msec
%   trialIndex: number of rows should be same as number of trials (length of spikeTime)
%   win: window range of xpt. should be 2 numbers. unit is msec.
%   binsize: unit is msec.
%   resolution: sigma for convolution = binsize * resolution.
%   unit of xpt will be sec.
narginchk(5, 5);
if isempty(spikeTime) || isempty(trialIndex) || length(spikeTime) ~= size(trialIndex,1) || length(win) ~= 2
    xpt = []; ypt = []; spikeBin = []; spikeHist = []; spikeConv = []; spikeConvZ = [];
    return;
end;

spikeBin = win(1):binSize:win(2); % unit: msec
nSpikeBin = length(spikeBin);

nTrial = length(spikeTime);
nCue = size(trialIndex,2);
trialResult = sum(trialIndex);
resultSum = [0 cumsum(trialResult)];

yTemp = [0:nTrial-1; 1:nTrial; NaN(1,nTrial)]; % template for ypt
xpt = cell(1,nCue);
ypt = cell(1,nCue);
spikeHist = zeros(nCue,nSpikeBin);
spikeConv = zeros(nCue,nSpikeBin);

for iCue = 1:nCue
    if trialResult(iCue) == 0; continue; end;
    
    % raster
    nSpikePerTrial = cellfun(@length,spikeTime(trialIndex(:,iCue)));
    nSpikeTotal = sum(nSpikePerTrial);
    if nSpikeTotal == 0; continue; end;
    
    spikeTemp = cell2mat(spikeTime(trialIndex(:,iCue)))';
    
    xptTemp = [spikeTemp;spikeTemp;NaN(1,nSpikeTotal)];
    xpt{iCue} = xptTemp(:);

    yptTemp = [];
    for iy = 1:trialResult(iCue)
        yptTemp = [yptTemp repmat(yTemp(:,resultSum(iCue)+iy),1,nSpikePerTrial(iy))];
    end
    ypt{iCue} = yptTemp(:);

    % psth
    spkhist_temp = histc(spikeTemp,spikeBin)/(binSize/10^3*trialResult(iCue));
    spkconv_temp = conv(spkhist_temp,fspecial('Gaussian',[1 5*resolution],resolution),'same');
    spikeHist(iCue,:) = spkhist_temp;
    spikeConv(iCue,:) = spkconv_temp;
end

totalHist = histc(cell2mat(spikeTime),spikeBin)/(binSize/10^3*nTrial);
fireMean = mean(totalHist);
fireStd = std(totalHist);
spikeConvZ = (spikeConv-fireMean)/fireStd;