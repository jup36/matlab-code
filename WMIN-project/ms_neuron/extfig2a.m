clc; clear all; close all;
load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat');

fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 17.4 24.6]);

% A. PV raster/psth
nCell = length(nspv);
nCol = 5;
nRow = 15;
for iCell = 1:nCell
    iRow = floor((iCell-1)/nCol)+1;
    iCol = mod((iCell-1),nCol)+1;
    
    load(nspv{iCell},'xpttag','ypttag',...
        'bintag','taghist',...
        'time_tagstat','H1_tagstat','H2_tagstat','p_tagstat');
    
    xpttag = xpttag(~isnan(xpttag)); ypttag = ypttag(~isnan(ypttag));
    xpttag = reshape(xpttag,2,[]); ypttag = reshape(ypttag,2,[]);
    xpttag = xpttag(2,:); ypttag = ypttag(2,:);
    
    axes('Position',axpt(1,2,1,1,axpt(5,5,mod(iCell-1,5)+1, floor((iCell-1)/5)+1, axpt(3,nRow,[1 2],[1 5])),[0.01 0.01]));
    hold on;
    plot(xpttag,ypttag,...
        'LineStyle','none','Marker','.','MarkerSize',1,'Color','k');
    set(gca,'Box','off','TickDir','out','FontSize',4.05, 'FontName', 'Arial',...
        'XLim',[-20 80],'XTick',[],...
        'YLim',[0 600],'YTick',[0 600],'YTickLabel',{[],600});
    if iCol==1; ylabel('Trial','FontSize',4.05, 'FontName', 'Arial'); end;

    axes('Position',axpt(1,2,1,2,axpt(5,5,mod(iCell-1,5)+1, floor((iCell-1)/5)+1, axpt(3,nRow,[1 2],[1 5])),[0.01 0.01]));
    hold on;
    hBar = bar(bintag+1,taghist,'LineStyle','none','FaceColor','k','BarWidth',1);
    yRangeHist = ceil(max(taghist(:)));
    set(gca,'Box','off','TickDir','out','FontSize',4.05, 'FontName', 'Arial','LineWidth',0.2,...
        'XLim',[-20 80],'XTick',[-20:20:80],'XTickLabel',{-20,0,[],[],[],80},...
        'YLim',[0 yRangeHist],'YTick',[0 yRangeHist],'YTickLabel',{'    0',yRangeHist});
    if iCol==1; ylabel('Spike/s','FontSize',4.05, 'FontName', 'Arial'); end;
end

% C. wsSOM raster/psth
nCell = length(wssom);
for iCell = 1:nCell
    iRow = floor((iCell-1)/nCol)+1;
    iCol = mod((iCell-1),nCol)+1;
    
    load(wssom{iCell},'xpttag','ypttag',...
        'bintag','taghist',...
        'time_tagstat','H1_tagstat','H2_tagstat','p_tagstat');
    
    xpttag = xpttag(~isnan(xpttag)); ypttag = ypttag(~isnan(ypttag));
    xpttag = reshape(xpttag,2,[]); ypttag = reshape(ypttag,2,[]);
    xpttag = xpttag(2,:); ypttag = ypttag(2,:);
    
    axes('Position',axpt(1,2,1,1,axpt(5,5,mod(iCell-1,5)+1, floor((iCell-1)/5)+1, axpt(3,nRow,[1 2],[6 10])),[0.01 0.01]));
    hold on;
    plot(xpttag,ypttag,...
        'LineStyle','none','Marker','.','MarkerSize',1,'Color','k');
    set(gca,'Box','off','TickDir','out','FontSize',4.05, 'FontName', 'Arial',...
        'XLim',[-20 80],'XTick',[],...
        'YLim',[0 600],'YTick',[0 600],'YTickLabel',{[],600});
    if iCol==1; ylabel('Trial','FontSize',4.05, 'FontName', 'Arial'); end;

    axes('Position',axpt(1,2,1,2,axpt(5,5,mod(iCell-1,5)+1, floor((iCell-1)/5)+1, axpt(3,nRow,[1 2],[6 10])),[0.01 0.01]));
    hold on;
    hBar = bar(bintag+1,taghist,'LineStyle','none','FaceColor','k','BarWidth',1);
    yRangeHist = ceil(max(taghist(:)));
    set(gca,'Box','off','TickDir','out','FontSize',4.05, 'FontName', 'Arial','LineWidth',0.2,...
        'XLim',[-20 80],'XTick',[-20:20:80],'XTickLabel',{-20,0,[],[],[],80},...
        'YLim',[0 yRangeHist],'YTick',[0 yRangeHist],'YTickLabel',{'    0',yRangeHist});
    if iCol==1; ylabel('Spike/s','FontSize',4.05, 'FontName', 'Arial'); end;
