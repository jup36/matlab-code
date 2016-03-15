% Loading
clc; close all; clear all;
rtdir = pwd;
load('D:\Cloud\project\workingmemory_interneuron\data\celllist_20150527.mat','nspv','nssom','wssom','fs','pc');
inspv = 12; inssom = 4; iwssom = 13; ifs = 4; ipc = 906; %902 4
% cs = [fs(ifs);nspv(inspv);nssom(inssom);wssom(iwssom);pc(ipc)];
cs = [nspv(inspv);nssom(inssom);wssom(iwssom)];
nFile = size(cs,1);

% Plot properties
lineColor={[0.906 0.184 0.153], [0.925 0.851 0.792], [0.925 0.851 0.792],...
    [0.012 0.337 0.608], [0.796 0.843 0.910], [0.796 0.843 0.910]};
lineWidth=[1 0.5 0.5 1 0.5 0.5];

% Plot position
fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5 6.375]);
nRow = 5;
startPoint = [0.10 0.10];
figWidth = [0.85 0.85];
intervalX = 0.005; intervalY = 0.02;
interFigY = 0.005;
window = [-1 3; -3 1;-1 1;-1 3;-1 4;-4 1;-1 1;-2 8];
xWidth = diff(window,1,2);
xWidth = xWidth([1 4 5 8]);
xWidthSum = [0;cumsum(xWidth)];
dX = (figWidth(1)-3*intervalX)/xWidthSum(end);
dY = (figWidth(2)-(nRow-1)*intervalY-nRow*interFigY)/(2*nRow);
axpt = zeros(4,nRow,2,4);
for iRow = 1:nRow
    for iax = 1:4
        axpt(iax,iRow,1,:) = [startPoint(1)+(iax-1)*intervalX+dX*xWidthSum(iax),...
            startPoint(2)+(nRow-iRow)*(2*dY+interFigY+intervalY)+interFigY+dY,...
            xWidth(iax)*dX dY];
        axpt(iax,iRow,2,:) = [startPoint(1)+(iax-1)*intervalX+dX*xWidthSum(iax),...
            startPoint(2)+(nRow-iRow)*(2*dY+interFigY+intervalY),...
            xWidth(iax)*dX dY];
    end
end

load(cs{1},'bins');
hpeth = zeros(1,4);
epoch = [1 4 5 8];

for iFile = 1:nFile
    [cellcd,cellname,~] = fileparts(cs{iFile});
    cd(cellcd);
    load('Events.mat','ntrial','result','lighttime');
    load(cs{iFile},'xpt','ypt','pethconv');
    yRangePSTH = 0;
    choice = find(result~=0);
    if any(choice==2 | choice==5)
        choice = [5 2 4 1];
    else
        choice = [6 3 4 1];
    end
    
%% PETH and Raster for epoch
    for iCol = 1:4
% Raster
        axes('Position',axpt(iCol,mod(iFile-1,nRow)+1,1,:)); % Raster
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
            plot(xpt{epoch(iCol),iChoice},ypt{epoch(iCol),iChoice},...
                'LineStyle','-','LineWidth',0.1,'Color',lineColor{iChoice});
        end
        set(gca,'box','off','TickDir','out','LineWidth',0.2,'FontSize',4,...
            'XLim',window(epoch(iCol),:),'XTick',[],...
            'YLim',[0 ntrial]);

% PETH
        hpeth(iCol) = axes('Position',axpt(iCol,mod(iFile-1,nRow)+1,2,:)); % PSTH
        hold on;
        if iFile < nFile
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
        for jChoice = choice
            plot(bins{epoch(iCol)},pethconv{epoch(iCol)}(jChoice,:),...
                'LineStyle','-','LineWidth',lineWidth(jChoice),'Color',lineColor{jChoice});
            yRangePSTH = max([yRangePSTH max(pethconv{epoch(iCol)}(jChoice,:))]);
        end
        set(gca,'box','off','TickDir','out','LineWidth',0.2,'FontSize',4);        
    end
    set(hpeth(1),'YLim',[0 ceil(yRangePSTH*1.10)],'YTick',[0 ceil(yRangePSTH*1.10)],'YTickLabel',{'     ',ceil(yRangePSTH*1.10)},'YColor','k');
    set(hpeth(2:end),'YLim',[0 ceil(yRangePSTH*1.10)],'YTick',[],'YColor','k');
end

cd(rtdir);
print(gcf,'-depsc','D:\Cloud\project\workingmemory_interneuron\fig\Fig3\fig3a_20150930.eps');