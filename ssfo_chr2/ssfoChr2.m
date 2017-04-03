function ssfoChr2(startFolder)
clc; close all;
if nargin==0
    startFolder = 'C:\CheetahData';
end
sessionFolder = {uigetdir(startFolder, 'Choose session folder to analyse.')};


%% variable
binSize = 10;
resolution = 1;
wins = [-400 400];
win = [-350 350];
winTick = [-300 0 300];

testRangeSsfo = 100;
baseRangeSsfo = [-2500+600+100, 0];

testRangeChr2 = 100;
baseRangeChr2 = [-2500+300+100, 0];

testRangeSsfoChr2 = 100;
dt = 1;


%% plot variable
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
colorYellow = [0 128 0] ./ 255;

cumbase = {'k', 'k', colorBlue};
cumtest = {colorYellow, colorBlue, colorRed};


%% event load
[eData, eList] = eLoad(sessionFolder);
nL = length(eData.s);

ssfoBlueIndex = strcmp(eData.s,'ssfoBlue');
ssfoRedIndex = strcmp(eData.s,'ssfoRed');
chr2Index = strcmp(eData.s,'chr2');

index = ssfoBlueIndex | ssfoRedIndex | chr2Index;
tDiff = diff(eData.t(index));

ssfoIndex = abs(tDiff(ssfoBlueIndex(index))-600)<1;
chrIndex = abs(tDiff(chr2Index(index))-2200)<50;
ssfoChrIndex = abs(tDiff(chr2Index(index))-300)<1;

tSsfoBlue = eData.t(ssfoBlueIndex);
tChr = eData.t(chr2Index);

timeSsfo = tSsfoBlue(ssfoIndex) + 300;
timeChr = tChr(chrIndex);
timeSsfoChr = tChr(ssfoChrIndex);

eventTime = [timeSsfo, timeChr, timeSsfoChr];
nEvent = size(eventTime, 1);


%% t load
[tData, tList] = tLoad(sessionFolder);
nT = length(tList);
wv = wvformVar(sessionFolder);

fclose('all');

