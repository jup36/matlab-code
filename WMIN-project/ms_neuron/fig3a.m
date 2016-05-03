function fig3a()
% Loading
clearvars; close all;
rtdir = pwd;

load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat');
iNspv = 12; iNssom = 4; iWssom = 12; % wssom 12
% iNspv = 12; iNssom = 4; iWssom = 13; iFs = 4; iPc = 906; %902 4
cs = [nspv(iNspv);nssom(iNssom);wssom(iWssom)];
nC = size(cs,1);

% Load spikes and make PSTH
spikeTime = spikeList(cs);
binSize = 10;
resolution = 10;

% Plot properties
lineColor={[0 0 0], [0.8 0 0]};
lineWidth=[1 0.5];
lineStl={'-','--'};

% Plot position
fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5 6.375]);
load(cs{1},'bins');
hPeth = zeros(6,4);
epoch = [1 4 5 8];
cols = {[1 4], [5 8], [9 13], [14 23]};
window = [-1 3; -3 1;-1 1;-1 3;-1 4;-4 1;-1 1;-2 8];
wins = {[-2 4]*10^3; [-2 4]*10^3; [-2 5]*10^3; [-3 9]*10^3};
gapS = [0.01 0.01];
gapM = [0.02 0.02];
gapL = [0.05 0.05];

for iC = 1:nC
    [cellDir,cellNm,~] = fileparts(cs{iC});
    cd(cellDir);
    load('Events.mat','index');
    nIdx = [any(index(:,[1 4]),2) any(index(:,[2 3 5 6]),2)];
    result = sum(nIdx);
    ntrial = sum(result);
    yRangePSTH = 0;
    
%% PETH and Raster for epoch
    for iCol = 1:4
        [xpt, ypt, psthtime, ~, psthconv, ~] = rasterPSTH(spikeTime{iC,iCol}, nIdx, wins{iCol}, binSize, resolution, 0);
        xpt = cellfun(@(x) x/1000, xpt, 'UniformOutput', false); psthtime = psthtime/10^3;
        
% Raster        
        hPeth(2*iC-1, iCol) = axes('Position',axpt(1,2,1,1,axpt(23,5,cols{iCol},iC,[],gapS),gapS)); % Raster
        hold on;
        switch iCol
            case 1
                ylabel('Trial','FontSize',4);
                plot([0 0],[0 ntrial],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                set(gca,'YTick',[0 ntrial],'YTickLabel',{'      ',ntrial});
            case 2
                plot([0 0],[0 ntrial],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                set(gca,'YTick',[]);
            case 3
                plot([0 0],[0 ntrial],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                plot([3 3],[0 ntrial],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                set(gca,'YTick',[]);
            case 4
                plot([0 0],[0 ntrial],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                set(gca,'YTick',[]);
        end
        for iChoice = find(result~=0)
            plot(xpt{iChoice},ypt{iChoice},...
                'LineStyle','-','LineWidth',0.1,'Color',lineColor{iChoice});
        end
        set(gca,'box','off','TickDir','out','LineWidth',0.2,'FontSize',4,...
            'XLim',window(epoch(iCol),:),'XTick',[],...
            'YLim',[0 ntrial]);

% PETH
        hPeth(2*iC, iCol) = axes('Position',axpt(1,2,1,2,axpt(23,5,cols{iCol},iC,[],gapS),gapS)); % PSTH
        hold on;
        if iC < nC
            switch iCol
                case 1
                    ylabel('Rate (Hz)','FontSize',4);
                    plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                    set(gca,'XLim',window(epoch(iCol),:),'XTick',[-1:3],'XTickLabel',{[],[],[],[],[]});
                case 2
                    plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                    set(gca,'XLim',window(epoch(iCol),:),'XTick',[-1:3],'XTickLabel',{[],[],[],[],[]});
                case 3
                    plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                    plot([3 3],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                    set(gca,'XLim',window(epoch(iCol),:),'XTick',[-1:4],'XTickLabel',{[],[],[],[],[],[]});
                case 4
                    plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                    set(gca,'XLim',window(epoch(iCol),:),'XTick',[-2:10],'XTickLabel',{[],[],[],[],[],[],[],[],[],[],[],[],[]});
            end
        else
            switch iCol
            case 1
                ylabel('Rate (Hz)','FontSize',4);
                plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                set(gca,'XLim',window(epoch(iCol),:),'XTick',[-1:3],'XTickLabel',{[],0,[],[2],[]});
            case 2
                plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                set(gca,'XLim',window(epoch(iCol),:),'XTick',[-1:3],'XTickLabel',{[],0,[],[2],[]});
            case 3
                plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                plot([3 3],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                set(gca,'XLim',window(epoch(iCol),:),'XTick',[-1:4],'XTickLabel',{[],0,[],[],[3],[]});
                xlabel('Time (s)','FontSize',5);
            case 4
                plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.8 0.8 0.8]);
                set(gca,'XLim',window(epoch(iCol),:),'XTick',[-2:10],'XTickLabel',{[],[],0,[],[],[3],[],[],[6],[],[],[9],[]});
            end
        end
        for jChoice = find(result~=0)
            plot(psthtime,psthconv(jChoice,:),...
                'LineStyle',lineStl{jChoice},'LineWidth',lineWidth(jChoice),'Color',lineColor{jChoice});
            yRangePSTH = max([yRangePSTH max(psthconv(jChoice,:))]);
        end
        set(gca,'box','off','TickDir','out','LineWidth',0.2,'FontSize',4);        
    end
    set(hPeth(2*iC, 1),'YLim',[0 ceil(yRangePSTH*1.10)+10^-8],'YTick',[0 ceil(yRangePSTH*1.10)],'YTickLabel',{'     ',ceil(yRangePSTH*1.10)},'YColor','k');
    set(hPeth(2*iC, 2:4),'YLim',[0 ceil(yRangePSTH*1.10)+10^-8],'YTick',[],'YColor','k');
end
align_ylabel(hPeth(1:6, 1));

cd(rtdir);
print(gcf,'-depsc','C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\manuscript\Neuron\Fig\fig3a_20160315.eps');

function spikeTime = spikeList(mFileList)
predir = 'C:\\Users\\Lapis\\OneDrive\\project\\workingmemory_interneuron\\data\\';
curdir = 'D:\\Cheetah_data\\workingmemory_interneuron\\';
tFL = cellfun(@(x) regexprep(x,predir,curdir),mFileList,'UniformOutput',false);
preext = '.mat';
curext = '.t';
tFL = cellfun(@(x) regexprep(x,preext,curext), tFL, 'UniformOutput',false);
tSP = LoadSpikes(tFL, 'tsflag','ts', 'verbose',0);
eFL = cellfun(@(x) [fileparts(x),'\Events.mat'], mFileList, 'UniformOutput',false);

nC = length(mFileList);
spikeTime = cell(nC, 4);
epoch = [1 4 5 8];
wins = {[-2 4]*10^3; [-2 4]*10^3; [-2 5]*10^3; [-3 9]*10^3};
for iC = 1:nC
    load(eFL{iC});
    spikeData = Data(tSP{iC})/10;
    for iW = 1:4
        spikeTime{iC, iW} = spikeWin(spikeData, eventtime(:,epoch(iW))/10, wins{iW});
    end
end
