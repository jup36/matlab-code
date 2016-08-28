function rewardSpecificityPlot()
close all;
barColor = {[0.494 0.184 0.556], [0.466 .674 0.188]};
load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');

cueS = cueSpc(T.cellList);

cellNm = {'nspv', 'som'};
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
for iT = 1:2
    cueTemp = cueS(tag.(cellNm{iT}));
    [~, p] = ttest(cueTemp)
    cueSpecificity = [cueSpecificity;cueTemp];
    cellType = [cellType;ones(sum(tag.(cellNm{iT})),1)*iT];
end

fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/4 6.375/2]);
MyScatterBarPlot(cueSpecificity,cellType,0.5,barColor);

set(gca,'Box','off','TickDir','out','FontSize',5,'LineWidth',0.2,...
    'XTickLabel',{'PV','SOM'},...
    'YLim',[-1 1],'YTick',[-1 0 1]);
ylabel('Cue-dependent firing','FontSize',5);

print(fHandle,'-dtiff','-r300', 'specificity_delay_in.tif');

function rewardSpecificity = cueSpc(cellList)
timeWindow = [1000 2000];
binWindow = 1000;
binStep = 1000;

nC = length(cellList);
rewardSpecificity = zeros(nC, 1);
for iC = 1:nC
    load([fileparts(cellList{iC}), '\Events.mat'], 'trialIndex');
    load(cellList{iC}, 'spikeTime');
    
    [~, spk] = spikeBin(spikeTime, timeWindow, binWindow, binStep);
    spkA = mean(spk(trialIndex(:,1)));
    spkB = mean(spk(trialIndex(:,13)));
    
    rewardSpecificity(iC) = (spkA - spkB) / (spkA + spkB);
end