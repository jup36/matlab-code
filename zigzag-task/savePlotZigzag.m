function savePlotZigzag(dataFileList, overwrite)
%% Find data file
% default data directory
DATA_PATH = 'E:\';

% find file and make list
if nargin < 1 || isempty(dataFileList) || ~iscell(dataFileList)
    dataList = dir(fullfile(DATA_PATH, '*_data.mat'));
    
    if isempty(dataList)
        dataPath = uigetdir(DATA_PATH);
        if ~ischar(dataPath); return; end
        dataList = dir(fullfile(dataPath, '*_data.mat'));
    else
        dataPath = DATA_PATH;
    end
    
    nData = length(dataList);
    dataFile = cell(nData, 1);
    for iData = 1:nData
        dataFile{iData} = fullfile(DATA_PATH, dataList(iData).name);
    end
else
    nData = length(dataFileList);    
    dataFile = {};
    for iData = 1:nData
        if exist(dataFileList{iData}, 'file')
            dataFile = [dataFile; dataFileList{iData}];
        end
    end
end

if nargin < 2
    overwrite = 0;
end




nData = length(dataFile);
for iD = 1:nData
    disp(['Loading ', dataFile{iD}, '...']);
    clearvars Plot
    load(dataFile{iD});

    
    
    
    %% If Plot variable exists in the data file, ask whether try to recalculte
    %     or not.  
    if exist('Plot', 'var') && overwrite==0
        choicePlot = questdlg('Plot variable exists. Recalculate plot variable?', 'Calc Plot', 'No');
    else
        choicePlot = 'Yes';
    end
    
    % Proceed calculation if you answered 'Yes'.
    if strcmpi(choicePlot, 'yes')
        clearvars Plot

        
        
        
        %% spike raster, psth, and regression
        % variables for raster and psth
        WIN_SIZE_START = [-4 8];
        WIN_SIZE_OUTCOME = [-6 6];
            % binSize 10 ms
            % sigma = 10 ms * 5 = 50 ms
            
        % variable for regression
        BIN_WINDOW = 0.5;
        BIN_STEP = 0.1;
        
        % trial index
        trialIndex = false(length(Trial.result), 2);
        for iT = 1:2
            trialIndex(Trial.result==(2-iT), iT) = true;
        end
        
        cueIndex = false(length(Trial.cue), 3);
        cueSequence = [3, 1, 2]; % center, left, right
        nCue = zeros(1, 3);
        for iC = 1:3
            cueIndex(:, iC) = Trial.cue == cueSequence(iC) & Trial.inTrial;
            nCue(iC) = sum(cueIndex(:, iC));
        end
        
        for iUnit = 1:Spike.nUnit
            disp([num2str(iUnit), ' / ', num2str(Spike.nUnit)]);
            
            % event time aligned spike time
            spikeTimeStart = spikeWin(Spike.time{iUnit}, Trial.timeStartBcs, WIN_SIZE_START);
            spikeTimeOutcome = spikeWin(Spike.time{iUnit}, Trial.timeResult, WIN_SIZE_OUTCOME);
            
            % psth and raster
            [Plot.Spike.RasterOutcome(iUnit), Plot.Spike.PsthOutcome(iUnit)] = rasterPsth(spikeTimeOutcome, trialIndex, WIN_SIZE_OUTCOME);
            [Plot.Spike.RasterCueStart(iUnit), Plot.Spike.PsthCueStart(iUnit)] = rasterPsth(spikeTimeStart, cueIndex, WIN_SIZE_START);
            [Plot.Spike.RasterCueOutcome(iUnit), Plot.Spike.PsthCueOutcome(iUnit)] = rasterPsth(spikeTimeOutcome, cueIndex, WIN_SIZE_OUTCOME);
            
            % regression
            [binTimeStart, binSpikeStart] = spikeBin(spikeTimeStart(Trial.inTrial), WIN_SIZE_START, BIN_WINDOW, BIN_STEP);
            [binTimeOutcome, binSpikeOutcome] = spikeBin(spikeTimeOutcome(Trial.inTrial), WIN_SIZE_OUTCOME, BIN_WINDOW, BIN_STEP);
            
            Plot.Spike.RegStart(iUnit) = slideReg(binTimeStart, binSpikeStart, cueIndex(Trial.inTrial, 2:3));
            Plot.Spike.RegOutcome(iUnit) = slideReg(binTimeOutcome, binSpikeOutcome, cueIndex(Trial.inTrial, 2:3));
        end
        
        
        
        
        %% mouse speed
        TIME_BIN = 1/30;
        
        Plot.Speed.Start = alignDataEvent(Vr.ballVelocity, Vr.timeImec, Trial.timeStartBcs, WIN_SIZE_START, TIME_BIN);
        Plot.Speed.Outcome = alignDataEvent(Vr.ballVelocity, Vr.timeImec, Trial.timeResult, WIN_SIZE_OUTCOME, TIME_BIN);
        
        nTime = length(Plot.Speed.Start.t);
        [Plot.Speed.Start.yMeanCue, Plot.Speed.Outcome.yMeanCue] = deal(zeros(3, nTime));
        [Plot.Speed.Start.ySemCue, Plot.Speed.Outcome.ySemCue] = deal(zeros(3, nTime*2));
        for iC = 1:3
            [Plot.Speed.Start.yMeanCue(iC, :), Plot.Speed.Start.ySemCue(iC, :)] = ...
                meanSem(Plot.Speed.Start.y(cueIndex(:, iC), :), nCue(iC));

            [Plot.Speed.Outcome.yMeanCue(iC, :), Plot.Speed.Outcome.ySemCue(iC, :)] = ...
                meanSem(Plot.Speed.Outcome.y(cueIndex(:, iC), :), nCue(iC));
        end
        
        [Plot.Speed.Start.yMeanRw, Plot.Speed.Outcome.yMeanRw] = deal(zeros(2, nTime));
        [Plot.Speed.Start.ySemRw, Plot.Speed.Outcome.ySemRw] = deal(zeros(2, nTime*2));
        for iR = 1:2
            [Plot.Speed.Start.yMeanRw(iR, :), Plot.Speed.Start.ySemRw(iR, :)] = ...
                meanSem(Plot.Speed.Start.y(trialIndex(:, iR), :), sum(trialIndex(:, iR)));

            [Plot.Speed.Outcome.yMeanRw(iR, :), Plot.Speed.Outcome.ySemRw(iR, :)] = ...
                meanSem(Plot.Speed.Outcome.y(trialIndex(:, iR), :), sum(trialIndex(:, iR)));
        end
        
        % regression
        Plot.Speed.RegStart = slideReg(Plot.Speed.Start.t, Plot.Speed.Start.y(Trial.inTrial, :), cueIndex(Trial.inTrial, 2:3));
        Plot.Speed.RegOutcome = slideReg(Plot.Speed.Outcome.t, Plot.Speed.Outcome.y(Trial.inTrial, :), cueIndex(Trial.inTrial, 2:3));
      
        
        
        
        %% mouse pitch
        Plot.Pitch.Start = alignDataEvent(Vr.pitch, Vr.timeImec, Trial.timeStartBcs, WIN_SIZE_START, TIME_BIN);
        Plot.Pitch.Outcome = alignDataEvent(Vr.pitch, Vr.timeImec, Trial.timeResult, WIN_SIZE_OUTCOME, TIME_BIN);
        
        nTime = length(Plot.Pitch.Start.t);
        [Plot.Pitch.Start.yMeanCue, Plot.Pitch.Outcome.yMeanCue] = deal(zeros(3, nTime));
        [Plot.Pitch.Start.ySemCue, Plot.Pitch.Outcome.ySemCue] = deal(zeros(3, nTime*2));
        for iC = 1:3
            [Plot.Pitch.Start.yMeanCue(iC, :), Plot.Pitch.Start.ySemCue(iC, :)] = ...
                meanSem(Plot.Pitch.Start.y(cueIndex(:, iC), :), nCue(iC));

            [Plot.Pitch.Outcome.yMeanCue(iC, :), Plot.Pitch.Outcome.ySemCue(iC, :)] = ...
                meanSem(Plot.Pitch.Outcome.y(cueIndex(:, iC), :), nCue(iC));
        end
        
        [Plot.Pitch.Start.yMeanRw, Plot.Pitch.Outcome.yMeanRw] = deal(zeros(2, nTime));
        [Plot.Pitch.Start.ySemRw, Plot.Pitch.Outcome.ySemRw] = deal(zeros(2, nTime*2));
        for iR = 1:2
            [Plot.Pitch.Start.yMeanRw(iR, :), Plot.Pitch.Start.ySemRw(iR, :)] = ...
                meanSem(Plot.Pitch.Start.y(trialIndex(:, iR), :), sum(trialIndex(:, iR)));

            [Plot.Pitch.Outcome.yMeanRw(iR, :), Plot.Pitch.Outcome.ySemRw(iR, :)] = ...
                meanSem(Plot.Pitch.Outcome.y(trialIndex(:, iR), :), sum(trialIndex(:, iR)));
        end
        
        % regression
        Plot.Pitch.RegStart = slideReg(Plot.Pitch.Start.t, Plot.Pitch.Start.y(Trial.inTrial, :), cueIndex(Trial.inTrial, 2:3));
        Plot.Pitch.RegOutcome = slideReg(Plot.Pitch.Outcome.t, Plot.Pitch.Outcome.y(Trial.inTrial, :), cueIndex(Trial.inTrial, 2:3));
      
        
        
        %% mouse roll
        Plot.Roll.Start = alignDataEvent(Vr.roll, Vr.timeImec, Trial.timeStartBcs, WIN_SIZE_START, TIME_BIN);
        Plot.Roll.Outcome = alignDataEvent(Vr.roll, Vr.timeImec, Trial.timeResult, WIN_SIZE_OUTCOME, TIME_BIN);
        
        nTime = length(Plot.Roll.Start.t);
        [Plot.Roll.Start.yMeanCue, Plot.Roll.Outcome.yMeanCue] = deal(zeros(3, nTime));
        [Plot.Roll.Start.ySemCue, Plot.Roll.Outcome.ySemCue] = deal(zeros(3, nTime*2));
        for iC = 1:3
            [Plot.Roll.Start.yMeanCue(iC, :), Plot.Roll.Start.ySemCue(iC, :)] = ...
                meanSem(Plot.Roll.Start.y(cueIndex(:, iC), :), nCue(iC));

            [Plot.Roll.Outcome.yMeanCue(iC, :), Plot.Roll.Outcome.ySemCue(iC, :)] = ...
                meanSem(Plot.Roll.Outcome.y(cueIndex(:, iC), :), nCue(iC));
        end
        
        [Plot.Roll.Start.yMeanRw, Plot.Roll.Outcome.yMeanRw] = deal(zeros(2, nTime));
        [Plot.Roll.Start.ySemRw, Plot.Roll.Outcome.ySemRw] = deal(zeros(2, nTime*2));
        for iR = 1:2
            [Plot.Roll.Start.yMeanRw(iR, :), Plot.Roll.Start.ySemRw(iR, :)] = ...
                meanSem(Plot.Roll.Start.y(trialIndex(:, iR), :), sum(trialIndex(:, iR)));

            [Plot.Roll.Outcome.yMeanRw(iR, :), Plot.Roll.Outcome.ySemRw(iR, :)] = ...
                meanSem(Plot.Roll.Outcome.y(trialIndex(:, iR), :), sum(trialIndex(:, iR)));
        end
        
        % regression
        Plot.Roll.RegStart = slideReg(Plot.Roll.Start.t, Plot.Roll.Start.y(Trial.inTrial, :), cueIndex(Trial.inTrial, 2:3));
        Plot.Roll.RegOutcome = slideReg(Plot.Roll.Outcome.t, Plot.Roll.Outcome.y(Trial.inTrial, :), cueIndex(Trial.inTrial, 2:3));
        
        
        
        
        %% mouse lick time
        lickTimeStart = spikeWin(Lick.time(Lick.type), Trial.timeStartBcs, WIN_SIZE_START);
        lickTimeOutcome = spikeWin(Lick.time(Lick.type), Trial.timeResult, WIN_SIZE_OUTCOME);
        
        [Plot.Lick.RasterStart, Plot.Lick.PsthStart] = rasterPsth(lickTimeStart, cueIndex, WIN_SIZE_START);
        [Plot.Lick.RasterOutcome, Plot.Lick.PsthOutcome] = rasterPsth(lickTimeOutcome, cueIndex, WIN_SIZE_OUTCOME);
        
        [binTimeLick, binLick] = spikeBin(lickTimeOutcome, WIN_SIZE_START, BIN_WINDOW, BIN_STEP);
        Plot.Lick.RegOutcome = slideReg(binTimeLick, binLick(Trial.inTrial, :), cueIndex(Trial.inTrial, 2:3));
        
        
        
        
        %% calc roll, speed in time bin
        % variable for binning
        CONV_RESOLUTION = 30;
        TIME_BIN_SIZE = 0.5; % 0.5 second
        
        speedBin = 0:1:50;
        nSpeedBin = length(speedBin);
        speedPlotBin = 0.5:1:50.5;
        
        speedDiffBin = -0.8:0.05:0.8;
        nSpeedDiffBin = length(speedDiffBin);
        speedDiffPlotBin = -0.775:0.05:0.825;
        
        rollBin = -20:20;
        nRollBin = length(rollBin);
        rollPlotBin = -19.5:20.5;
        
        rollDiffBin = -0.4:0.05:0.4;
        nRollDiffBin = length(rollDiffBin);
        rollDiffPlotBin = -0.375:0.05:0.425;
        
        % convolute roll and speed
        rollConv = -conv(Vr.roll, fspecial('Gaussian', [1, 5*CONV_RESOLUTION], CONV_RESOLUTION), 'same')/10;
        rollDiff = diff([0; rollConv]);
        
        speedConv = conv(Vr.pitch, fspecial('Gaussian', [1, 5*CONV_RESOLUTION], CONV_RESOLUTION), 'same')/10;
        speedDiff = diff([0; speedConv]);
        
        timeBin = ceil(Vr.timeImec(1)):TIME_BIN_SIZE:floor(Vr.timeImec(end));
        nBin = length(timeBin);
        [~, timeIndex] = histc(Vr.timeImec, timeBin);
        
        [rollBinned, rollDiffBinned, speedBinned, speedDiffBinned] = deal(zeros(nBin, 1));
        for iBin = 1:nBin
            rollBinned(iBin) = mean(rollConv(timeIndex==iBin));
            rollDiffBinned(iBin) = mean(rollDiff(timeIndex==iBin));
            speedBinned(iBin) = mean(speedConv(timeIndex==iBin));
            speedDiffBinned(iBin) = mean(speedDiff(timeIndex==iBin));
        end
        
        [~, speedIndex] = histc(speedBinned, speedBin);
        [~, speedDiffIndex] = histc(speedDiffBinned, speedDiffBin);
        [~, rollIndex] = histc(rollBinned, rollBin);
        [~, rollDiffIndex] = histc(rollDiffBinned, rollDiffBin);
        
        % binned time and spike rate
        for iUnit = 1:Spike.nUnit
            disp([num2str(iUnit), ' / ', num2str(Spike.nUnit)]);
            
            spikeBinned = histc(Spike.time{iUnit}, timeBin);
            
            Plot.Spike.RollDiff(iUnit).x = rollDiffPlotBin;
            [Plot.Spike.RollDiff(iUnit).mean, Plot.Spike.Roll(iUnit).sse] = deal(zeros(1, nRollDiffBin));
            for iRoll = 1:nRollDiffBin
                Plot.Spike.RollDiff(iUnit).mean(iRoll) = mean(spikeBinned(rollDiffIndex==iRoll)) / TIME_BIN_SIZE;
                Plot.Spike.RollDiff(iUnit).sse(iRoll) = std(spikeBinned(rollDiffIndex==iRoll)) / (sqrt(sum(rollDiffIndex==iRoll))*TIME_BIN_SIZE);
            end
            
            Plot.Spike.Roll(iUnit).x = rollPlotBin;
            [Plot.Spike.Roll(iUnit).mean, Plot.Spike.Roll(iUnit).sse] = deal(zeros(1, nRollBin));
            for iRoll = 1:nRollBin
                Plot.Spike.Roll(iUnit).mean(iRoll) = mean(spikeBinned(rollIndex==iRoll)) / TIME_BIN_SIZE;
                Plot.Spike.Roll(iUnit).sse(iRoll) = std(spikeBinned(rollIndex==iRoll)) / (sqrt(sum(rollIndex==iRoll)) * TIME_BIN_SIZE);
            end
            
            Plot.Spike.Speed(iUnit).x = speedPlotBin;
            [Plot.Spike.Speed(iUnit).mean, Plot.Spike.Speed(iUnit).sse] = deal(zeros(1, nSpeedBin));
            for iSpeed = 1:nSpeedBin
                Plot.Spike.Speed(iUnit).mean(iSpeed) = mean(spikeBinned(speedIndex==iSpeed)) / TIME_BIN_SIZE;
                Plot.Spike.Speed(iUnit).sse(iSpeed) = std(spikeBinned(speedIndex==iSpeed)) / (sqrt(sum(speedIndex==iSpeed)) * TIME_BIN_SIZE);
            end
            
            Plot.Spike.SpeedDiff(iUnit).x = speedDiffPlotBin;
            [Plot.Spike.SpeedDiff(iUnit).mean, Plot.Spike.SpeedDiff(iUnit).sse] = deal(zeros(1, nSpeedDiffBin));
            for iSpeed = 1:nSpeedDiffBin
                Plot.Spike.SpeedDiff(iUnit).mean(iSpeed) = mean(spikeBinned(speedDiffIndex==iSpeed)) / TIME_BIN_SIZE;
                Plot.Spike.SpeedDiff(iUnit).sse(iSpeed) = std(spikeBinned(speedDiffIndex==iSpeed)) / (sqrt(sum(speedDiffIndex==iSpeed)) * TIME_BIN_SIZE);
            end
        end
        
        
        
        
        %% save file
        clc;
        save(dataFile{iD}, 'Plot', '-append');
    elseif strcmpi(choicePlot, 'cancel')
        return;
    end
