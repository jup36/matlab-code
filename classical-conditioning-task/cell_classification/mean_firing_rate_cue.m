clc; clearvars; close all;
load('cellTable.mat');

cellNm = {'nspv', 'som', 'nssom', 'wssom', 'fs', 'pc'};
trialType = [1, 7];
lineClr = {[0 0.447 0.741], [0.8 0 0]};
fillClr = {[0 0.447 0.741], [0.8 0 0]};

tag.p = T.pLR < 0.01 & T.pSalt < 0.01;

tag.pv = tag.p & T.mouseLine=='PV';
tag.nspv = tag.p & T.mouseLine=='PV' & T.class == 1;
tag.som = tag.p & T.mouseLine=='SOM';
tag.nssom = tag.p & T.mouseLine=='SOM' & T.class == 1;
tag.wssom = tag.p & T.mouseLine=='SOM' & T.class == 2;
tag.fs = ~tag.p & T.class == 1;
tag.pc = ~tag.p & T.class == 2;

fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5 6.375*2]);
gapL = [0.1 0.1];

hA = zeros(1, 2);
for iT = 1:2
    cellList.(cellNm{iT}) = T.cellList(tag.(cellNm{iT}));
    n.(cellNm{iT}) = length(cellList.(cellNm{iT}));
    
    [psth{1} psth{2} psth{3} psth{4}] = deal(zeros(n.(cellNm{iT}), 801));
    for iC = 1:n.(cellNm{iT})
        load(cellList.(cellNm{iT}){iC}, 'psthconvzCue', 'psthtime');
        test = psthconvzCue(trialType, :);
        for iCue = 1:2
            psth{iCue}(iC, :) = test(iCue, :);
        end
    end
    nC = cellfun(@(x) sum(~isnan(x(:,1))), psth, 'UniformOutput', false);
    
    mpsth = cellfun(@nanmean, psth, 'UniformOutput', false);
    spsth = cellfun(@(x, y) nanstd(x) / sqrt(y), psth, nC, 'UniformOutput', false);
    spsth = cellfun(@(x,y) [x-y flip(x+y)], mpsth, spsth, 'UniformOutput', false);
    
    hA(iT) = axes('Position', axpt(1, 2, 1, iT, [], gapL));
    hold on;
    plot([0 0], [-2.5 2.5], 'LineStyle', '-', 'LineWidth', 0.3, 'Color', [0.8 0.8 0.8]);
    for jC = 1:2
        fill([psthtime flip(psthtime)], spsth{jC}, fillClr{jC}, 'LineStyle', 'none', 'FaceAlpha', 0.5);
        plot(psthtime, mpsth{jC}, 'Color', lineClr{jC}, 'LineWidth', 1);
    end
    ylabel('Normalized firing rate', 'FontSize', 5);
    if iT==1
        title('PV', 'FontSize', 6, 'Color', [0.494 0.184 0.556]);
        axes('Position',[0.80 0.80 0.1 0.1]);
        hold on;
        plot([0 0.25],[0.75 0.75],'LineWidth',0.5,'Color',lineClr{1});
        text(0.3,0.75,'CS+','FontSize',4);
        plot([0 0.25],[0.5 0.5],'LineWidth',0.5,'Color',lineClr{2});
        text(0.3,0.5,'CS-','FontSize',4);
        set(gca,'visible','off', 'YLim', [0 1], 'XLim', [0 1]);
    elseif iT==2
        title('SOM', 'FontSize', 6, 'Color', [0.466 0.674 0.188]);
        xlabel('Time from cue onset (s)', 'FontSize', 5);
    end
end
set(hA, 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 4, ...
        'XLim', [-0.5 3], 'XTick', [-0.5 0 1 2 3], ...
        'YLim', [-3 3], 'YTick', -3:3, 'YTickLabel', {'', -2, '', 0, '', 2, ''});
set(hA(1), 'XTickLabel', []);

print(fHandle, '-dtiff', '-r300', 'cue_in.tif');