end

% E. nsSOM raster/psth
nCell = length(nssom);
for iCell = 1:nCell
    iRow = floor((iCell-1)/nCol)+1;
    iCol = mod((iCell-1),nCol)+1;
    
    load(nssom{iCell},'xpttag','ypttag',...
        'bintag','taghist',...
        'time_tagstat','H1_tagstat','H2_tagstat','p_tagstat');
    
    xpttag = xpttag(~isnan(xpttag)); ypttag = ypttag(~isnan(ypttag));
    xpttag = reshape(xpttag,2,[]); ypttag = reshape(ypttag,2,[]);
    xpttag = xpttag(2,:); ypttag = ypttag(2,:);
    
    axes('Position',axpt(1,2,1,1,axpt(5,5,mod(iCell-1,5)+1, floor((iCell-1)/5)+1, axpt(3,nRow,[1 2],[9 13])),[0.01 0.01]));
    hold on;
    plot(xpttag,ypttag,...
        'LineStyle','none','Marker','.','MarkerSize',1,'Color','k');
    set(gca,'Box','off','TickDir','out','FontSize',4.05, 'FontName', 'Arial',...
        'XLim',[-20 80],'XTick',[],...
        'YLim',[0 600],'YTick',[0 600],'YTickLabel',{[],600});
    if iCol==1; ylabel('Trial','FontSize',4.05, 'FontName', 'Arial'); end;

    axes('Position',axpt(1,2,1,2,axpt(5,5,mod(iCell-1,5)+1, floor((iCell-1)/5)+1, axpt(3,nRow,[1 2],[9 13])),[0.01 0.01]));
    hold on;
    hBar = bar(bintag+1,taghist,'LineStyle','none','FaceColor','k','BarWidth',1);
    yRangeHist = ceil(max(taghist(:)));
    set(gca,'Box','off','TickDir','out','FontSize',4.05, 'FontName', 'Arial','LineWidth',0.2,...
        'XLim',[-20 80],'XTick',[-20:20:80],'XTickLabel',{-20,0,[],[],[],80},...
        'YLim',[0 yRangeHist],'YTick',[0 yRangeHist],'YTickLabel',{'    0',yRangeHist});
    if iCol==1; ylabel('Spike/s','FontSize',4.05, 'FontName', 'Arial'); end;
end

load('C:\Users\Lapis\OneDrive\git\matlab-code\WMIN-project\tagging\waveform_correlation.mat');
nC = [21 13 9];
r = {stat_nspv.r; stat_wssom.r; stat_nssom.r};
sponwv = {stat_nspv.m_spont_wv; stat_wssom.m_spont_wv; stat_nssom.m_spont_wv};
evokedwv = {stat_nspv.m_evoked_wv; stat_wssom.m_evoked_wv; stat_nssom.m_evoked_wv};
colRange = {[1 5], [6 10], [9 13]};

for iT = 1:3
    clearvars ha;

    for iC = 1:nC(iT)
        ha(iC) = axes('Position', axpt(5,5,mod(iC-1,5)+1, floor((iC-1)/5)+1, axpt(3,nRow,3,colRange{iT})));
        hold on;
        plot(sponwv{iT}(iC,:), 'Color', 'k');
        plot(evokedwv{iT}(iC,:), 'Color', [0 0.66 1]);
        text(33/2, 2.5, ['r = ',num2str(r{iT}(iC),'%-.3f')],'FontSize',4.05, 'FontName', 'Arial', 'HorizontalAlign', 'center');
    end
    set(ha, 'Visible', 'off', 'YLim', [-2 2]);
end

print(fHandle,'-depsc','C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\manuscript\Neuron\Fig\extfig2a.eps');
% close all;