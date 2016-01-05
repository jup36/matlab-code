function tagComparison(sessionFolder)

lineS = 0.2; % line width small
lineL = 1; % line width large
colorRed = [237 50 52] ./ 255;
markerS = 2.2;

eventFile = FindFiles('Events.nev','CheckSubdirs',0);
[timeStamp, eventString] = Nlx2MatEV(eventFile{1}, [1 0 0 0 1], 0, 1, []);
timeStamp = timeStamp'/1000;

recStart = find(strcmp(eventString,'Starting Recording'));
recEnd = find(strcmp(eventString,'Stopping Recording'));
tagTimeSoma = timeStamp([recStart(3),recEnd(3)]);
tagTimeAxon = timeStamp([recStart(4),recEnd(4)]);

tagIndexSoma = (timeStamp >= tagTimeSoma(1)) & (timeStamp <= tagTimeSoma(2));
tagIndexAxon = (timeStamp >= tagTimeAxon(1)) & (timeStamp <= tagTimeAxon(2));
redOnsetIndex(:,1) = strcmp(eventString, 'Red') & tagIndexSoma;
redOnsetIndex(:,2) = strcmp(eventString, 'Red') & tagIndexAxon;
redOnsetTime(:,1) = timeStamp(redOnsetIndex(:,1));
redOnsetTime(:,2) = timeStamp(redOnsetIndex(:,2));

ttFile = FindFiles('T*.t','CheckSubdirs',0);
ttData = LoadSpikes(ttFile,'tsflag','ts','verbose',0);
nFile = length(ttFile);
winTagRed = [-500 2000];
binSizeTagRed = 20;
resolution = 10;
testRangeRed = 400;
baseRangeRed = 4400;