for iT = 1:nT
    [cellDir,cellName,~] = fileparts(tList{iT});
    cellDirSplit = regexp(cellDir,'\','split');
    cellFigName = strcat(cellDirSplit(end-1),'_',cellDirSplit(end),'_',cellName);
    
   
    %% plot
    fHandle = figure('PaperUnits','centimeters','PaperPosition',[0 0 18.3 13.725]);
    
    % cell name
    hText = axes('Position',axpt(1,2,1,1,axpt(10,10,1,1,[],wideInterval),tightInterval));
    hold on;
    text(0,1.2,tList{iT}, 'FontSize',fontL, 'Interpreter','none');
    set(hText,'Visible','off');

    % waveform
    yLimWaveform = [min(wv(iT).spkwv(:)) max(wv(iT).spkwv(:))];
    hWaveform = zeros(1,4);
    for iCh = 1:4
        hWaveform(iCh) = axes('Position',axpt(4,2,iCh,2,axpt(5,4,1,1,[],wideInterval),tightInterval));
        plot(wv(iT).spkwv(iCh,:), 'LineWidth', lineL, 'Color','k');
        if iCh == 4
            line([24 32], [yLimWaveform(2)-50 yLimWaveform(2)-50], 'Color','k', 'LineWidth', lineM);
            line([24 24],[yLimWaveform(2)-50 yLimWaveform(2)], 'Color','k', 'LineWidth',lineM);
        end
    end
    set(hWaveform, 'Visible', 'off', ...
        'XLim',[1 32], 'YLim',yLimWaveform*1.05);
    

    spikeTime = spikeWin(tData{iT}, eventTime, wins);
    yLimBar = 0;
    [hRaster, hPsth, hSdf, hLogrank] = deal(zeros(1,3));
    for iE = 1:3
        [xpt, ypt, spikeBin, spikeHist, spikeConv, ~, spikeSem] = rasterPSTH(spikeTime(:,iE), true(nEvent,1), wins, binSize, resolution, 1);
        
        % raster
        hRaster(iE) = axes('Position', axpt(1,5,1,1,axpt(4,12,iE+1,2:12,[],wideInterval),tightInterval));
        hold on;
        if iE==1 || iE==3
            rectangle('Position', [-300 1 50 nEvent], 'LineStyle', 'none', 'FaceColor', colorLightBlue);
            rectangle('Position', [300 1 10 nEvent], 'LineStyle', 'none', 'FaceColor', colorLightRed);
        end
        if iE>=2
            rectangle('Position', [0 1 10 nEvent], 'LineStyle', 'none', 'FaceColor', colorLightBlue);
        end
        plot(xpt{1}, ypt{1}, ...
            'LineStyle', 'none', 'Marker', '.', 'MarkerSize', markerS, 'Color', 'k');
        if iE==1
            title('SSFO','Color', colorYellow);
            ylabel('Trial', 'FontSize', fontS);
        elseif iE==2
            title('ChR_2', 'Color', colorBlue);
        else
            title('SSFO+ChR_2', 'Color', colorRed);
        end
        
        % psth
        hPsth(iE) = axes('Position', axpt(1,5,1,2,axpt(4,12,iE+1,2:12,[],wideInterval),tightInterval));
        hold on;
        yLimBar = max([ceil(max(spikeHist)*1.05+0.0001), yLimBar]);
        if ~isempty(spikeBin)
            hHist = bar(spikeBin, spikeHist, 'histc');
        else
            hHist = bar(0);
        end
        set(hHist, 'FaceColor', 'k', 'EdgeAlpha', 0);
        if iE==1; ylabel('Spike/s', 'FontSize', fontS); end;
        
        % sdf
        hSdf(iE) = axes('Position', axpt(1,5,1,3,axpt(4,12,iE+1,2:12,[],wideInterval),tightInterval));
        hold on;
        fill([spikeBin flip(spikeBin)], spikeSem, colorGray, ...
            'LineStyle', 'none', 'FaceAlpha', 0.5);
        plot(spikeBin, spikeConv, ...
            'LineWidth', 1, 'Color', 'k');
        if iE==1; ylabel('Spike/s', 'FontSize', fontS); end;
        
        % log rank
        hLogrank(iE) = axes('Position', axpt(1,21,1,14:17,axpt(4,12,iE+1,2:12,[],wideInterval),tightInterval));
        hold on;
        if iE==1
            [firstTimeSsfo, censorSsfo] = tagDataLoad(tData{iT}, tSsfoBlue, testRangeSsfo, baseRangeSsfo);
            [pSsfo,tSsfo,H1Ssfo,H2Ssfo] = logRankTest(firstTimeSsfo, censorSsfo);
            saltSsfo = saltTest(firstTimeSsfo, testRangeSsfo, dt);
            
            yLimH = min([ceil(max([H1Ssfo;H2Ssfo])*1100+0.0001)/1000 1]);
            winH = [0 testRangeSsfo];
            stairs(tSsfo, H2Ssfo, 'LineStyle', ':', 'LineWidth', lineM, 'Color', 'k');
            stairs(tSsfo, H1Ssfo, 'LineStyle', '-', 'LineWidth', lineL, 'Color', colorYellow);
            text(winH(2)*0.1,yLimH*0.95,['p = ',num2str(pSsfo,3),' (log-rank)'],'FontSize',fontS,'Interpreter','none');
            text(winH(2)*0.1,yLimH*0.85,['p = ',num2str(saltSsfo,2),' (salt)'],'FontSize',fontS,'Interpreter','none');
            set(hLogrank(iE), 'XLim', winH, 'XTick', winH, 'XTickLabel', {[], []}, ...
                'YLim', [0 yLimH], 'YTick', [0 yLimH], 'YTickLabel', {[], yLimH});
            ylabel('H(t)','FontSize', fontS);
        elseif iE==2
            [firstTimeChr2, censorChr2] = tagDataLoad(tData{iT}, timeChr, testRangeChr2, baseRangeChr2); 
            [pChr2,tChr2,H1Chr2,H2Chr2] = logRankTest(firstTimeChr2, censorChr2); 
            saltChr2 = saltTest(firstTimeChr2, testRangeChr2, dt);
            
            yLimH = min([ceil(max([H1Chr2;H2Chr2])*1100+0.0001)/1000 1]);
            winH = [0 testRangeChr2];
            stairs(tChr2, H2Chr2, 'LineStyle', ':', 'LineWidth', lineM, 'Color', 'k');
            stairs(tChr2, H1Chr2, 'LineStyle', '-', 'LineWidth', lineL, 'Color', colorBlue);
            text(winH(2)*0.1,yLimH*0.95,['p = ',num2str(pChr2,3),' (log-rank)'],'FontSize',fontS,'Interpreter','none');
            text(winH(2)*0.1,yLimH*0.85,['p = ',num2str(saltChr2,2),' (salt)'],'FontSize',fontS,'Interpreter','none');
            set(hLogrank(iE), 'XLim', winH, 'XTick', winH, 'XTickLabel', {[], []}, ...
                'YLim', [0 yLimH], 'YTick', [0 yLimH], 'YTickLabel', {[], yLimH});
        elseif iE==3
            testSsfoChr2 = findFirstSpike(tData{iT}, timeSsfoChr, testRangeSsfoChr2);
            baseChr2 = findFirstSpike(tData{iT}, timeChr, testRangeSsfoChr2);
            baseSsfo = findFirstSpike(tData{iT}, timeSsfo, testRangeSsfoChr2);

            [pSsfoChr2,tSsfoChr2,H1SsfoChr2,H2SsfoChr2] = logrank(testSsfoChr2',baseChr2');
            [pSsfoChr2Ssfo, tSsfoChr2Ssfo, H1SsfoChr2Ssfo, H2SsfoChr2Ssfo] = logrank(testSsfoChr2', baseSsfo');
          
            yLimH = min([ceil(max([H1SsfoChr2;H2SsfoChr2;H2SsfoChr2Ssfo])*1100+0.0001)/1000 1]);
            winH = [0 testRangeSsfoChr2];
            stairs(tSsfoChr2Ssfo, H2SsfoChr2Ssfo, 'LineStyle', ':', 'LineWidth', lineM, 'Color', colorYellow);
            stairs(tSsfoChr2, H2SsfoChr2, 'LineStyle', ':', 'LineWidth', lineM, 'Color', colorBlue);
            stairs(tSsfoChr2, H1SsfoChr2, 'LineStyle', '-', 'LineWidth', lineL, 'Color', colorRed);
            text(winH(2)*0.25,yLimH*0.20,['p = ',num2str(pSsfoChr2,3),' (log-rank, SSFO+ChR2 vs ChR2)'],'FontSize',fontS,'Interpreter','none');

            text(winH(2)*0.25,yLimH*0.10,['p = ',num2str(pSsfoChr2Ssfo,3),' (log-rank, SSFO+ChR2 vs SSFO)'],'FontSize',fontS,'Interpreter','none');
            set(hLogrank(iE), 'XLim', winH, 'XTick', winH, 'XTickLabel', {[], []}, ...
                'YLim', [0 yLimH], 'YTick', [0 yLimH], 'YTickLabel', {[], yLimH});
        end

        % cumulative spike
        hCum(iE) = axes('Position', axpt(1,21,1,18:21,axpt(4,12,iE+1,2:12,[],wideInterval),tightInterval));
        hold on;
        if iE==1
            cumSp = cumSpike2(tData{iT}, tSsfoBlue, testRangeSsfo, baseRangeSsfo);
            ylabel('Cumulative spike', 'FontSize', fontS);
            winCum = [0 testRangeSsfo];
        elseif iE==2
            cumSp = cumSpike2(tData{iT}, timeChr, testRangeChr2, baseRangeChr2);
            winCum = [0 testRangeChr2];
        elseif iE==3
            cumSp = cumSpike(tData{iT}, timeSsfoChr, timeChr, testRangeSsfoChr2);
            cumSp2 = cumSpike(tData{iT}, timeSsfoChr, timeSsfo, testRangeSsfoChr2);
            winCum = [0 testRangeSsfoChr2];
        end
        
        if ~isempty(cumSp)
            yLimCum = max([ceil(max([cumSp.base(:,2); cumSp.test(:,2)])*110+0.0001)/100,0.01]);
            if iE==3
                stairs(cumSp2.base(:,1), cumSp2.base(:,2), 'LineStyle', ':', 'LineWidth', lineM, 'Color', colorYellow);
            end
            stairs(cumSp.base(:,1), cumSp.base(:,2), 'LineStyle', ':', 'LineWidth', lineM, 'Color', cumbase{iE});
            stairs(cumSp.test(:,1), cumSp.test(:,2), 'LineStyle', '-', 'LineWidth', lineL, 'Color', cumtest{iE});
            set(hCum(iE), 'XLim', winCum, 'XTick', winCum, ...
                'YLim', [0 yLimCum], 'YTick', [0 yLimCum], 'YTickLabel', {[], yLimCum});
        end
            xlabel('Time (ms)', 'FontSize', fontS);
    end
    if yLimBar == 0; yLimBar = 1; end;
    set(hRaster, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontM, ...
        'XLim', win, 'XTick', winTick, 'XTickLabel', {[],[],[]}, 'YLim', [0 nEvent], 'YTick', [0 nEvent], 'YTickLabel', {[], nEvent});
    set(hPsth, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontM, ...
        'XLim', win, 'XTick', winTick, 'XTickLabel', {[],[],[]}, 'YLim', [0 yLimBar], 'YTick', [0 yLimBar], 'YTickLabel', {[], yLimBar});
    set(hSdf, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontM, ...
        'XLim', win, 'XTick', winTick, 'YLim', [0 yLimBar], 'YTick', [0 yLimBar], 'YTickLabel', {[], yLimBar});
    set(hLogrank, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontM);
    set(hCum, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontM);
    
    align_ylabel([hRaster(1), hPsth(1), hSdf(1), hLogrank(1), hCum(1)]);
    
    print(fHandle, '-dtiff', '-r300', fullfile(cellDir,[cellFigName{1},'.tif']));
    close;
end

function [time, censor] = tagDataLoad(spikeData, onsetTime, testRange, baseRange)
%tagDataLoad makes dataset for statistical tests
%   spikeData: raw data from MClust t file (in msec)
%   onsetTime: time of light stimulation (in msec)
%   testRange: binning time range for test (in msec)
%   baseRange: binning time range for baseline --> [startTime endTime] (in msec)
%
%   time: nBin (nBin-1 number of baselines and 1 test) x nLightTrial
%
narginchk(4,4);
if isempty(onsetTime); time = []; censor = []; return; end;

% If onsetTime interval is shorter than test+baseline range, omit.
outBin = find(diff(onsetTime)<=(testRange-baseRange(1)));
outBin = [outBin;outBin+1];
onsetTime(outBin(:))=[];
if isempty(onsetTime); time = []; censor = []; return; end;
nLight = length(onsetTime);

% Rearrange data
bin = [ceil(baseRange(1)/testRange)*testRange:testRange:floor(baseRange(2)/testRange)];
nBin = length(bin);

binMat = ones(nLight,nBin)*diag(bin);
lightBin = (repmat(onsetTime',nBin,1)+binMat');
time = zeros(nBin,nLight);
censor = zeros(nBin,nLight);

for iLight=1:nLight
    for iBin=1:nBin
        idx = find(spikeData > lightBin(iBin,iLight), 1, 'first');
        if isempty(idx)
            time(iBin,iLight) = testRange;
            censor(iBin,iLight) = 1;
        else
            time(iBin,iLight) = spikeData(idx) - lightBin(iBin,iLight);
            if time(iBin,iLight) > testRange
                time(iBin,iLight) = testRange;
                censor(iBin,iLight) = 1;
            end
        end     
    end
end


function timeCensor = findFirstSpike(spikeData, onsetTime, testRange)
nLight = length(onsetTime);
timeCensor = zeros(2, nLight);

for iLight=1:nLight
    idx = find(spikeData > onsetTime(iLight), 1, 'first');
    if isempty(idx)
        timeCensor(1,iLight) = testRange;
        timeCensor(2,iLight) = 1;
    else
        timeCensor(1,iLight) = spikeData(idx) - onsetTime(iLight);
        if timeCensor(1,iLight) > testRange
            timeCensor(1,iLight) = testRange;
            timeCensor(2,iLight) = 1;
        end
    end     
end


function [p,time,H1,H2] = logRankTest(time, censor)
%logRankTest makes dataset for log-rank test

if isempty(time) || isempty(censor); p = []; time = []; H1 = []; H2 = []; return; end;

base = [reshape(time(1:(end-1),:),1,[]);reshape(censor(1:(end-1),:),1,[])]';
test = [time(end,:);censor(end,:)]';

[p,time,H1,H2] = logrank(test,base);


function [p, l] = saltTest(time, wn, dt)
if isempty(time) ; p = []; l= []; return; end;

base = time(1:(end-1),:)';
test = time(end,:)';

[p, l] = salt2(test, base, wn, dt);


function cumSpike = cumSpike(spikeData, onsetTimeTest, onsetTimeBase, testRange)
narginchk(4,4);
if isempty(onsetTimeTest) | isempty(onsetTimeBase); cumSpike = []; return; end;

nTest = length(onsetTimeTest);
nBase = length(onsetTimeBase);

% get cumulative curve
spikeTimeTest = spikeWin(spikeData, onsetTimeTest, [0 testRange]);
spikeTimeBase = spikeWin(spikeData, onsetTimeBase, [0 testRange]);
base = sort(cell2mat(spikeTimeBase));
nBaseX = length(base);
base = [base, (1:nBaseX)'/nBase];

test = sort(cell2mat(spikeTimeTest));
nTestX = length(test);
test = [test, (1:nTestX)'/nTest];
cumSpike = struct('base', base, 'test', test);


function cumSpike = cumSpike2(spikeData, onsetTime, testRange, baseRange)
narginchk(4,4);
if isempty(onsetTime); cumSpike = []; return; end;

% If onsetTime interval is shorter than test+baseline range, omit.
outBin = find(diff(onsetTime)<=(testRange-baseRange(1)));
outBin = [outBin;outBin+1];
onsetTime(outBin(:))=[];
if isempty(onsetTime); cumSpike = []; return; end;
nLight = length(onsetTime);

% Rearrange data
bin = [ceil(baseRange(1)/testRange)*testRange:testRange:floor(baseRange(2)/testRange)];
nBin = length(bin);

binMat = ones(nLight,nBin)*diag(bin);
lightBin = (repmat(onsetTime',nBin,1)+binMat');

% get cumulative curve
spikeTime = spikeWin(spikeData, lightBin, [0 testRange]);
baseSpike = spikeTime(1:end-1, :);
base = sort(cell2mat(baseSpike(:)));
nBaseX = length(base);
base = [base, (1:nBaseX)'/nLight/(nBin-1)];
test = sort(cell2mat(spikeTime(end, :)'));
nTestX = length(test);
test = [test, (1:nTestX)'/nLight];
cumSpike = struct('base', base, 'test', test);