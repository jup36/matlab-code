% target specificity during trial start, sample period, reward period
clc; clearvars; close all;

%% variables
epochWindow = [-1000 4000];
timeBin = (-1000+250):100:(4000-250);
nBin = length(timeBin);

%% load cell data
load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat');
cellType = {nspv, [nssom; wssom]};
nCT = length(cellType);

tSpc = cell(nCT, 1);
for iCT = 1:nCT
    cells = cellType{iCT};
    [tData, tList] = tLoad(cells);
    nC = length(cells);
    
    absoluteTargetSpecificity = zeros(nC, nBin);
    for iC = 1:nC
        load([fileparts(tList{iC}), '\Events.mat'], 'eventtime', 'trialresult');
        nTrial = size(trialresult, 1);
                
        %% summerize event
        trialIndex = false(nTrial, 2);
        trialIndex(:, 1) = trialresult(:, 1)==1 & trialresult(:, 2)==2 & trialresult(:, 4)==0;
        trialIndex(:, 2) = trialresult(:, 1)==2 & trialresult(:, 2)==1 & trialresult(:, 4)==0;
        
        spikeTime = spikeWin(tData{iC}, eventtime(:, 5)/10, epochWindow);
        [~, spk] = spikeBin(spikeTime, epochWindow, 500, 100);
        
        spcTemp = [nanmean(spk(trialIndex(:, 1), :), 1); nanmean(spk(trialIndex(:, 2), :), 1)];
        
        absoluteTargetSpecificity(iC, :) = abs(diff(spcTemp)) ./ sum(spcTemp);
    end
    tSpc{iCT} = absoluteTargetSpecificity;
end


%% figure variables
barColor = {[0.494 0.184 0.556], [0.466 0.674 0.188]};
fillClr = {[0.592 0.282 0.655], [0.071 0.604 0.184]};
gapS = [0.05 0.05];

hF = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/2 6.375/1.5*0.65]);
hA = axes('Position', axpt(1, 1, 1, 1, [], gapS));
hold on;
    
[h, p] = deal(NaN(1, nBin));
for iBin = 1:nBin
    [hTemp, p(iBin)] = ttest2(tSpc{1}(:, iBin), tSpc{2}(:, iBin));
    if hTemp == 1
        h(iBin) = 1;
    end
end


plot([0 0], [0 1], 'LineWidth', 0.35, 'LineStyle', '--', 'Color', [0.8 0.8 0.8]);
plot([3 3], [0 1], 'LineWidth', 0.35, 'LineStyle', '--', 'Color', [0.8 0.8 0.8]);

for iCT = 1:2
    nC = sum(~isnan(tSpc{iCT}), 1);
    mS = nanmean(tSpc{iCT}, 1);
    sS = nanstd(tSpc{iCT}, 1) ./ sqrt(nC);
    
    ssS = [mS-sS flip(mS+sS)];
    
    fill([timeBin flip(timeBin)]/1000, ssS, barColor{iCT}, ...
        'LineStyle', 'none');
    plot(timeBin/1000, mS, 'LineWidth', 1, 'Color', barColor{iCT});
    
    plot(timeBin/1000, 0.49*h, 'LineWidth', 4, 'Color', [0.8 0.8 0.8]);
end
    
set(gca,'Box','off','TickDir','out','FontSize',5,'LineWidth',0.35,...
    'XLim', [-0.5 3.5], 'XTick', [0 1 2 3], 'XTickLabel', {0, '', '', 3}, ...
    'YLim',[0 0.5],'YTick', [0 0.25 0.5]);
xlabel('Time from delay onset (s)', 'FontSize', 6);
ylabel('Absolute target preference', 'FontSize', 6);

print(hF, '-depsc', 'C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\manuscript\Neuron\Fig\fig3d.eps');