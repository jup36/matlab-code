function LickRatePlot(sessionFolder)
% LickRatePlot Draws raster and peth for licking rate

% variables
lickWindow = [-1 8];
binSize = 0.01; % unit: second;
lickBin = -1:binSize:8;
resolution = 10;
nType = 16;

lineClr = {[0.8 0 0], [0.8 0.4 0.4], [0.8 0 0], [0.8 0.4 0.4], ...
        [0 0 0.8], [0.4 0.4 0.8], [0 0 0.8], [0.4 0.4 0.8], ...
        [1 0.6 0], [1 1 0.4], [1 0.6 0], [1 1 0.4], ...
        [0 0.6 1], [0.4 1 1], [0 0.6 1], [0.4 1 1]};
lineStl = {'-', '-', '--', '--', ...
    '-', '-', '--', '--', ...
    '-', '-', '--', '--', ...
    '-', '-', '--', '--'};
lineWth = [1 0.5 0.5 0.5 1 0.5 0.5 0.5 1 0.5 0.5 0.5 1 0.5 0.5 0.5];

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
    
    % licking raster / PETH
    trialResultSum = [0 cumsum(trialResult)];
    eventTimeType = zeros(nTrial,1);
    xLickTrial = cell(nTrial,1);
    yLickTrial = cell(nTrial,1);
    xLickRaster = cell(nType,1);
    yLickRaster = cell(nType,1);
    lickHist = zeros(nTrial, length(lickBin));
    lickPETH = zeros(nType, length(lickBin));
    lickPETHSem = zeros(nType, length(lickBin));
    for iType = 1:nType
        % raster
        if trialResult(iType)==0; continue; end;
        eventTimeType((trialResultSum(iType)+1):trialResultSum(iType+1)) = eventTime(trialIndex(:,iType),1);
        for iSubtrial = (trialResultSum(iType)+1):trialResultSum(iType+1)
            [~,lickIndex] = histc(lickOnsetTime/1000, eventTimeType(iSubtrial)/1000 + lickWindow);
            lickTemp = (lickOnsetTime(logical(lickIndex)) - eventTimeType(iSubtrial)) / 1000;

            nLick = length(lickTemp);
            xLickTemp = [lickTemp lickTemp  NaN(nLick,1)]';
            yLickTemp = [ones(nLick,1)*(iSubtrial-1) ones(nLick,1)*iSubtrial NaN(nLick,1)]';
            xLickTrial{iSubtrial} = xLickTemp(:);
            yLickTrial{iSubtrial} = yLickTemp(:);
            
            lickHist(iSubtrial,:) = histc(lickTemp, lickBin)/binSize;
        end
        xLickRaster{iType} = cell2mat(xLickTrial((trialResultSum(iType)+1):trialResultSum(iType+1)));
        yLickRaster{iType} = cell2mat(yLickTrial((trialResultSum(iType)+1):trialResultSum(iType+1)));
        
        lickMean = mean(lickHist((trialResultSum(iType)+1):trialResultSum(iType+1),:));
        lickSem = std(lickHist((trialResultSum(iType)+1):trialResultSum(iType+1),:))/sqrt(trialResult(iType));
        lickPETH(iType,:) = conv(lickMean, fspecial('Gaussian', [1 5*resolution],resolution), 'same');
        lickPETHSem(iType,:) = conv(lickSem, fspecial('Gaussian', [1 5*resolution],resolution), 'same');
    end

    lickSemBin = [lickBin flip(lickBin)];
    lickSemConv = [lickPETH-lickPETHSem flip(lickPETH+lickPETHSem,2)];

    % plot part
    fHandle = figure('PaperUnits', 'centimeters', 'PaperPosition', [2 2 8.9 6.88]);
    hRaster = axes('Position',[0.1 0.55 0.8 0.40]);
    hold on;

    for iType = 1:nType
        if trialResult(iType)==0; continue; end;
        if mod(iType,2)==0
            rectangle('Position', [0 trialResultSum(iType) 8 trialResult(iType)], 'LineStyle', 'none', 'FaceColor', [0.95 0.95 0.95]);
        end
        plot(xLickRaster{iType}, yLickRaster{iType}, ...
            'LineWidth', 0.3, 'Color', lineClr{iType});
    end
    plot([0.5 0.5], [0 nTrial], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([1.5 1.5], [0 nTrial], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([4 4], [0 nTrial], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    set(hRaster, 'box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 5, ...
        'XLim', [0 7.5], 'XTick', [], ...
        'YLim', [0 nTrial], 'YTick', [0 nTrial]);
    ylabel('Trial');
    
    hPETH = axes('Position',[0.1 0.1 0.8 0.40]);
    hold on;
    yMax = ceil(max(lickSemConv(:)));
    
    plot([0.5 0.5], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([1.5 1.5], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    plot([4 4], [0 yMax], 'LineStyle', ':', 'LineWidth', 0.2, 'Color', [0.8 0.8 0.8]);
    rectangle('Position', [0.5 yMax*0.95 1 yMax*0.05], 'LineStyle', 'none', 'FaceColor', [0 0 0]);
    rectangle('Position', [4 yMax*0.95 0.1 yMax*0.05], 'LineStyle', 'none', 'FaceColor', [0 0 0]);
%   fill(lickSemBin, lickPETHSem(iType,:), lineClr{iType}, 'LineStyle', 'none');
    for jType = 1:2:nType    
        plot(lickBin, lickPETH(jType,:), ...
            'LineStyle', lineStl{jType}, 'Color', lineClr{jType}, 'LineWidth', lineWth(jType));
    end
    set(gca, 'box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 5, ...
        'XLim', [0 7.5], 'XTick', [0 0.5 1.5 4 7.5], 'XTickLabel', {'', 0, 1, 3.5, ''}, ...
        'YLim', [0 yMax], 'YTick', [0 yMax]);
    xlabel('Time after cue onset');
    ylabel('Lick/s');
    
    cd('..');
    cellcd = strsplit(fileparts(eventFile{iFile}),'\');
    cellfile = strcat(cellcd(end-1),'_',cellcd(end),'_lickplot');
%     print(fHandle,'-depsc',[cellfile{1},'.eps']);
    print(fHandle,'-dtiff','-r600',[cellfile{1},'.tif']);
    cd(fileparts(eventFile{iFile}));
end
close all;