function cueSpecificityPlot()
close all;
barColor = {[0.494 0.184 0.556], [0.466 0.674 0.188]};
load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');

cueS = cueSpc(T.cellList);

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
for iT = 1:nT
    cueTemp = cueS(tag.(cellNm{iT}));
    [~, p] = ttest(cueTemp)
    cueSpecificity = [cueSpecificity;cueTemp];
    cellType = [cellType;ones(sum(tag.(cellNm{iT})),1)*iT];
end

[~, p2] = ttest2(cueSpecificity(cellType==1), cueSpecificity(cellType==2))

hF = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/1.949/2 6.375/2.323]);
MyScatterBarPlot(cueSpecificity,cellType,0.5,barColor, {[1 2]});

set(gca,'Box','off','TickDir','out','FontSize',5,'LineWidth',0.35,...
    'XTickLabel',{'PV','SOM'},...
    'YLim',[0 1],'YTick',[0 1]);
ylabel('Absolute cue specificity','FontSize',6);

print(hF,'-depsc', 'C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\manuscript\Presentation\specificity_abs_delay_in.eps');

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
    
    rewardSpecificity(iC) = abs(spkA - spkB) / (spkA + spkB);
end