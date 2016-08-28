% lick rate plot at the time of reward presentation

clc; clearvars; close all;
load('C:\Users\lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');

trialType = [1, 3];
nType = length(trialType);
binSize = 10;
resolution = 10;
winRw = [-1500 3500];
window = [-1 3];

cellNum = 4;

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

for iT = 1
    cellList = T.cellList(tag.(cellNm{iT}));
    sessionList = cellfun(@fileparts, cellList, 'UniformOutput', false);
    nC = length(sessionList);
    
    for iC = 1:nC
        load([sessionList{iC}, '\Events.mat'], 'trialIndex', 'lickOnsetTime', 'rewardLickTime');
        inTrial = ~isnan(rewardLickTime);
        nTrial = sum(inTrial(any(trialIndex(:, trialType), 2)));
        lickTimeRw = spikeWin(lickOnsetTime, rewardLickTime, winRw);
        
        [xpt, ypt, psthtime, ~, psthconv, ~, psthsem] = rasterPSTH(lickTimeRw(inTrial),trialIndex(inTrial, trialType),winRw,binSize,resolution,1);
        xpt = cellfun(@(x) x/1000, xpt, 'UniformOutput', false); psthtime = psthtime/10^3;
        
        fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5 6.375]);
        hA = zeros(4,1);
        hA(1) = axes('Position', axpt(1, 2, 1, 1, axpt(2,1,1,1,[],gapL), gapS));
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
        
        hA(2) = axes('Position', axpt(1, 2, 1, 2, axpt(2,1,1,1,[],gapL), gapS));
        hold on;
        for iType = 1:nType
            fill([psthtime flip(psthtime)], psthsem(iType, :), lineClr{iType}, 'LineStyle', 'none', 'FaceAlpha', 0.5);
            plot(psthtime, psthconv(iType, :), 'Color', lineClr{iType}, 'LineWidth', 1);
        end
        yMax = ceil(max(psthsem(:))*1.2+10^-6);
        set(gca, 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 4, ...
            'XLim', window, 'XTick', -1:3, 'XTickLabel', {-1, 0, '', '', 3}, ...
            'YLim', [0 yMax], 'YTick', [0 yMax]);
        xlabel('Time from outcome (s)', 'FontSize', 5);
        ylabel('Lick rate (Hz)', 'FontSize', 5);
        align_ylabel(hA(1:2));
        
        load(cellList{iC}, 'spikeTimeRw');
        
        [xptRw, yptRw, psthtimeRw, ~, psthconvRw, ~, psthsemRw] = rasterPSTH(spikeTimeRw(inTrial),trialIndex(inTrial, trialType),winRw,binSize,resolution,1);
        xptRw = cellfun(@(x) x/1000, xptRw, 'UniformOutput', false); psthtimeRw = psthtimeRw/10^3;
        
        hA(3) = axes('Position', axpt(1, 2, 1, 1, axpt(2,1,2,1,[],gapL), gapS));
        hold on;
        for iType = 1:nType
            plot(xptRw{iType}, yptRw{iType}, ...
                'Marker', '.', 'MarkerSize', 3, ...
                'LineStyle', 'none', 'Color', lineClr{iType});
        end
        set(gca, 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 4, ...
            'XLim', window, 'XTick', -1:3, 'XTickLabel', [], ...
            'YLim', [0 nTrial], 'YTick', [0 nTrial], 'YTickLabel', {[], nTrial});
        ylabel('Trial', 'FontSize', 5);
        
        hA(4) = axes('Position', axpt(1, 2, 1, 2, axpt(2,1,2,1,[],gapL), gapS));
        hold on;
        for iType = 1:nType
            fill([psthtimeRw flip(psthtimeRw)], psthsemRw(iType, :), lineClr{iType}, 'LineStyle', 'none', 'FaceAlpha', 0.5);
            plot(psthtimeRw, psthconvRw(iType, :), 'Color', lineClr{iType}, 'LineWidth', 1);
        end
        yMax = ceil(max(psthconvRw(:))*1.2+10^-6);
        set(gca, 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 4, ...
            'XLim', window, 'XTick', -1:3, 'XTickLabel', {-1, 0, '', '', 3}, ...
            'YLim', [0 yMax], 'YTick', [0 yMax]);
        xlabel('Time from outcome (s)', 'FontSize', 5);
        ylabel('Firing rate (Hz)', 'FontSize', 5);
        align_ylabel(hA(3:4));
        
        axes('Position', [0.5 0.975 0.1 0.05]);
        text(0, 0, cellList{iC}, 'FontSize', 4, 'Interpreter', 'none', 'HorizontalAlign', 'center');
        set(gca, 'visible', 'off');
        
        print(fHandle, '-dtiff', '-r300', ['lickRateReward_', num2str(iC),'.tif']);
        close(fHandle);
    end
end