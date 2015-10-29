function LickRatePlot(sessionFolder)
% LickRatePlot Draws raster and peth for licking rate

% variables
binSize = 0.01; % unit: second;
resolution = 10; % sigma = resolution * binSize = 100 ms
nType = 16;
nCue = 4;

lineClr = {[0.8 0 0], [0.8 0.4 0.4], [0.8 0 0], [0.8 0.4 0.4], ...
        [0 0 0.8], [0.4 0.4 0.8], [0 0 0.8], [0.4 0.4 0.8], ...
        [1 0.6 0], [1 1 0.4], [1 0.6 0], [1 1 0.4], ...
        [0 0.6 1], [0.4 1 1], [0 0.6 1], [0.4 1 1]};
lineStl = {'-', '-', ':', '--', ...
    '-', '-', ':', '--', ...
    '-', '-', '--', '--', ...
    '-', '-', '--', '--'};
lineWth = [2 0.5 0.5 0.5 2 0.5 0.5 0.5 1 0.5 0.5 0.5 1 0.5 0.5 0.5];

% function related
narginchk(0, 1);
if nargin == 0
    eventFile = FindFiles('Events.mat','CheckSubdirs',0);
elseif nargin == 1
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        eventFile = FindFiles('Events.mat','CheckSubdirs',0);
    else
        nFolder = length(sessionFolder);
        eventFile = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder},'dir')
                cd(sessionFolder{iFolder});
                eventFile = [eventFile;FindFiles('Events.mat','CheckSubdirs',1)];
            end
        end
    end
end
if isempty(eventFile)
    disp('Event file does not exist!');
    return;
end

nFile = length(eventFile);
for iFile = 1:nFile
    cd(fileparts(eventFile{iFile}));
    load(eventFile{iFile});
    
    lickWindow = [-1 maxTrialDuration+0.5];
    lickBin = -1:binSize:(maxTrialDuration+0.5);
    
    % licking raster / PETH
    trialResultSum = [0 cumsum(trialResult)];
    eventTimeType = zeros(nTrial,3);
    xLickTrial = cell(nTrial,1);
    yLickTrial = cell(nTrial,1);
    xLickRaster = cell(nType,1);
    yLickRaster = cell(nType,1);
    lickHist = zeros(nTrial, length(lickBin));
    for iType = 1:nType
        % raster
        if trialResult(iType)==0; continue; end;
        eventTimeType((trialResultSum(iType)+1):trialResultSum(iType+1),:) = eventTime(trialIndex(:,iType),[1 6 2]) / 1000;
        for iSubtrial = (trialResultSum(iType)+1):trialResultSum(iType+1)
            inTrial = (lickOnsetTime/1000 >= eventTimeType(iSubtrial,1)) & (lickOnsetTime/1000 < eventTimeType(iSubtrial,2));
            lickTime = lickOnsetTime(inTrial)/1000;
            [~,lickIndex] = histc(lickTime, eventTimeType(iSubtrial,3) + lickWindow);
            lickTemp = (lickTime(logical(lickIndex)) - eventTimeType(iSubtrial,3));

            nLick = length(lickTemp);
            xLickTemp = [lickTemp lickTemp  NaN(nLick,1)]';
            yLickTemp = [ones(nLick,1)*(iSubtrial-1) ones(nLick,1)*iSubtrial NaN(nLick,1)]';
            xLickTrial{iSubtrial} = xLickTemp(:);
            yLickTrial{iSubtrial} = yLickTemp(:);
            
            lickHist(iSubtrial,:) = histc(lickTemp, lickBin)/binSize;
        end
        xLickRaster{iType} = cell2mat(xLickTrial((trialResultSum(iType)+1):trialResultSum(iType+1)));
        yLickRaster{iType} = cell2mat(yLickTrial((trialResultSum(iType)+1):trialResultSum(iType+1)));
    end
    
    % aligned with cue
    lickMeanConv = zeros(nType, length(lickBin));
    lickSemConv = zeros(nType, length(lickBin));
    cueResultSum = [0 cumsum(cueResult)];
    for iCue = 1:nCue
        lickMean = mean(lickHist((cueResultSum(iCue)+1):cueResultSum(iCue+1),:));
        lickSem = std(lickHist((cueResultSum(iCue)+1):cueResultSum(iCue+1),:))/sqrt(cueResult(iCue));
        lickMeanConv(iCue,:) = conv(lickMean, fspecial('Gaussian', [1 5*resolution],resolution), 'same');
        lickSemConv(iCue,:) = conv(lickSem, fspecial('Gaussian', [1 5*resolution],resolution), 'same');
    end

    lickSemBin = [lickBin flip(lickBin)];
    lickSemConv = [lickMeanConv-lickSemConv flip(lickMeanConv+lickSemConv,2)];
    
    % licking statistics
    lickNum = zeros(nTrial,2);
    for iTrial = 1:nTrial
        lickNum(iTrial,:) = histc(lickOnsetTime,eventTime(iTrial,[2 4]));
    end
    lickNum = lickNum(:,1);
    [pRankSum4Cue] = ranksum(lickNum(cueIndex(:,1)),lickNum(cueIndex(:,2)));