for iFile = 1:nFile
    scrsz = get(groot,'ScreenSize');
    figure('Position',[scrsz(3)/4 scrsz(4)/4 scrsz(3)/2.5 scrsz(4)/2.5]);
    
    [cellPath,cellName,~] = fileparts(ttFile{iFile});
    figNameTemp = strsplit(cellPath,'\');
    figName = [figNameTemp{4},'_',figNameTemp{5},'_',cellName,'_tagComparison.tif'];
    
    spikeData = Data(ttData{iFile})/10;
    spikeTimeTagRed_soma = spikeWin(spikeData, redOnsetTime(:,1), winTagRed);
    spikeTimeTagRed_axon = spikeWin(spikeData, redOnsetTime(:,2), winTagRed);
    [xptTagRed_soma, yptTagRed_soma, psthtimeTagRed_soma,psthTagRed_soma,~,~] = rasterPSTH(spikeTimeTagRed_soma,true(size(redOnsetTime(:,1))),winTagRed,binSizeTagRed,resolution,1);
    [xptTagRed_axon, yptTagRed_axon, psthtimeTagRed_axon,psthTagRed_axon,~,~] = rasterPSTH(spikeTimeTagRed_axon,true(size(redOnsetTime(:,1))),winTagRed,binSizeTagRed,resolution,1);
    [p_tagRed_soma,time_tagRed_soma,H1_tagRed_soma,H2_tagRed_soma] = logRankTest(spikeData, redOnsetTime(:,1), testRangeRed, baseRangeRed);
    [p_tagRed_axon,time_tagRed_axon,H1_tagRed_axon,H2_tagRed_axon] = logRankTest(spikeData, redOnsetTime(:,2), testRangeRed, baseRangeRed);
        
    if ~isempty(redOnsetTime(:,1)) && ~isempty(xptTagRed_soma)
        nRedSoma = length(redOnsetTime(:,1));
        winRedSoma = [min(psthtimeTagRed_soma) max(psthtimeTagRed_soma)];
        
        hTagRedSoma(1) = axes('Position',axpt(2,3,1,1,[],[0.1 0.05]));
        plot(xptTagRed_soma{1},yptTagRed_soma{1},'LineStyle', 'none', 'Marker', '.', 'MarkerSize', markerS, 'Color', 'k');
        set(hTagRedSoma(1), 'XLim', winRedSoma, 'XTick', [], ...
            'YLim', [0 nRedSoma], 'YTick', [0 nRedSoma], 'YTickLabel', {[], nRedSoma});
        ylabel('Trials');
        
        hTagRedSoma(2) = axes('Position',axpt(2,3,1,2,[],[0.1 0.05]));
        hBarRed_soma = bar(psthtimeTagRed_soma,psthTagRed_soma,'histc');
        yLimBarRed_soma = ceil(max(psthTagRed_soma(:))*1.05+0.0001);
        %bar(250, 1000, 'BarWidth', 500, 'LineStyle', 'none', 'FaceColor', colorLightRed);
        rectangle('Position', [0 yLimBarRed_soma*0.925 500 yLimBarRed_soma*0.075], 'LineStyle', 'none', 'FaceColor', colorRed);
        set(hBarRed_soma, 'FaceColor','k', 'EdgeAlpha',0);
        set(hTagRedSoma(2), 'XLim', winRedSoma, 'XTick', [winRedSoma(1) 0 winRedSoma(2)], ...
           'YLim', [0 yLimBarRed_soma], 'YTick', [0 yLimBarRed_soma], 'YTickLabel', {[], yLimBarRed_soma});
        ylabel('Rate (Hz)');
        
        hTagRedSoma(3) = axes('Position',axpt(2,3,1,3,[],[0.1 0.05]));
        stairs(time_tagRed_soma,H2_tagRed_soma,'LineStyle',':', 'LineWidth', lineL, 'Color', 'k'); 
        hold on;
        stairs(time_tagRed_soma, H1_tagRed_soma, 'LineStyle','-', 'LineWidth', lineL, 'Color', colorRed);    
        ylimH = min([ceil(max([H1_tagRed_soma;H2_tagRed_soma])*1100+0.0001)/1000 1]);
        winHRed = [0 ceil(max(time_tagRed_soma))];
         text(winHRed(2)*0.5,ylimH*0.8,['p = ',num2str(p_tagRed_soma,3),' (log-rank)'],'Interpreter','none');
        set(hTagRedSoma(3), 'XLim', winHRed, 'XTick', winHRed, ...
            'YLim', [0 ylimH], 'YTick', [0 ylimH], 'YTickLabel', {[], ylimH});
        ylabel('H(t)');
        set(hTagRedSoma, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS);
        align_ylabel(hTagRedSoma)
    end
    
    if ~isempty(redOnsetTime(:,2)) && ~isempty(xptTagRed_axon)
        nRedAxon = length(redOnsetTime(:,2));
        winRedAxon = [min(psthtimeTagRed_axon) max(psthtimeTagRed_axon)];
        
        hTagRedAxon(1) = axes('Position',axpt(2,3,2,1,[],[0.1 0.05]));
        plot(xptTagRed_axon{1},yptTagRed_axon{1},'LineStyle', 'none', 'Marker', '.', 'MarkerSize', markerS, 'Color', 'k');
        set(hTagRedAxon(1), 'XLim', winRedAxon, 'XTick', [], ...
            'YLim', [0 nRedAxon], 'YTick', [0 nRedAxon], 'YTickLabel', {[], nRedAxon});
        
        hTagRedAxon(2) = axes('Position',axpt(2,3,2,2,[],[0.1 0.05]));
        hBarRed_axon = bar(psthtimeTagRed_axon,psthTagRed_axon,'histc');
        yLimBarRed_axon = ceil(max(psthTagRed_axon(:))*1.05+0.0001);
        %bar(250, 1000, 'BarWidth', 500, 'LineStyle', 'none', 'FaceColor', colorLightRed);
        rectangle('Position', [0 yLimBarRed_axon*0.925 500 yLimBarRed_axon*0.075], 'LineStyle', 'none', 'FaceColor', colorRed);
        set(hBarRed_axon, 'FaceColor','k', 'EdgeAlpha',0);
        set(hTagRedAxon(2), 'XLim', winRedAxon, 'XTick', [winRedAxon(1) 0 winRedAxon(2)], ...
           'YLim', [0 yLimBarRed_axon], 'YTick', [0 yLimBarRed_axon], 'YTickLabel', {[], yLimBarRed_axon});

        hTagRedAxon(3) = axes('Position',axpt(2,3,2,3,[],[0.1 0.05]));
        stairs(time_tagRed_axon,H2_tagRed_axon,'LineStyle',':', 'LineWidth', lineL, 'Color', 'k');
        hold on;
        stairs(time_tagRed_axon, H1_tagRed_axon, 'LineStyle','-', 'LineWidth', lineL, 'Color', colorRed); 
        ylimH = min([ceil(max([H1_tagRed_axon;H2_tagRed_axon])*1100+0.0001)/1000 1]);
        winHRed = [0 ceil(max(time_tagRed_axon))];
         text(winHRed(2)*0.5,ylimH*0.8,['p = ',num2str(p_tagRed_axon,3),' (log-rank)'], 'Interpreter','none');
        set(hTagRedAxon(3), 'XLim', winHRed, 'XTick', winHRed, ...
            'YLim', [0 ylimH], 'YTick', [0 ylimH], 'YTickLabel', {[], ylimH});
        set(hTagRedAxon, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS);
        align_ylabel(hTagRedAxon)
    end
    
    print(gcf,'-dtiff','-r300',figName);
    close;
    
end


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


function [xpt,ypt,spikeBin,spikeHist,spikeConv,spikeConvZ] = rasterPSTH(spikeTime, trialIndex, win, binSize, resolution, dot)
%rasterPSTH converts spike time into raster plot
%   spikeTime: cell array. each cell contains vector array of spike times per each trial. unit is msec
%   trialIndex: number of rows should be same as number of trials (length of spikeTime)
%   win: window range of xpt. should be 2 numbers. unit is msec.
%   binsize: unit is msec.
%   resolution: sigma for convolution = binsize * resolution.
%   dot: 1-dot, 0-line
%   unit of xpt will be msec.
narginchk(5, 6);
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
    if trialResult(iCue) == 0
        spikeHist(iCue,:) = NaN;
        spikeConv(iCue,:) = NaN;
        continue; 
    end
    
    % raster
    nSpikePerTrial = cellfun(@length,spikeTime(trialIndex(:,iCue)));
    nSpikeTotal = sum(nSpikePerTrial);
    if nSpikeTotal == 0; continue; end;
    
    spikeTemp = cell2mat(spikeTime(trialIndex(:,iCue)))';
    
    xptTemp = [spikeTemp;spikeTemp;NaN(1,nSpikeTotal)];
    if (nargin == 6) && (dot==1)
        xpt{iCue} = xptTemp(2,:);
    else
        xpt{iCue} = xptTemp(:);
    end

    yptTemp = [];
    for iy = 1:trialResult(iCue)
        yptTemp = [yptTemp repmat(yTemp(:,resultSum(iCue)+iy),1,nSpikePerTrial(iy))];
    end
    if (nargin == 6) && (dot==1)
        ypt{iCue} = yptTemp(2,:);
    else
        ypt{iCue} = yptTemp(:);
    end

    % psth
    spkhist_temp = histc(spikeTemp,spikeBin)/(binSize/10^3*trialResult(iCue));
    spkconv_temp = conv(spkhist_temp,fspecial('Gaussian',[1 5*resolution],resolution),'same');
%     spkconv_temp = ssvkernel(spikeTemp,spikeBin)*nSpikeTotal*1000/trialResult(iCue);
    spikeHist(iCue,:) = spkhist_temp;
    spikeConv(iCue,:) = spkconv_temp;
end

totalHist = histc(cell2mat(spikeTime),spikeBin)/(binSize/10^3*nTrial);
fireMean = mean(totalHist);
fireStd = std(totalHist);
spikeConvZ = (spikeConv-fireMean)/fireStd;


function [p,time,H1,H2] = logRankTest(spikeData, onsetTime, testRange, baseRange)
%logRankTest makes dataset for log-rank test
%   spikeData: raw data from MClust t file (in msec)
%   onsetTime: time of light stimulation (in msec)
%   testRange: binning time range for test (in msec)
%   baseRange: binning time range for baseline (in msec)
narginchk(4,4);
if isempty(onsetTime); p = []; time = []; H1 = []; H2 = []; return; end;

% if onsetTime interval is shorter than test+baseline range, omit.
outBin = find(diff(onsetTime)<=(testRange+baseRange));
outBin = [outBin;outBin+1];
onsetTime(outBin(:))=[];
if isempty(onsetTime); p = []; time = []; H1 = []; H2 = []; return; end;
nLight = length(onsetTime);

bin = [-floor(baseRange/testRange)*testRange:testRange:0];
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
base = [reshape(time(1:nBin,:),1,[]);reshape(censor(1:nBin,:),1,[])]';
test = [time(end,:);censor(end,:)]';

[p,time,H1,H2] = logrank(test,base);