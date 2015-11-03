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
lineStl = {'-', '--', '-', '--', ...
    '-', '--', '-', '--', ...
    '-', '--', '-', '--', ...
    '-', '--', '-', '--'};
lineWth = [2 2 2 2 2 2 2 2 1 0.5 0.5 0.5 1 0.5 0.5 0.5];

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
    
    types = 1:nType;
    trialResultSum2Reward = zeros(1,nType);
    trialResultSum2Reward(mod(types,4)==1 | mod(types,4)==2) = cumsum(trialResult(find(mod(types,4)==1 | mod(types,4)==2)));
    trialResultSum2Reward(mod(types,4)==3 | mod(types,4)==0) = cumsum(trialResult(find(mod(types,4)==3 | mod(types,4)==0)));
    trialResultSum2Reward = [0 trialResultSum2Reward];
    
    for iType = 1:nType
        % raster
        if trialResult(iType)==0; continue; end;
        eventTimeType((trialResultSum(iType)+1):trialResultSum(iType+1),:) = eventTime(trialIndex(:,iType),[1 6 2]) / 1000;
        for iSubtrial = (trialResultSum(iType)+1):trialResultSum(iType+1)
            inTrial = (lickOnsetTime/1000 >= eventTimeType(iSubtrial,1)) & (lickOnsetTime/1000 < eventTimeType(iSubtrial,2));
            lickTime = lickOnsetTime(inTrial)/1000;
            lickTemp = lickTime - eventTimeType(iSubtrial,3);

            nLick = length(lickTemp);
            xLickTemp = [lickTemp lickTemp  NaN(nLick,1)]';
            if iType==1 || iType==3;
                yLickTemp = [ones(nLick,1)*(iSubtrial-(trialResultSum(iType)+1)) ones(nLick,1)*(iSubtrial-(trialResultSum(iType)+1)+1) NaN(nLick,1)]';
            elseif mod(iType,4)==2 || mod(iType,4)==0;
                yLickTemp = [ones(nLick,1)*(iSubtrial-(trialResultSum(iType)+1)+trialResultSum2Reward(iType)),...
                    ones(nLick,1)*(iSubtrial-(trialResultSum(iType)+1)+trialResultSum2Reward(iType)+1) NaN(nLick,1)]';
            else
                yLickTemp = [ones(nLick,1)*(iSubtrial-(trialResultSum(iType)+1)+trialResultSum2Reward(iType-2)),...
                    ones(nLick,1)*(iSubtrial-(trialResultSum(iType)+1)+trialResultSum2Reward(iType-2)+1) NaN(nLick,1)]';
            end
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
    for iType = 1:nType
        lickMean = mean(lickHist((trialResultSum(iType)+1):trialResultSum(iType+1),:));
        lickSem = std(lickHist((trialResultSum(iType)+1):trialResultSum(iType+1),:))/sqrt(trialResult(iType));
        lickMeanConv(iType,:) = conv(lickMean, fspecial('Gaussian', [1 5*resolution],resolution), 'same');
        lickSemConv(iType,:) = conv(lickSem, fspecial('Gaussian', [1 5*resolution],resolution), 'same');
    end

    lickSemBin = [lickBin flip(lickBin)];
    lickSemConv = [lickMeanConv-lickSemConv flip(lickMeanConv+lickSemConv,2)];
    
    % licking statistics
    warning('off');
    lickNum = zeros(nTrial,2);
    for iTrial = 1:nTrial
        lickNum(iTrial,:) = histc(lickOnsetTime,eventTime(iTrial,[2 4]));
    end
    lickNum = lickNum(:,1);
    [pRankSum4Cue] = ranksum(lickNum(cueIndex(:,1)),lickNum(cueIndex(:,3)));
