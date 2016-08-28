function rewardSpecificityPlot()
close all;
barColor = {[0.494 0.184 0.556], [0.929 0.694 0.125], [0.466 .674 0.188]};
load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');

cellNm = {'nspv', 'nssom', 'wssom'};
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
for iT = 1:3
    cueS = cueSpc(T.cellList(tag.(cellNm{iT})));
    [~, p] = ttest(cueS)
    cueSpecificity = [cueSpecificity;cueS];
    cellType = [cellType;ones(sum(tag.(cellNm{iT})),1)*iT];
end

fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/2 6.375]);
MyScatterBarPlot(cueSpecificity,cellType,0.5,barColor);
text(1, 0.4, '*', 'FontSize', 10, 'HorizontalAlign', 'center', 'Color', [1 0 0]);

set(gca,'Box','off','TickDir','out','FontSize',5,'LineWidth',0.2,...
    'XTickLabel',{'PV','ns-SOM','ws-SOM'},...
    'YLim',[-1 1],'YTick',[-1 0 1]);
ylabel('Reward-dependent firing','FontSize',5);

print(fHandle,'-dtiff','-r300', 'specificity_reward_in.tif');

function rewardSpecificity = cueSpc(cellList)
timeWindow = [0 1000];
binWindow = timeWindow(2) - timeWindow(1);
binStep = binWindow;

nC = length(cellList);
rewardSpecificity = zeros(nC, 1);
for iC = 1:nC
    load([fileparts(cellList{iC}), '\Events.mat'], 'trialIndex');
    load(cellList{iC}, 'spikeTimeRw');
    
    [~, spk] = spikeBin(spikeTimeRw, timeWindow, binWindow, binStep);
    spkP = mean(spk(trialIndex(:,1)));
    spkNP = mean(spk(trialIndex(:,3)));
    
    rewardSpecificity(iC) = (spkP - spkNP) / (spkP + spkNP);
end