end
slack('savePlot done');




function Out = alignDataEvent(data, timeData, timeTrial, winEdge, binSize)
narginchk(5, 5);

Out.t = winEdge(1):binSize:winEdge(2);
if isempty(timeTrial); Out.y = {}; return; end

nTime = length(Out.t);
nTrial = length(timeTrial);
Out.y = zeros(nTrial, nTime);

for iTrial = 1:nTrial
    if isnan(timeTrial(iTrial)); continue; end
    
    [~, ~, dataIndex] = histcounts(timeData, timeTrial(iTrial)+winEdge);
    if isempty(dataIndex); continue; end
    timeTemp = timeData(logical(dataIndex)) - timeTrial(iTrial);
    Out.y(iTrial, :) = interp1(timeTemp, double(data(logical(dataIndex))), Out.t, 'linear', 'extrap');
end
Out.yMean = nansum(Out.y, 1) / nTrial;
semTemp = nanstd(Out.y, 1) / sqrt(nTrial);
Out.ySem = [Out.yMean - semTemp, flip(Out.yMean + semTemp)];

function [yMean, ySem] = meanSem(y, n)
yMean = nansum(y, 1) / n;
semTemp = nanstd(y, 1) / sqrt(n);
ySem = [yMean - semTemp, flip(yMean + semTemp)];