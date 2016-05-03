function rewardSpecificityPlot()

barColor = {[0.494 0.184 0.556], [0.929 0.694 0.125], [0.466 .674 0.188]};
load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');

rwSpecificity = rwSpc(T.cellList);

cellNm = {'nspv', 'nssom', 'wssom'};
tag.p = T.pLR < 0.01 & T.pSalt < 0.01;
tag.pv = tag.p & T.mouseLine=='PV';
tag.nspv = tag.p & T.mouseLine=='PV' & T.class == 1;
tag.som = tag.p & T.mouseLine=='SOM';
tag.nssom = tag.p & T.mouseLine=='SOM' & T.class == 1;
tag.wssom = tag.p & T.mouseLine=='SOM' & T.class == 2;
tag.fs = ~tag.p & T.class == 1;
tag.pc = ~tag.p & T.class == 2;

rewardSpecificity = [];
cellType = [];
for iT = 1:3
    rwTemp = rwSpecificity(tag.(cellNm{iT}));
    [~, p] = ttest(rwTemp)
    rewardSpecificity = [rewardSpecificity;rwTemp];
    cellType = [cellType;ones(sum(tag.(cellNm{iT})),1)*iT];
end

fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/4 6.375/2]);
MyScatterBarPlot(rewardSpecificity,cellType,0.5,barColor);

set(gca,'Box','off','TickDir','out','FontSize',5,'LineWidth',0.2,...
    'XTickLabel',{'PV','ns-SOM','ws-SOM'},...
    'YLim',[-1 1],'YTick',[-1 0 1]);
ylabel('Reward-dependent firing','FontSize',5);

print(fHandle,'-depsc','C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\manuscript\Neuron\Fig\fig5f.eps');

function rewardSpecificity = rwSpc(cellList)
timeWindow = [0 1000];
binWindow = 1000;
binStep = 1000;

nC = length(cellList);
rewardSpecificity = zeros(nC, 1);
for iC = 1:nC
    load([fileparts(cellList{iC}), '\Events.mat'], 'trialIndex');
    load(cellList{iC}, 'spikeTimeRw');
    
    [~, spk] = spikeBin(spikeTimeRw, timeWindow, binWindow, binStep);
    spkR = mean(spk(trialIndex(:,1)));
    spkNR = mean(spk(trialIndex(:,3)));
    
    rewardSpecificity(iC) = (spkR - spkNR) / (spkR + spkNR);
end