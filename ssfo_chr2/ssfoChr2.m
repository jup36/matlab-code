clc; clearvars; close all;
startFolder = 'C:\CheetahData';
sessionFolder = {uigetdir(startFolder, 'Choose session folder to analyse.')};

%% variable
binSize = 10;
resolution = 1;
wins = [-400 400];
win = [-350 350];
winTick = [-300 0 300];

fontS = 4; % font size small
fontM = 6; % font size middle
fontL = 8; % font size large
lineS = 0.2; % line width small
lineM = 0.5; % line width middle
lineL = 1; % line width large
markerS = 2;
markerM = 4;
markerL = 6;
tightInterval = [0.02 0.02];
wideInterval = [0.07 0.07];
colorBlue = [0 153 227] ./ 255;
colorLightBlue = [223 239 252] ./ 255;
colorRed = [237 50 52] ./ 255;
colorLightRed = [242 138 130] ./ 255;
colorGray = [204 204 204] ./ 255;

%% event load
[eData, eList] = eLoad(sessionFolder);
nL = length(eData.s);

ssfoBlueIndex = strcmp(eData.s,'ssfoBlue');
ssfoRedIndex = strcmp(eData.s,'ssfoRed');
chr2Index = strcmp(eData.s,'chr2');

index = ssfoBlueIndex | ssfoRedIndex | chr2Index;
tDiff = diff(eData.t(index));

ssfoIndex = abs(tDiff(ssfoBlueIndex(index))-600)<1;
chrIndex = abs(tDiff(chr2Index(index))-4700)<50;
ssfoChrIndex = abs(tDiff(chr2Index(index))-300)<1;

tSsfoBlue = eData.t(ssfoBlueIndex);
tChr = eData.t(chr2Index);

timeSsfo = tSsfoBlue(ssfoIndex) + 300;
timeChr = tChr(chrIndex);
timeSsfoChr = tChr(ssfoChrIndex);

eventTime = [timeSsfo, timeChr, timeSsfoChr];

%% t load
[tData, tList] = tLoad(sessionFolder);
nT = length(tList);
wv = wvformVar(sessionFolder);

for iT = 1:nT
    [cellDir,cellName,~] = fileparts(tList{iT});
    cellDirSplit = regexp(cellDir,'\','split');
    cellFigName = strcat(cellDirSplit(end-1),'_',cellDirSplit(end),'_',cellName);
    
    spikeTime = spikeWin(tData{iT}, eventTime, wins);
    fHandle = figure('PaperUnits','centimeters','PaperPosition',[0 0 18.3 13.725]);
    
    hText = axes('Position',axpt(1,2,1,1,axpt(10,10,1,1,[],wideInterval),tightInterval));
    hold on;
    text(0,1.2,tList{iT}, 'FontSize',fontL, 'Interpreter','none');
    set(hText,'Visible','off');

    % Waveform
    yLimWaveform = [min(wv(iT).spkwv(:)) max(wv(iT).spkwv(:))];
    hWaveform = zeros(1,4);
    for iCh = 1:4
        hWaveform(iCh) = axes('Position',axpt(4,2,iCh,2,axpt(3,4,1,1,[],wideInterval),tightInterval));
        plot(wv(iT).spkwv(iCh,:), 'LineWidth', lineL, 'Color','k');
        if iCh == 4
            line([24 32], [yLimWaveform(2)-50 yLimWaveform(2)-50], 'Color','k', 'LineWidth', lineM);
            line([24 24],[yLimWaveform(2)-50 yLimWaveform(2)], 'Color','k', 'LineWidth',lineM);
        end
    end
    set(hWaveform, 'Visible', 'off', ...
        'XLim',[1 32], 'YLim',yLimWaveform*1.05);
    
    yLimBar = 0;
    hPsth = zeros(1,3);
    for iE = 1:3
        [xpt, ypt, spikeBin, spikeHist, spikeConv, ~, spikeSem] = rasterPSTH(spikeTime(:,iE), true(100,1), wins, binSize, resolution, 1);
        
        hRaster = axes('Position', axpt(1,3,1,1,axpt(3,4,iE,2:4,[],wideInterval),tightInterval));
        hold on;
        if iE==1 || iE==3
            rectangle('Position', [-300 1 50 99], 'LineStyle', 'none', 'FaceColor', colorLightBlue);
            rectangle('Position', [300 1 10 99], 'LineStyle', 'none', 'FaceColor', colorLightRed);
        end
        if iE>=2
            rectangle('Position', [0 1 10 99], 'LineStyle', 'none', 'FaceColor', colorLightBlue);
        end
        plot(xpt{1}, ypt{1}, ...
            'LineStyle', 'none', 'Marker', '.', 'MarkerSize', markerS, 'Color', 'k');
        set(hRaster, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontM, ...
            'XLim', win, 'XTick', winTick, 'XTickLabel', {[],[],[]}, 'YLim', [0 100], 'YTick', [0 100], 'YTickLabel', {[], 100});
        if iE==1
            title('SSFO');
        elseif iE==2
            title('ChR_2');
        else
            title('SSFO+ChR_2');
        end
        
        hBar(iE) = axes('Position', axpt(1,3,1,2,axpt(3,4,iE,2:4,[],wideInterval),tightInterval));
        hold on;
        yLimBar = max([ceil(max(spikeHist)*1.05+0.0001), yLimBar]);
        hHist = bar(spikeBin, spikeHist, 'histc');
        set(hHist, 'FaceColor', 'k', 'EdgeAlpha', 0);
        
        hPsth(iE) = axes('Position', axpt(1,3,1,3,axpt(3,4,iE,2:4,[],wideInterval),tightInterval));
        hold on;
        fill([spikeBin flip(spikeBin)], spikeSem, colorGray, ...
            'LineStyle', 'none', 'FaceAlpha', 0.5);
        plot(spikeBin, spikeConv, ...
            'LineWidth', 1, 'Color', 'k');
        
        
    end
    set(hBar, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontM, ...
        'XLim', win, 'XTick', winTick, 'XTickLabel', {[],[],[]}, 'YLim', [0 yLimBar], 'YTick', [0 yLimBar], 'YTickLabel', {[], yLimBar});
    set(hPsth, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontM, ...
        'XLim', win, 'XTick', winTick, 'YLim', [0 yLimBar], 'YTick', [0 yLimBar], 'YTickLabel', {[], yLimBar});
    
    print(fHandle, '-dtiff', '-r300', [cellFigName{1},'.tif']);
    close;
end