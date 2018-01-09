function plotZigzag(dataFile)
% preset variable
DATA_PATH_LIST = {'E:'; ...
%     ['C:\Users\', getenv('USERNAME'), '\OneDrive - Howard Hughes Medical Institute\project\zigzag\data_ephys']; ...
%     'F:\zigzag\data_ephys', ...
    };

%% load event data
if nargin < 1 || exist(dataFile, 'file')==0
    nList = length(DATA_PATH_LIST);
    dataList = {};
    for iL = 1:nList
        dataListTemp = dir([DATA_PATH_LIST{iL}, '\*ap*_data.mat']);
        nData = length(dataListTemp);
        for iD = 1:nData
            dataList = [dataList; {fullfile(DATA_PATH_LIST{iL}, dataListTemp(iD).name)}];
        end
    end
    selection = listdlg('PromptString', 'Select a file', ...
        'SelectionMode', 'single', ...
        'ListSize', [500, 200], ...
        'ListString', dataList);
    
    if isempty(selection); return; end
    dataFile = dataList{selection};
end
option = str2double(dataFile(regexp(dataFile, 'opt\d')+3));

F = initPlot(option);
loadData(dataFile, F);

function F = initPlot(option)
if option==3
    nChannel = 384;
    referenceSite = [37 76 113 152 189 228 265 304 341 380];
elseif option==4
    nChannel = 276;
    referenceSite = [37 76 113 152 189 228 265];
end

% task variable
xLimStart = [-3 7];
xLimOutcome = [-5 5];

colorSpikeCue = {[0, 0, 0], [0, 0.6, 0], [0.6, 0, 0], [0.6, 0.6, 0.6], [0.6, 0.9, 0.6], [0.9, 0.6, 0.6]};
colorSpikeOutcome = {[0, 0, 0], [0.6, 0.6, 0.6]};

markerType = {'.', '+', '*'}; % p value 0.05, 0.01, 0.001

% plot variable
nX = 15; nY = 14;
figureMargin = [0.025, 0.05, 0.95, 0.9];
gapS = [0.01, 0.01];
gapM = [0.05, 0.05];
fontS = 6;
lineS = 0.35;
lineM = 0.7;
markerS = 2;

F = figure('Position', [384, 108, 1152, 864], ...
    'PaperSize', [11 8.5], 'PaperUnits', 'inches', 'PaperPosition', [0.5, 0.5, 10, 7.5], ...
    'KeyPressFcn', @keyPressFcn);

%% unit information
D.aText = axes(F, 'Position', axpt(10, 10, 1, 1:2, figureMargin), ...
    'Visible', 'off', 'XLim', [0 1], 'YLim', [0 1]);
D.pText = text(0, 1, '', ...
    'FontSize', fontS, 'VerticalAlignment', 'top');


%% silicon probe map
D.aProbe = axes(F, 'Position', axpt(15, 10, 1, 3:10, figureMargin), ...
    'Visible', 'off', 'XLim', [0, 60], 'YLim', [0, nChannel*10+12]);
hold(D.aProbe, 'on');
D.probeMap = zeros(nChannel, 2);
viHalf = 0:(nChannel/2-1);
D.probeMap(1:2:end, 2) = viHalf * 20;
D.probeMap(2:2:end, 2) = D.probeMap(1:2:end, 2);
D.probeMap(1:4:end,1) = 16;
D.probeMap(2:4:end,1) = 48;
D.probeMap(3:4:end,1) = 0;
D.probeMap(4:4:end,1) = 32;
pad = [12 12];
D.probeMap(referenceSite, :) = [];
nSite = size(D.probeMap, 1);

for iS = 1:nSite
    rectangle(D.aProbe, 'Position', [D.probeMap(iS, :), pad]);
end
D.pPosAll = plot(D.aProbe, NaN, NaN, ...
    'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 15, 'Color', [0.2 0.2 0.2]);
D.pPos = plot(D.aProbe, NaN, NaN, ...
    'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 20, 'Color', [1 0.2 0.2]);


%% waveform
D.aWaveform = axes(F, 'Position', axpt(15, 10, 2:3, 3:10, figureMargin));
D.pWaveform = plot(D.aWaveform, NaN, NaN, 'Color', 'k');
set(D.aWaveform, 'TickDir', 'out', 'FontSize', fontS, 'LineWidth', lineS, ...
    'XLim', [0, 64], 'XTick', [0, 16, 32, 48], 'XTickLabel', {});


%% ball speed
D = makeFigure(F, D, 'SpeedStart', 4:9, 1:2, xLimStart);
D = makeFigure(F, D, 'SpeedOutcome', 10:15, 1:2, xLimOutcome);

%% pitch speed
D = makeFigure(F, D, 'PitchStart', 4:9, 3:4, xLimStart);
D = makeFigure(F, D, 'PitchOutcome', 10:15, 3:4, xLimOutcome);

%% roll speed
D = makeFigure(F, D, 'RollStart', 4:9, 5:6, xLimStart);
D = makeFigure(F, D, 'RollOutcome', 10:15, 5:6, xLimOutcome);

%% lick rate
D = makeSpikeFigure(F, D, 'LickStart', 4:9, 7:9, xLimStart);
D = makeSpikeFigure(F, D, 'LickOutcome', 10:15, 7:9, xLimOutcome);

%% Spike
D = makeSpikeFigure(F, D, 'CueStart', 4:9, 10:12, xLimStart);
D = makeSpikeFigure(F, D, 'CueOutcome', 10:15, 10:12, xLimOutcome);

%% binned spike plots
% plot - speed vs fr
D.aSpikeSpeed = axes(F, 'Position', axpt(nX, nY, 4:6, 13:14, figureMargin, gapM), ...
    'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS);
hold(D.aSpikeSpeed, 'on');
xlabel(D.aSpikeSpeed, 'Pitch speed (cm/s)');
ylabel(D.aSpikeSpeed, 'Firing rate (Hz)');
D.pSpikeSpeed = errorbar(D.aSpikeSpeed, NaN, NaN, NaN, 'Color', 'k');

% plot - speedDiff vs fr
D.aSpikeSpeedDiff = axes(F, 'Position', axpt(nX, nY, 7:9, 13:14, figureMargin, gapM), ...
    'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS);
hold(D.aSpikeSpeedDiff, 'on');
xlabel(D.aSpikeSpeedDiff, 'Pitch acceleration (cm/s^2)');
ylabel(D.aSpikeSpeedDiff, 'Firing rate (Hz)');
D.pSpikeSpeedDiff = errorbar(D.aSpikeSpeedDiff, NaN, NaN, NaN, 'Color', 'k');

% plot - Roll acceleration vs fr
D.aSpikeRoll = axes(F, 'Position', axpt(nX, nY, 10:12, 13:14, figureMargin, gapM), ...
    'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS);
hold(D.aSpikeRoll, 'on');
xlabel(D.aSpikeRoll, 'Roll speed (cm/s)');
ylabel(D.aSpikeRoll, 'Firing rate (Hz)');
D.pSpikeRoll = errorbar(D.aSpikeRoll, NaN, NaN, NaN, 'Color', 'k');

% plot - Roll acceleration vs fr
D.aSpikeRollDiff = axes(F, 'Position', axpt(nX, nY, 13:15, 13:14, figureMargin, gapM), ...
    'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS);
hold(D.aSpikeRollDiff, 'on');
xlabel(D.aSpikeRollDiff, 'Roll acceleration (cm/s^2)');
ylabel(D.aSpikeRollDiff, 'Firing rate (Hz)');
D.pSpikeRollDiff = errorbar(D.aSpikeRollDiff, NaN, NaN, NaN, 'Color', 'k');

F.UserData = D;

function showData(F)
D = F.UserData;

%% unit info
[~, fileName] = fileparts(F.UserData.dataFile);
fileNameEnd = regexp(fileName, '_g._t.') -1;

D.pText.String = {fileName(1:fileNameEnd), ...
    ['Cell: ', num2str(D.iUnit)], ...
    ['X: ', num2str(D.Spike.posX(D.iUnit), 2), ' um, Y: ', num2str(D.Spike.posY(D.iUnit), 4), ' um'], ...
    ['Vmin: ', num2str(D.Spike.Vmin(D.iUnit), 3), ' uV'], ...
    ['Vpp: ', num2str(D.Spike.Vpp(D.iUnit), 3), ' uV'], ...
    ['SNR: ', num2str(D.Spike.snr(D.iUnit), 2)], ...
    ['ID: ', num2str(D.Spike.isolationDistance(D.iUnit), 2)], ...
    ['L-ratio: ', num2str(D.Spike.LRatio(D.iUnit), 2)], ...
    ['ISI-ratio: ', num2str(D.Spike.isiRatio(D.iUnit), 3)]};
D.pText.Interpreter = 'none';
D.pText.FontSize = 6;

%% probe map
D.pPos.XData = D.Spike.posX(D.iUnit)+6;
D.pPos.YData = D.Spike.posY(D.iUnit)+6;

% waveform
[waveformX, waveformY] = deal(NaN(1, 33*14));
for iW = 1:14
    waveformX(33*(iW-1)+(1:32)) = D.Spike.waveformSite{D.iUnit}(iW, 1) + (0:31)/2;
    waveformY(33*(iW-1)+(1:32)) = D.Spike.waveform(:, iW, D.iUnit)/8 + D.Spike.waveformSite{D.iUnit}(iW, 2);
end
D.pWaveform.XData = waveformX;
D.pWaveform.YData = waveformY;
D.aWaveform.YLim = [min(D.Spike.waveformSite{D.iUnit}(:, 2))-20, max(D.Spike.waveformSite{D.iUnit}(:, 2))+20];

% spike plots
plotSpike(D, 'Start');
plotSpike(D, 'Outcome');

% speed, roll
STR = {'Speed', 'Roll', 'SpeedDiff', 'RollDiff'};
for iS = 1:length(STR)
    D.(['pSpike', STR{iS}]).XData = D.Plot.Spike.(STR{iS})(D.iUnit).x;
    D.(['pSpike', STR{iS}]).YData = D.Plot.Spike.(STR{iS})(D.iUnit).mean;
    D.(['pSpike', STR{iS}]).YNegativeDelta = D.Plot.Spike.(STR{iS})(D.iUnit).sse;
    D.(['pSpike', STR{iS}]).YPositiveDelta = D.Plot.Spike.(STR{iS})(D.iUnit).sse;
    D.(['aSpike', STR{iS}]).YLim = [0, ceil(max(D.Plot.Spike.(STR{iS})(D.iUnit).mean + D.Plot.Spike.(STR{iS})(D.iUnit).sse))];
end

if D.iUnit == 1
    %% unit location in probe
    D.pPosAll.XData = D.Spike.posX+6;
    D.pPosAll.YData = D.Spike.posY+6;
    
    %% ball speed
    for iC = 1:3
        D.pSpeedStartFill(iC).XData = [D.Plot.Speed.Start.t, flip(D.Plot.Speed.Start.t)];
        D.pSpeedStartFill(iC).YData = D.Plot.Speed.Start.ySemCue(iC, :);
        set(D.pSpeedStartPlot(iC), 'XData', D.Plot.Speed.Start.t, 'YData', D.Plot.Speed.Start.yMeanCue(iC, :));
    end
    speedYLim = [0 ceil(min([50, max(D.Plot.Speed.Start.ySemCue(:))+0.1]))];
    set(D.aSpeedStart, 'YLim', speedYLim, 'YTick', speedYLim);
    
    pThreshold = [0.05, 0.01, 0.001, 0];
    yTemp = NaN(3, length(D.Plot.Speed.RegStart.time));
    for iP = 1:3
        D.pSpeedStartReg(iP).XData = D.Plot.Speed.RegStart.time;
        yTemp(iP, D.Plot.Speed.RegStart.pF < pThreshold(iP) & D.Plot.Speed.RegStart.pF >= pThreshold(iP+1)) = diff(speedYLim)*0.95+speedYLim(1);
        D.pSpeedStartReg(iP).YData = yTemp(iP, :);
    end
    
    for iR = 1:3
        D.pSpeedOutcomeFill(iR).XData = [D.Plot.Speed.Outcome.t, flip(D.Plot.Speed.Outcome.t)];
        D.pSpeedOutcomeFill(iR).YData = D.Plot.Speed.Outcome.ySemCue(iR, :);
        set(D.pSpeedOutcomePlot(iR), 'XData', D.Plot.Speed.Outcome.t, 'YData', D.Plot.Speed.Outcome.yMeanCue(iR, :));
    end
    speedYLim = [0 ceil(min([50, max(D.Plot.Speed.Outcome.ySemCue(:))+0.1]))];
    set(D.aSpeedOutcome, 'YLim', speedYLim, 'YTick', speedYLim);
    
    yTemp = NaN(3, length(D.Plot.Speed.RegOutcome.time));
    for iP = 1:3
        D.pSpeedOutcomeReg(iP).XData = D.Plot.Speed.RegOutcome.time;
        yTemp(iP, D.Plot.Speed.RegOutcome.pF < pThreshold(iP) & D.Plot.Speed.RegOutcome.pF >= pThreshold(iP+1)) = diff(speedYLim)*0.95+speedYLim(1);
        D.pSpeedOutcomeReg(iP).YData = yTemp(iP, :);
    end
    
    %% pitch speed
    for iC = 1:3
        D.pPitchStartFill(iC).XData = [D.Plot.Pitch.Start.t, flip(D.Plot.Pitch.Start.t)];
        D.pPitchStartFill(iC).YData = D.Plot.Pitch.Start.ySemCue(iC, :);
        set(D.pPitchStartPlot(iC), 'XData', D.Plot.Pitch.Start.t, 'YData', D.Plot.Pitch.Start.yMeanCue(iC, :));
    end
    pitchYLim = [floor(min(D.Plot.Pitch.Start.ySemCue(:))-0.1) ceil(min([400, max(D.Plot.Pitch.Start.ySemCue(:))+0.1]))];
    set(D.aPitchStart, 'YLim', pitchYLim, 'YTick', [pitchYLim(1), 0, pitchYLim(2)]);
    
    yTemp = NaN(3, length(D.Plot.Pitch.RegStart.time));
    for iP = 1:3
        D.pPitchStartReg(iP).XData = D.Plot.Pitch.RegStart.time;
        yTemp(iP, D.Plot.Pitch.RegStart.pF < pThreshold(iP) & D.Plot.Pitch.RegStart.pF >= pThreshold(iP+1)) = diff(pitchYLim)*0.95+pitchYLim(1);
        D.pPitchStartReg(iP).YData = yTemp(iP, :);
    end
    
    for iR = 1:3
        D.pPitchOutcomeFill(iR).XData = [D.Plot.Pitch.Outcome.t, flip(D.Plot.Pitch.Outcome.t)];
        D.pPitchOutcomeFill(iR).YData = D.Plot.Pitch.Outcome.ySemCue(iR, :);
        set(D.pPitchOutcomePlot(iR), 'XData', D.Plot.Pitch.Outcome.t, 'YData', D.Plot.Pitch.Outcome.yMeanCue(iR, :));
    end
    pitchYLim = [floor(min(D.Plot.Pitch.Start.ySemCue(:))-0.1) ceil(min([400, max(D.Plot.Pitch.Outcome.ySemCue(:))+0.1]))];
    set(D.aPitchOutcome, 'YLim', pitchYLim, 'YTick', [pitchYLim(1), 0, pitchYLim(2)]);
    
    yTemp = NaN(3, length(D.Plot.Pitch.RegOutcome.time));
    for iP = 1:3
        D.pPitchOutcomeReg(iP).XData = D.Plot.Pitch.RegOutcome.time;
        yTemp(iP, D.Plot.Pitch.RegOutcome.pF < pThreshold(iP) & D.Plot.Pitch.RegOutcome.pF >= pThreshold(iP+1)) = diff(pitchYLim)*0.95+pitchYLim(1);
        D.pPitchOutcomeReg(iP).YData = yTemp(iP, :);
    end
    
    %% roll speed
    for iC = 1:3
        D.pRollStartFill(iC).XData = [D.Plot.Roll.Start.t, flip(D.Plot.Roll.Start.t)];
        D.pRollStartFill(iC).YData = D.Plot.Roll.Start.ySemCue(iC, :);
        set(D.pRollStartPlot(iC), 'XData', D.Plot.Roll.Start.t, 'YData', D.Plot.Roll.Start.yMeanCue(iC, :));
    end
    rollYLim = [floor(min(D.Plot.Roll.Start.ySemCue(:))-0.1) ceil(max(D.Plot.Roll.Start.ySemCue(:))+0.1)];
    set(D.aRollStart, 'YLim', rollYLim, 'YTick', [rollYLim(1), 0, rollYLim(2)]);
    
    yTemp = NaN(3, length(D.Plot.Roll.RegStart.time));
    for iP = 1:3
        D.pRollStartReg(iP).XData = D.Plot.Roll.RegStart.time;
        yTemp(iP, D.Plot.Roll.RegStart.pF < pThreshold(iP) & D.Plot.Roll.RegStart.pF >= pThreshold(iP+1)) = diff(rollYLim)*0.95+rollYLim(1);
        D.pRollStartReg(iP).YData = yTemp(iP, :);
    end
    
    for iR = 1:3
        D.pRollOutcomeFill(iR).XData = [D.Plot.Roll.Outcome.t, flip(D.Plot.Roll.Outcome.t)];
        D.pRollOutcomeFill(iR).YData = D.Plot.Roll.Outcome.ySemCue(iR, :);
        set(D.pRollOutcomePlot(iR), 'XData', D.Plot.Roll.Outcome.t, 'YData', D.Plot.Roll.Outcome.yMeanCue(iR, :));
    end
    rollYLim = [floor(min(D.Plot.Roll.Outcome.ySemCue(:))-0.1) ceil(max(D.Plot.Roll.Outcome.ySemCue(:))+0.1)];
    set(D.aRollOutcome, 'YLim', rollYLim, 'YTick', [rollYLim(1), 0, rollYLim(2)]);
    
    yTemp = NaN(3, length(D.Plot.Roll.RegOutcome.time));
    for iP = 1:3
        D.pRollOutcomeReg(iP).XData = D.Plot.Roll.RegOutcome.time;
        yTemp(iP, D.Plot.Roll.RegOutcome.pF < pThreshold(iP) & D.Plot.Roll.RegOutcome.pF >= pThreshold(iP+1)) = diff(rollYLim)*0.95+rollYLim(1);
        D.pRollOutcomeReg(iP).YData = yTemp(iP, :);
    end
    
    
    %% lick
    for iC = 1:3
        D.pLickStartRaster(iC).XData = D.Plot.Lick.RasterStart.x{iC};
        D.pLickStartRaster(iC).YData = D.Plot.Lick.RasterStart.y{iC};
        
        D.pLickStartPsthPlot(iC).XData = D.Plot.Lick.PsthStart.x;
        D.pLickStartPsthPlot(iC).YData = D.Plot.Lick.PsthStart.conv(iC,:);
        D.pLickStartPsthFill(iC).XData = [D.Plot.Lick.PsthStart.x, flip(D.Plot.Lick.PsthStart.x)];
        D.pLickStartPsthFill(iC).YData = D.Plot.Lick.PsthStart.sem(iC,:);
    end
    rasterYLim = [0, max(D.pLickStartRaster(3).YData)];
    set(D.aLickStartRaster, 'YLim', rasterYLim, 'YTick', rasterYLim, 'YTickLabel', {'', rasterYLim(2)});
    psthYLim = [0, ceil(max(D.Plot.Lick.PsthStart.sem(:))+0.01)];
    set(D.aLickStartPsth, 'YLim', psthYLim, 'YTick', psthYLim, 'YTickLabel', {'', psthYLim(2)});
    
    for iC = 1:3
        D.pLickOutcomeRaster(iC).XData = D.Plot.Lick.RasterOutcome.x{iC};
        D.pLickOutcomeRaster(iC).YData = D.Plot.Lick.RasterOutcome.y{iC};
        
        D.pLickOutcomePsthPlot(iC).XData = D.Plot.Lick.PsthOutcome.x;
        D.pLickOutcomePsthPlot(iC).YData = D.Plot.Lick.PsthOutcome.conv(iC,:);
        D.pLickOutcomePsthFill(iC).XData = [D.Plot.Lick.PsthOutcome.x, flip(D.Plot.Lick.PsthOutcome.x)];
        D.pLickOutcomePsthFill(iC).YData = D.Plot.Lick.PsthOutcome.sem(iC,:);
    end
    rasterYLim = [0, max(D.pLickOutcomeRaster(3).YData)];
    set(D.aLickOutcomeRaster, 'YLim', rasterYLim, 'YTick', rasterYLim, 'YTickLabel', {'', rasterYLim(2)});
    psthYLim = [0, ceil(max(D.Plot.Lick.PsthOutcome.sem(:))+0.01)];
    set(D.aLickOutcomePsth, 'YLim', psthYLim, 'YTick', psthYLim, 'YTickLabel', {'', psthYLim(2)});
    
    yTemp = NaN(3, length(D.Plot.Lick.RegOutcome.time));
    for iP = 1:3
        D.pLickOutcomeReg(iP).XData = D.Plot.Lick.RegOutcome.time;
        yTemp(iP, D.Plot.Lick.RegOutcome.pF < pThreshold(iP) & D.Plot.Lick.RegOutcome.pF >= pThreshold(iP+1)) = diff(psthYLim)*0.95+psthYLim(1);
        D.pLickOutcomeReg(iP).YData = yTemp(iP, :);
    end
    
    set(D.aSpikeRollDiff, 'XLim', [-0.4, 0.4]);
    set(D.aSpikeRoll, 'XLim', [-20, 20]);
    set(D.aSpikeSpeed, 'XLim', [0, 40]);
end


function loadData(dataFile, F)
load(dataFile);

%% move to figure userdata
F.UserData.Spike = Spike;
F.UserData.Trial = Trial;
F.UserData.Vr = Vr;
F.UserData.Lick = Lick;

F.UserData.iUnit = 1;
F.UserData.nUnit = Spike.nUnit;

F.UserData.Plot = Plot;
F.UserData.dataFile = dataFile;

showData(F);


function D = makeFigure(F, D, varName, positionX, positionY, xLim)
colorSpikeCue = {[0, 0, 0], [0, 0.6, 0], [0.6, 0, 0], [0.6, 0.6, 0.6], [0.6, 0.9, 0.6], [0.9, 0.6, 0.6]};

markerType = {'.', '+', '*'}; % p value 0.05, 0.01, 0.001

nX = 15; nY = 14;
figureMargin = [0.025, 0.05, 0.95, 0.9];
gapS = [0.01, 0.01];
gapM = [0.05, 0.05];
fontS = 6;
lineS = 0.35;
lineM = 0.7;
markerS = 2;

D.(['a', varName]) = ...
    axes(F, 'Position', axpt(nX, nY, positionX, positionY, figureMargin, gapM), ...
    'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS, ...
    'XLim', xLim, 'XTick', [xLim(1), 0, xLim(2)], ...
    'YLim', [0 1], 'YTick', [0 1], 'YTickLabel', {[], 1});
hold(D.(['a', varName]), 'on');
title(D.(['a', varName]), varName);
for iC = 1:3
    D.(['p', varName, 'Fill'])(iC) = fill(D.(['a', varName]), NaN, NaN, colorSpikeCue{iC}, ...
       'LineStyle', 'none', 'FaceAlpha', 0.5);
    D.(['p', varName, 'Plot'])(iC) = plot(D.(['a', varName]), NaN, NaN, ...
       'Color', colorSpikeCue{iC}, 'LineWidth', lineM);
end

for iP = 1:3
    D.(['p', varName, 'Reg'])(iP) = plot(D.(['a', varName]), NaN, NaN, ...
        'Color', 'm', 'Marker', markerType{iP}, 'MarkerSize', markerS);
end


function D = makeSpikeFigure(F, D, varName, positionX, positionY, xLim)
colorSpikeCue = {[0, 0, 0], [0, 0.6, 0], [0.6, 0, 0], [0.6, 0.6, 0.6], [0.6, 0.9, 0.6], [0.9, 0.6, 0.6]};

markerType = {'.', '+', '*'}; % p value 0.05, 0.01, 0.001

nX = 15; nY = 14;
figureMargin = [0.025, 0.05, 0.95, 0.9];
gapS = [0.01, 0.01];
gapM = [0.05, 0.05];
fontS = 6;
lineS = 0.35;
lineM = 0.7;
markerS = 2;


D.(['a', varName, 'Raster']) = ...
    axes(F, 'Position', axpt(1, 2, 1, 1, axpt(nX, nY, positionX, positionY, figureMargin, gapM), gapS), ...
    'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS, ...
    'XLim', xLim, 'XTick', [], ...
    'YLim', [0 1], 'YTick', [0 1], 'YTickLabel', {[], 1});
hold(D.(['a', varName, 'Raster']), 'on');
title(D.(['a', varName, 'Raster']), varName);
for iC = 1:3
    D.(['p', varName, 'Raster'])(iC) = ...
        plot(D.(['a', varName, 'Raster']), NaN, NaN, 'Color', colorSpikeCue{iC}, 'LineWidth', 0.2);
end

D.(['a', varName, 'Psth']) = ...
    axes(F, 'Position', axpt(1, 2, 1, 2, axpt(nX, nY, positionX, positionY, figureMargin, gapM), gapS), ...
    'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS, ...
    'XLim', xLim, 'XTick', [xLim(1), 0, xLim(2)], ...
    'YLim', [0 1], 'YTick', [0 1], 'YTickLabel', {[], 1});
hold(D.(['a', varName, 'Psth']), 'on');
for iC = 1:3
    D.(['p', varName, 'PsthFill'])(iC) = fill(D.(['a', varName, 'Psth']), NaN, NaN, colorSpikeCue{iC}, ...
       'LineStyle', 'none', 'FaceAlpha', 0.5);
    D.(['p', varName, 'PsthPlot'])(iC) = plot(D.(['a', varName, 'Psth']), NaN, NaN, ...
       'Color', colorSpikeCue{iC}, 'LineWidth', lineM);
end

for iP = 1:3
    D.(['p', varName, 'Reg'])(iP) = plot(D.(['a', varName, 'Psth']), NaN, NaN, ...
        'Color', 'm', 'Marker', markerType{iP}, 'MarkerSize', markerS);
end


function plotSpike(D, varName)
yLimRaster = 1;
nType = length(D.Plot.Spike.(['RasterCue', varName])(1).x);
for iC = 1:nType
    D.(['pCue', varName, 'Raster'])(iC).XData = D.Plot.Spike.(['RasterCue', varName])(D.iUnit).x{iC};
    D.(['pCue', varName, 'Raster'])(iC).YData = D.Plot.Spike.(['RasterCue', varName])(D.iUnit).y{iC};
    D.(['pCue', varName, 'PsthPlot'])(iC).XData = D.Plot.Spike.(['PsthCue', varName])(D.iUnit).x;
    D.(['pCue', varName, 'PsthPlot'])(iC).YData = D.Plot.Spike.(['PsthCue', varName])(D.iUnit).conv(iC, :);
    D.(['pCue', varName, 'PsthFill'])(iC).XData = [D.Plot.Spike.(['PsthCue', varName])(D.iUnit).x, flip(D.Plot.Spike.(['PsthCue', varName])(D.iUnit).x)];
    D.(['pCue', varName, 'PsthFill'])(iC).YData = D.Plot.Spike.(['PsthCue', varName])(D.iUnit).sem(iC, :);
    
    yLimRaster = max([yLimRaster, D.(['pCue', varName, 'Raster'])(iC).YData]);
end
set(D.(['aCue', varName, 'Raster']), 'YLim', [0, yLimRaster], 'YTick', [0, yLimRaster], 'YTickLabel', {'', yLimRaster});
yLimPsth = max([1; D.Plot.Spike.(['PsthCue', varName])(D.iUnit).sem(:)]);
set(D.(['aCue', varName, 'Psth']), 'YLim', [0, yLimPsth], 'YTick', [0, yLimPsth], 'YTickLabel', {'', yLimPsth});

pThreshold = [0.05, 0.01, 0.001, 0];
yTemp = NaN(3, length(D.Plot.Spike.(['Reg', varName])(D.iUnit).time));
for iP = 1:3
    D.(['pCue', varName, 'Reg'])(iP).XData = D.Plot.Spike.(['Reg', varName])(D.iUnit).time;
    yTemp(iP, D.Plot.Spike.(['Reg', varName])(D.iUnit).pF < pThreshold(iP) & D.Plot.Spike.(['Reg', varName])(D.iUnit).pF >= pThreshold(iP+1)) = yLimPsth*0.95;
    D.(['pCue', varName, 'Reg'])(iP).YData = yTemp(iP, :);
end


function keyPressFcn(F, event)
switch lower(event.Key)
    case {'leftarrow', 'uparrow'}
        if F.UserData.iUnit > 1
            F.UserData.iUnit = F.UserData.iUnit - 1;
            showData(F);
        end
    case {'rightarrow', 'downarrow'}
        if F.UserData.iUnit < F.UserData.nUnit
            F.UserData.iUnit = F.UserData.iUnit + 1;
            showData(F);
        end
    case 'g'
        if strcmp(F.UserData.pCorrect.Visible, 'on')
            F.UserData.pCorrect.Visible = 'off';
            F.UserData.pWrong.Visible = 'off';
        else
            F.UserData.pCorrect.Visible = 'on';
            F.UserData.pWrong.Visible = 'on';
        end
    case 's'
        saveFigure(F);
end


function saveFigure(F)
SAVE_PATH = 'C:\Users\kimd11\OneDrive - Howard Hughes Medical Institute\project\neozig\result_cell_summary\';
[~, figureName] = fileparts(F.UserData.dataFile);
figureNameEnd = regexp(figureName, '_g0_t0') -1;
figureFile = [SAVE_PATH, figureName(1:figureNameEnd), '_', num2str(F.UserData.iUnit, '%02d'), '.tif'];

print(F, '-dtiff', '-r300', figureFile);
disp(['Saved ', figureFile]);