clc; clear all; close all;
load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat');

allcell = {nspv,wspv,nssom,wssom,fs,pc,nongrouped};
nType = 7;
cellColor = {[0.494 0.184 0.556], [0.494 0.184 0.556], [0.929 0.694 0.125], [0.078 .447 0.188],[0.808 0.808 0.808],[0.808 0.808 0.808],[0.808 0.808 0.808]};
faceColor = {[0.592 0.282 0.655], [0.592 0.282 0.655], [1 0.792 0.224], [0.071 0.604 0.184],[0.808 0.808 0.808],[0.808 0.808 0.808],[1 1 1]};
cellMarker = {'o','^','o','^','o','^','s'};
mkSize = [3 3 3 3 2 2 2];
cellLine = [0.4 0.4 0.4 0.4 0.4 0.4 0.4];

fhandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/1.5 6.375]);
axes('Position',[0.15 0.15 0.5 0.35]);
hold on;
hvw = zeros(2,nType);
pvr = zeros(2,nType);
fr = zeros(2,nType);

for iType = nType:-1:1
    cs = allcell{iType};
    nCell = length(cs);
    
    halfValleyWidth = zeros(1,nCell);
    firingRate = zeros(1,nCell);
    peakValleyRatio = zeros(1,nCell);
    for iCell = 1:nCell
        load(cs{iCell},'hfvwth','fr_task','spkpvr');
        halfValleyWidth(iCell) = hfvwth;
        firingRate(iCell) = fr_task;
        peakValleyRatio(iCell) = spkpvr;
    end
    
    hvw(1,iType) = mean(halfValleyWidth);
    fr(1,iType) = mean(firingRate);
    pvr(1,iType) = mean(peakValleyRatio);
    hvw(2,iType) = std(halfValleyWidth)/sqrt(nCell);
    fr(2,iType) = std(firingRate)/sqrt(nCell);
    pvr(2,iType) = std(peakValleyRatio)/sqrt(nCell);
    
    h(iType) = plot(halfValleyWidth,firingRate);
    set(h(iType),'LineStyle','none','LineWidth',cellLine(iType),...
        'Marker',cellMarker{iType},'MarkerSize',mkSize(iType),'MarkerEdgeColor',cellColor{iType},'MarkerFaceColor',faceColor{iType});
end
xlabel('Half-valley width (\mus)','FontSize',5);
ylabel('Mean firing rate (Hz)','FontSize',5);
% zlabel('Peak-valley ratio','FontSize',20);

set(gca,'box','off','TickDir','out','FontSize',5,'LineWidth',0.2,'FontName','Arial');
% set(gca,'View',[0 90]);
set(gca,'XLim',[100 600],'XTick',[100 200 300 400 500]);
set(gca,'YLim',[0 55],'YTick',[10 30 50]);

print(gcf,'-depsc','C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\manuscript\Neuron\Fig\fig2c.eps');