%     [~,pTtest] = ttest2(lickNum(cueIndex(:,1)),lickNum(cueIndex(:,2)));
%     [b, dev, stats] = glmfit([2-cue cumsum(reward)],lickNum,'poisson');

    [lickReg,lickRegXpt] = sliding(lickHist,50,10);
    pValueReg = zeros(length(lickReg(1,:)),3);
    pValueRegIndex = zeros(length(lickReg(1,:)),3);
    for iRegBin = 1: length(lickReg(1,:))
        [~,~,stat] = glmfit([cue-1 reward modulation],lickReg(:,iRegBin),'poisson');
        pValueReg(iRegBin,:) = stat.p(2:4)';
        pValueRegIndex(iRegBin,:) = stat.p(2:4)'<0.05;
        pValueRegIndex(iRegBin,pValueRegIndex(iRegBin,:)==0) = NaN;
    end

    save('Events.mat', ...
        'xLickRaster','yLickRaster', ...
        'lickHist','lickMean','lickSem','lickMeanConv','lickSemConv','-append');
    
    % plot part
    fHandle = figure;
    hRaster4Reward = axes('Position',axpt(1,2,1,1,axpt(1,2,1,1,[],[0 0.1])));
    hold on;
    for iType = find(mod(types,4)==1 | mod(types,4)==2)
        if trialResult(iType)==0; continue; end;
        if mod(iType,2)==0
            rectangle('Position',[lickWindow(1)+0.51 trialResultSum2Reward(iType) diff(lickWindow)-1 trialResult(iType)],...
                'LineStyle', 'none', 'FaceColor',[0.9 0.9 0.9]);
        end
        plot(xLickRaster{iType}, yLickRaster{iType},'LineWidth', 0.3, 'Color', lineClr{iType});
    end
    plot([eventDuration(2) eventDuration(2)], [0 trialResultSum2Reward(end-2)], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(3) eventDuration(3)], [0 trialResultSum2Reward(end-2)], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(4) eventDuration(4)], [0 trialResultSum2Reward(end-2)], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    set(hRaster4Reward, 'box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 5, ...
        'XLim', [lickWindow(1)+0.5 lickWindow(2)-0.5], 'XTick', [], ...
        'YLim', [0 trialResultSum2Reward(end-2)], 'YTick', [0 trialResultSum2Reward(end-2)]);
    ylabel('Trial','FontSize',9);
    title('< Rewarded Trials >','FontSize',12);
    
    hPETH4Reward = axes('Position',axpt(1,2,1,2,axpt(1,2,1,1,[],[0 0.1])));
    hold on;
    yMax = ceil(max(lickSemConv(:)));
    plot([eventDuration(2) eventDuration(2)], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(3) eventDuration(3)], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(4) eventDuration(4)], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    rectangle('Position', [eventDuration(2) yMax*0.95 eventDuration(3)-eventDuration(2) yMax*0.05], 'LineStyle', 'none', 'FaceColor', [1 0.79 0.22]);
    rectangle('Position', [eventDuration(4) yMax*0.95 0.1 yMax*0.05], 'LineStyle', 'none', 'FaceColor', [0 0.45 0.74]);
    for jType = find(mod(types,4)==1 | mod(types,4)==2)
        if trialResult(jType)==0; continue; end;
        fill(lickSemBin, lickSemConv(jType,:), lineClr{jType}, 'LineStyle', 'none','FaceAlpha',0.2);
        plot(lickBin, lickMeanConv(jType,:), ...
            'LineStyle', lineStl{jType}, 'Color', lineClr{jType}, 'LineWidth', lineWth(jType));
    end
    plot(lickRegXpt/100.*pValueRegIndex(:,1)',repmat(yMax*0.9,1,length(lickRegXpt)),'LineStyle','none','Marker','s','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',5);
    plot(lickRegXpt/100.*pValueRegIndex(:,3)',repmat(yMax*0.9,1,length(lickRegXpt)),'LineStyle','none','Marker','s','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',5);
    set(gca, 'box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 5, ...
        'XLim', [lickWindow(1)+0.5 lickWindow(2)-0.5], 'XTick', [], ...
        'YLim', [0 yMax], 'YTick', [0 yMax]);
    ylabel('Lick/s','FontSize',9);
        
    hRaster4noReward = axes('Position',axpt(1,2,1,1,axpt(1,2,1,2,[],[0 0.1])));
    hold on;
    for iType = find(mod(types,4)==3 | mod(types,4)==0)
        if trialResult(iType)==0; continue; end;
        if mod(iType,2)==0
            rectangle('Position',[lickWindow(1)+0.51 trialResultSum2Reward(iType) diff(lickWindow)-1 trialResult(iType)],...
                'LineStyle', 'none', 'FaceColor',[0.9 0.9 0.9]);
        end
        plot(xLickRaster{iType}, yLickRaster{iType},'LineWidth', 0.3, 'Color', lineClr{iType});
    end
    plot([eventDuration(2) eventDuration(2)], [0 trialResultSum2Reward(end)], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(3) eventDuration(3)], [0 trialResultSum2Reward(end)], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(4) eventDuration(4)], [0 trialResultSum2Reward(end)], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    set(hRaster4noReward, 'box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 5, ...
        'XLim', [lickWindow(1)+0.5 lickWindow(2)-0.5], 'XTick', [], ...
        'YLim', [0 trialResultSum2Reward(end)], 'YTick', [0 trialResultSum2Reward(end)]);
    ylabel('Trial','FontSize',9);
    title('< Not Rewarded Trials >','FontSize',12);
    
    hPETH4noReward = axes('Position',axpt(1,2,1,2,axpt(1,2,1,2,[],[0 0.1])));
    hold on;
    plot([eventDuration(2) eventDuration(2)], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(3) eventDuration(3)], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([eventDuration(4) eventDuration(4)], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    rectangle('Position', [eventDuration(2) yMax*0.95 eventDuration(3)-eventDuration(2) yMax*0.05], 'LineStyle', 'none', 'FaceColor', [1 0.79 0.22]);
    rectangle('Position', [eventDuration(4) yMax*0.95 0.1 yMax*0.05], 'LineStyle', 'none', 'FaceColor', [0 0.45 0.74]);
    for jType = find(mod(types,4)==3 | mod(types,4)==0)
        if trialResult(jType)==0; continue; end;
        fill(lickSemBin, lickSemConv(jType,:), lineClr{jType}, 'LineStyle', 'none','FaceAlpha',0.2);
        plot(lickBin, lickMeanConv(jType,:), ...
            'LineStyle', lineStl{jType}, 'Color', lineClr{jType}, 'LineWidth', lineWth(jType));
    end
    plot(lickRegXpt/100.*pValueRegIndex(:,1)',repmat(yMax*0.9,1,length(lickRegXpt)),'LineStyle','none','Marker','s','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',5);
    plot(lickRegXpt/100.*pValueRegIndex(:,3)',repmat(yMax*0.9,1,length(lickRegXpt)),'LineStyle','none','Marker','s','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',5);
    set(gca, 'box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 5, ...
        'XLim', [lickWindow(1)+0.5 lickWindow(2)-0.5], 'XTick', [eventDuration(1:4) lickWindow(2)-0.5], 'XTickLabel', {'', eventDuration(2), eventDuration(3), eventDuration(4), ''}, ...
        'YLim', [0 yMax], 'YTick', [0 yMax]);
    xlabel('Time after cue onset','FontSize',9);
    ylabel('Lick/s','FontSize',9);  
    text(lickWindow(2)*0.75, yMax*0.8, ['p for cue = ',num2str(pRankSum4Cue,3)], 'FontSize',9);
        
    cd('..');
    cellcd = strsplit(fileparts(eventFile{iFile}),'\');
    cellfile = strcat(cellcd(end-1),'_',cellcd(end),'_lickplot');
    print(fHandle,'-dtiff','-r600',[cellfile{1},'.tif']);
    cd(fileparts(eventFile{iFile}));
end
close all;