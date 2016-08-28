% lick rate plot at the time of reward presentation

clc; clearvars; close all;
load('C:\Users\lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');

trialType = [1, 3, 13, 15];
nType = length(trialType);
binSize = 10;
resolution = 10;
win = [-1500 7500];
window = [0 5];

cellNum = 200;

lineClr= {[0 0 0.8], [0.6 0.6 1], ...
    [0.8 0 0], [1 0.6 0.6]};
% lineClr = {[0 0.447 0.741], [0.235 0.235 0.235], [0.8 0 0], [1 0.5 0.5]};
fillClr = {[0 0.447 0.741], [0.494 0.494 0.494], [0.8 0 0], [1 0.5 0.5]};
gapL = [0.1 0.1];
gapS = [0.01 0.01];

cellNm = {'nspv', 'som', 'nssom', 'wssom', 'fs', 'pc'};
tag.p = T.pLR < 0.01 & T.pSalt < 0.01;

tag.pv = tag.p & T.mouseLine=='PV';
tag.nspv = tag.p & T.mouseLine=='PV' & T.class == 1;
tag.som = tag.p & T.mouseLine=='SOM';
tag.nssom = tag.p & T.mouseLine=='SOM' & T.class == 1;
tag.wssom = tag.p & T.mouseLine=='SOM' & T.class == 2;
tag.fs = ~tag.p & T.class == 1;
tag.pc = ~tag.p & T.class == 2;

for iT = 6
    cellList = T.cellList(tag.(cellNm{iT}));
    sessionList = cellfun(@fileparts, cellList, 'UniformOutput', false);
    nC = length(sessionList);
    
    for iC = cellNum
        load([sessionList{iC}, '\Events.mat'], 'trialIndex', 'lickOnsetTime', 'eventTime');
        inTrial = ~isnan(eventTime(:,1));
        nTrial = sum(inTrial(any(trialIndex(:, trialType), 2)));
        lickTime = spikeWin(lickOnsetTime, eventTime(:,2), win);
        
        [xpt, ypt, psthtime, ~, psthconv, ~, psthsem] = rasterPSTH(lickTime(inTrial),trialIndex(inTrial, trialType),win,binSize,resolution,1);
        xpt = cellfun(@(x) x/1000, xpt, 'UniformOutput', false); psthtime = psthtime/10^3;
        
        fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/2 6.375/2]);
        hA = zeros(2,1);
        hA(1) = axes('Position', axpt(1, 2, 1, 1, [], gapL));
        hold on;
        for iType = 1:nType
            plot(xpt{iType}, ypt{iType}, ...
                'Marker', '.', 'MarkerSize', 3, ...
                'LineStyle', 'none', 'Color', lineClr{iType});
        end
        set(gca, 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 4, ...
            'XLim', window, 'XTick', -1:3, 'XTickLabel', [], ...
            'YLim', [0 nTrial], 'YTick', [0 nTrial], 'YTickLabel', {[], nTrial});
        ylabel('Trial', 'FontSize', 5);
        
        hA(2) = axes('Position', axpt(1, 2, 1, 2, [], gapL));
        hold on;
        for iType = 1:nType
            fill([psthtime flip(psthtime)], psthsem(iType, :), lineClr{iType}, 'LineStyle', 'none', 'FaceAlpha', 0.5);
            plot(psthtime, psthconv(iType, :), 'Color', lineClr{iType}, 'LineWidth', 1);
        end
        yMax = ceil(max(psthsem(:))*1.2+10^-6);
        set(gca, 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 4, ...
            'XLim', window, 'XTick', -1:6, 'XTickLabel', {-1, 0, 1, 2, '', '', '', ''}, ...
            'YLim', [0 yMax], 'YTick', [0 yMax]);
        xlabel('Time from outcome (s)', 'FontSize', 5);
        ylabel('Lick rate (Hz)', 'FontSize', 5);
        align_ylabel(hA(1:2));
       
        
        print(fHandle, '-dtiff', '-r300', ['lickRateWhole_', num2str(iC),'.tif']);
        close(fHandle);
    end
end