function cueSpecificityPlot()
close all;
barColor = {[0.494 0.184 0.556], [0.466 0.674 0.188]};

timeWindow = [-1000 4000];
binWindow = 500;
binStep = 100;
timeBin = (timeWindow(1)+binWindow/2):binStep:(timeWindow(2)-binWindow/2);
timeBin = timeBin / 1000;
nB = length(timeBin);

load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');
cellNm = {'nspv', 'som'};
nT = length(cellNm);
tag.p = T.pLR < 0.01 & T.pSalt < 0.01;
tag.pv = tag.p & T.mouseLine=='PV';
tag.nspv = tag.p & T.mouseLine=='PV' & T.class == 1;
tag.som = tag.p & T.mouseLine=='SOM';
tag.nssom = tag.p & T.mouseLine=='SOM' & T.class == 1;
tag.wssom = tag.p & T.mouseLine=='SOM' & T.class == 2;
tag.fs = ~tag.p & T.class == 1;
tag.pc = ~tag.p & T.class == 2;

cueSpecificity = [];
cellType = [];
hF = figure('PaperUnits','centimeters','PaperPosition',[0 0 8.5/1.949 6.375/2.323]);
hold on;
for iT = 1:nT
    [~, cueTemp] = cueSpc(T.cellList(tag.(cellNm{iT})));
        
    nC = sum(~isnan(cueTemp), 1);
    mS = nanmean(cueTemp, 1);
    sS = nanstd(cueTemp, 1) ./ sqrt(nC);
    
    ssS = [mS-sS flip(mS+sS)];
    
    plot([0 0], [0 1], 'LineStyle', '--', 'LineWidth', 0.35, 'Color', [0.8 0.8 0.8]);
    plot([1 1], [0 1], 'LineStyle', '--', 'LineWidth', 0.35, 'Color', [0.8 0.8 0.8]);
    plot([2 2], [0 1], 'LineStyle', '--', 'LineWidth', 0.35, 'Color', [0.8 0.8 0.8]);
    
    fill([timeBin flip(timeBin)], ssS, barColor{iT}, ...
        'LineStyle', 'none');
    plot(timeBin, mS, 'LineWidth', 0.5, ...
        'Color', barColor{iT});
    
    nnC = size(cueTemp, 1);
    cueSpecificity = [cueSpecificity; cueTemp];
    cellType = [cellType; iT*ones(nnC, 1)];
end

ps = zeros(1, nB);
hs = zeros(1, nB);
for iB = 1:nB
    [hs(iB), ps(iB)] = ttest2(cueSpecificity(cellType==1, iB), cueSpecificity(cellType==2, iB));
end
hs(hs==0) = NaN;

plot(timeBin, hs*0.49, 'LineWidth', 2, ...
    'Color', [0.8 0.8 0.8]);

set(gca,'Box','off','TickDir','out','FontSize',5,'LineWidth',0.35,...
    'XLim', [-0.5 2.5], 'XTick', [0 1 2], ...
    'YLim',[0 0.5], 'YTick',[0 0.25 0.5]);
xlabel('Time from trial onset (s)', 'FontSize', 6);
ylabel('Absolute cue specificity','FontSize',6);

print(hF,'-depsc', 'C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\manuscript\Presentation\specificity_abs_delay_in_slide.eps');

function [timeBin, rewardSpecificity] = cueSpc(cellList)
timeWindow = [-1000 4000];
binWindow = 500;
binStep = 100;
timeBin = (timeWindow(1)+binWindow/2):binStep:(timeWindow(2)-binWindow/2);
nB = length(timeBin);

nC = length(cellList);
rewardSpecificity = zeros(nC, nB);
for iC = 1:nC
    load([fileparts(cellList{iC}), '\Events.mat'], 'trialIndex');
    load(cellList{iC}, 'spikeTime');
    
    [~, spk] = spikeBin(spikeTime, timeWindow, binWindow, binStep);
    spkA = mean(spk(trialIndex(:,1), :), 1);
    spkB = mean(spk(trialIndex(:,13), :), 1);
    
    rewardSpecificity(iC, :) = abs(spkA - spkB) ./ (spkA + spkB);
end