%     [~,pTtest] = ttest2(lickNum(cueIndex(:,1)),lickNum(cueIndex(:,2)));
%     [b, dev, stats] = glmfit([2-cue cumsum(reward)],lickNum,'poisson');
    
    [lickReg,lickRegXpt] = sliding(lickHist,50,10);
    pValueReg = zeros(length(lickReg(1,:)),3);
    pValueRegIndex = zeros(length(lickReg(1,:)),3);
    for iRegBin = 1: length(lickReg(1,:))
        [~,~,stat] = glmfit([cue-1 reward modulation],lickReg(:,iRegBin),'normal');
        pValueReg(iRegBin,:) = stat.p(2:4)';
        pValueRegIndex(iRegBin,:) = stat.p(2:4)'<0.05;
        pValueRegIndex(iRegBin,pValueRegIndex(iRegBin,:)==0) = NaN;
    end


    save('Events.mat', ...
        'xLickRaster','yLickRaster', ...
        'lickHist','lickMean','lickSem','lickMeanConv','lickSemConv','-append');
    
    % plot part
    fHandle = figure('PaperUnits', 'centimeters', 'PaperPosition', [2 2 8.9 6.88]);
    hRaster = axes('Position',[0.1 0.55 0.8 0.4]);
    hold on;

    for iType = 1:nType
        if trialResult(iType)==0; continue; end;
        if mod(iType,2)==0
            rectangle('Position', [eventDuration(1) trialResultSum(iType) lickWindow(2) trialResult(iType)], 'LineStyle', 'none', 'FaceColor', [0.95 0.95 0.95]);
        end
        plot(xLickRaster{iType}, yLickRaster{iType}, ...
            'LineWidth', 0.3, 'Color', lineClr{iType});
    end
    plot([eventDuration(2) eventDuration(2)], [0 nTrial], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(3) eventDuration(3)], [0 nTrial], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(4) eventDuration(4)], [0 nTrial], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    set(hRaster, 'box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 5, ...
        'XLim', [lickWindow(1)+0.5 lickWindow(2)-0.5], 'XTick', [], ...
        'YLim', [0 nTrial], 'YTick', [0 nTrial]);
    ylabel('Trial');
    
    hPETH = axes('Position',[0.1 0.1 0.8 0.4]);
    hold on;
    yMax = ceil(max(lickSemConv(:)));
    
    plot([eventDuration(2) eventDuration(2)], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(3) eventDuration(3)], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(4) eventDuration(4)], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    rectangle('Position', [eventDuration(2) yMax*0.95 eventDuration(3)-eventDuration(2) yMax*0.05], 'LineStyle', 'none', 'FaceColor', [1 0.79 0.22]);
    rectangle('Position', [eventDuration(4) yMax*0.95 0.1 yMax*0.05], 'LineStyle', 'none', 'FaceColor', [0 0.45 0.74]);
    for jCue = 1:nCue
        if cueResult(jCue)==0; continue; end;
        fill(lickSemBin, lickSemConv(jCue,:), lineClr{jCue*4-3}, 'LineStyle', 'none','FaceAlpha',0.2);
        plot(lickBin, lickMeanConv(jCue,:), ...
            'LineStyle', lineStl{jCue*4-3}, 'Color', lineClr{jCue*4-3}, 'LineWidth', lineWth(jCue*4-3));
    end
    text(lickWindow(2)*0.8, yMax*0.8, ['p = ',num2str(pRankSum4Cue,3)], 'FontSize',5);
    set(gca, 'box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 5, ...
        'XLim', [lickWindow(1)+0.5 lickWindow(2)-0.5], 'XTick', [eventDuration(1:4) lickWindow(2)-0.5], 'XTickLabel', {'', eventDuration(2), eventDuration(3), eventDuration(4), ''}, ...
        'YLim', [0 yMax], 'YTick', [0 yMax]);
    xlabel('Time after cue onset');
    ylabel('Lick/s');
    
    cd('..');
    cellcd = strsplit(fileparts(eventFile{iFile}),'\');
    cellfile = strcat(cellcd(end-1),'_',cellcd(end),'_lickplot');
    print(fHandle,'-dtiff','-r600',[cellfile{1},'.tif']);
    cd(fileparts(eventFile{iFile}));
end
close all;