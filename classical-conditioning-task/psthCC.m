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
winTagBlue = [-20 100]; % unit: msec
binSizeTagBlue = 2;

winTagRed = [-500 2000]; % unit: msec
binSizeTagRed = 20;

% Find files
if nargin == 0; sessionFolder = {}; end;
[tData, tList] = tLoad(sessionFolder);
if isempty(tList); return; end;

nCell = length(tList);
for iCell = 1:nCell
    disp(['### Analyzing ',tList{iCell},'...']);
    [cellPath,cellName,~] = fileparts(tList{iCell});

    % Load event variables
    load([cellPath,'\Events.mat']);
    win = [eventDuration(1)-0.5 maxTrialDuration]*10^3; % unit: msec, window for binning
    
    % Load spike data
    spikeData = tData{iCell}; % unit: msec
    
    % Firing rate
    fr_base = sum(histc(spikeData,baseTime))/diff(baseTime/1000);
    fr_task = sum(histc(spikeData,taskTime))/diff(taskTime/1000);
    
    % spike data aligned to events
    spikeTime = spikeWin(spikeData, eventTime(:,2), win);
    spikeTimeRw = spikeWin(spikeData, rewardLickTime, winRw);
    inRw = ~isnan(rewardLickTime);

    % Making raster points.  unit of xpt is sec. unit of ypt is trial.
    [xpt, ypt, psthtime, psthbar, psthconv, psthconvz, psthsem] = rasterPSTH(spikeTime,trialIndex,win,binSize,resolution,1);
    xpt = cellfun(@(x) x/1000, xpt, 'UniformOutput', false); psthtime = psthtime/10^3;
    [xptCue, yptCue, ~, psthbarCue, psthconvCue, psthconvzCue, psthsemCue] = rasterPSTH(spikeTime,cueIndex,win,binSize,resolution,1);
    xptCue = cellfun(@(x) x/1000, xptCue, 'UniformOutput', false);
    [xptRw, yptRw, psthtimeRw, psthbarRw, psthconvRw, psthconvzRw, psthsemRw] = rasterPSTH(spikeTimeRw(inRw),trialIndex(inRw,:),winRw,binSize,resolution,1);
    xptRw = cellfun(@(x) x/1000, xptRw, 'UniformOutput', false); psthtimeRw = psthtimeRw/10^3;

    save([cellName,'.mat'],...
        'fr_base','fr_task',...
        'spikeTime','spikeTimeRw',...
        'win','xpt','ypt','psthtime','psthbar','psthconv','psthconvz', 'psthsem', ...
        'xptCue','yptCue','psthbarCue','psthconvCue','psthconvzCue', 'psthsemCue', ...
        'winRw','xptRw','yptRw','psthbarRw','psthtimeRw','psthconvRw','psthconvzRw', 'psthsemRw');
    
    % Tagging
    spikeTimeTagBlue = spikeWin(spikeData, blueOnsetTime, winTagBlue);
    [xptTagBlue, yptTagBlue, psthtimeTagBlue,psthTagBlue,~,~] = rasterPSTH(spikeTimeTagBlue,true(size(blueOnsetTime)),winTagBlue,binSizeTagBlue,resolution,1);
    save([cellName,'.mat'],...
        'spikeTimeTagBlue','xptTagBlue','yptTagBlue','psthtimeTagBlue','psthTagBlue','-append');
    
    spikeTimeTagRed = spikeWin(spikeData, redOnsetTime, winTagRed);
    [xptTagRed, yptTagRed, psthtimeTagRed,psthTagRed,~,~] = rasterPSTH(spikeTimeTagRed,true(size(redOnsetTime)),winTagRed,binSizeTagRed,resolution,1);
    save([cellName,'.mat'],...
        'spikeTimeTagRed','xptTagRed','yptTagRed','psthtimeTagRed','psthTagRed','-append');
end
disp('### Making Raster, PSTH is done!');