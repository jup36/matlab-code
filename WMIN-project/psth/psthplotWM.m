function psthplotWM(folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Object: Mat으로 저장된 정보로 PSTH/Raster/Tagging 등의 그림을 그린다.
% Author: Dohoung Kim
% First written: 2014/09/19
%
% Ver 2.0 (2015. 1. 7)
%   Function 수정
%   Figure file은 처음 실행한 directory에서 저장되도록
%   Modulation하지 않은 파일만 분석한다. 
% Ver 2.1 (2015. 1. 9)
%   Log-rank test plot 추가
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
win = [-20 100]; % Tagging period
p_value = 0.05; % Threshold for tagging

% Plot properties
lineclr={[1 0 0],[1 0.5 0.5],[1 0.3 0.3]...
        [0 0 1],[0.5 0.5 1],[0.3 0.3 1]};
linewth=[0.75 0.5 0.5 0.75 0.5 0.5];

% Find files
switch nargin
    case 0 % Input이 없는 경우 그냥 폴더안의 mat 파일을 검색
        matfile = FindFiles('T*.mat','CheckSubdirs',0); % Subfolder는 검색하지 않는다
        if isempty(matfile)
            disp('Mat file does not exist!');
            return;
        end
    case 1 % Input이 있는 경우
        if ~iscell(folders) % 셀 array인지 확인
            disp('Input argument is wrong. It should be cell array.');
            return;
        elseif isempty(folders) % Cell이 맞지만 텅 비었으면 그냥 폴더 안의 mat파일 검색
            matfile = FindFiles('T*.mat','CheckSubdirs',1); % Subfolder 검색.
            if isempty(matfile)
                disp('Mat file does not exist!');
                return;
            end
        else % Cell이 맞고 빈 array가 아니면, 차례대로 cell 내용물 확인
            nfolder = length(folders);
            matfile = cell(0,1);
            for ifolder = 1:nfolder
                if exist(folders{ifolder})==7 % 폴더이면 그 아래 폴더들의 mat파일 검색
                    cd(folders{ifolder});
                    matfile = [matfile;FindFiles('T*.mat','CheckSubdirs',1)];
                elseif strcmp(folders{ifolder}(end-3:end),'.mat') % mat파일이면 바로 합친다.
                    matfile = [matfile;folders{ifolder}];
                end
            end
            if isempty(matfile)
                disp('Mat file does not exist!');
                return;
            end
        end
end
nfiles = length(matfile);
rtdir = pwd;

% Plot position
row = 5;
startpoint = [0.40 0.1];
figwidth = [0.575 0.8];
interval_x = 0.005; interval_y = 0.05;
interfig_y = 0.01;
load(matfile{1},'window');
xwidth = diff(window,1,2);
xwidth = xwidth([1 4 5 8]);
xwidthsum = [0;cumsum(xwidth)];
dx = (figwidth(1)-3*interval_x)/xwidthsum(end);
dy = (figwidth(2)-(row-1)*interval_y-row*interfig_y)/(2*row);
axpt = zeros(4,row,2,4);
for irow = 1:row
    for iax = 1:4
        axpt(iax,irow,1,:) = [startpoint(1)+(iax-1)*interval_x+dx*xwidthsum(iax),...
            startpoint(2)+(row-irow)*(2*dy+interfig_y+interval_y)+interfig_y+interval_y,...
            xwidth(iax)*dx dy];
        axpt(iax,irow,2,:) = [startpoint(1)+(iax-1)*interval_x+dx*xwidthsum(iax),...
            startpoint(2)+(row-irow)*(2*dy+interfig_y+interval_y),...
            xwidth(iax)*dx dy];
    end
end

load(matfile{1},'bins');
hpeth = zeros(1,4);
ipage = 0;
epoch = [1 4 5 8];

for ifiles = 1:nfiles
    [cellcd,cellname,~] = fileparts(matfile{ifiles});
    
    cd(cellcd);
    
    load('Events.mat','ntrial','result','lighttime');
    lighttrial = length(lighttime);
    load(matfile{ifiles},'xpt','ypt','pethconv');
    ylims = 0;
%% PETH and Raster for epoch
    for icol = 1:4
% Raster
        axes('Position',axpt(icol,mod(ifiles-1,row)+1,1,:)); % Raster
            hold on;
            for ichoice = find(result~=0)
                plot(xpt{epoch(icol),ichoice},ypt{epoch(icol),ichoice},...
                    'LineStyle','-','LineWidth',0.2,'Color',lineclr{ichoice});
            end
            set(gca,'XLim',window(epoch(icol),:),'XTick',[],'XColor','w');
            set(gca,'YLim',[0 ntrial],'YColor','k');
            set(gca,'box','off','TickDir','out','FontSize',4);
            switch icol
                case 1
                    ylabel('Trials');
                    plot([0 0],[1 ntrial],'LineStyle','-','LineWidth',0.3,'Color',[0.7 0.7 0.7]);
                    set(gca,'YTick',[0 ntrial],'YTickLabel',{[],ntrial});
                case 2
                    plot([0 0],[1 ntrial],'LineStyle','-','LineWidth',0.3,'Color',[0.7 0.7 0.7]);
                    set(gca,'YTick',[]);
                case 3
                    plot([0 0],[1 ntrial],'LineStyle','-','LineWidth',0.3,'Color',[0.7 0.7 0.7]);
                    plot([3 3],[1 ntrial],'LineStyle','-','LineWidth',0.3,'Color',[0.7 0.7 0.7]);
                    set(gca,'YTick',[]);
                case 4
                    plot([0 0],[1 ntrial],'LineStyle','-','LineWidth',0.3,'Color',[0.7 0.7 0.7]);
                    set(gca,'YTick',[]);
            end

% PETH
        hpeth(icol) = axes('Position',axpt(icol,mod(ifiles-1,row)+1,2,:)); % PSTH
            hold on;
            for jchoice = find(result~=0)
                plot(bins{epoch(icol)},pethconv{epoch(icol)}(jchoice,:),...
                    'LineStyle','-','LineWidth',linewth(jchoice),'Color',lineclr{jchoice});
                ylims = max([ylims max(pethconv{epoch(icol)}(jchoice,:))]);
            end
            set(gca,'box','off','TickDir','out','FontSize',4);

            switch icol
                case 1
                    ylabel('Spikes s^-^1');
                    plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.7 0.7 0.7]);
                    set(gca,'XLim',window(epoch(icol),:),'XTick',[-1:3],'XTickLabel',{[],0,[],[2],[]});
                case 2
                    plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.7 0.7 0.7]);
                    set(gca,'XLim',window(epoch(icol),:),'XTick',[-1:3],'XTickLabel',{[],0,[],[2],[]});
                case 3
                    plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.7 0.7 0.7]);
                    plot([3 3],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.7 0.7 0.7]);
                    set(gca,'XLim',window(epoch(icol),:),'XTick',[-1:4],'XTickLabel',{[],0,[],[],[3],[]});
                case 4
                    plot([0 0],[0.01 100],'LineStyle','-','LineWidth',0.3,'Color',[0.7 0.7 0.7]);
                    set(gca,'XLim',window(epoch(icol),:),'XTick',[-2:10],'XTickLabel',{[],[],0,[],[],[3],[],[],[6],[],[],[9],[]});
            end
    end
    set(hpeth(1),'YLim',[0 ceil(ylims)],'YTick',[0 ceil(ylims)],'YColor','k');
    set(hpeth(2:end),'YLim',[0 ceil(ylims)],'YTick',[],'YColor','k');
    axes('Position',[axpt(1,1,2,1) axpt(1,mod(ifiles-1,row)+1,2,2)-0.03 0.4 0.1])
        text(0,0,matfile{ifiles},'FontSize',4,'interpreter','none');
        set(gca,'Visible','off');
%% Tagging
    clear xpttag ypttag bintag taghist time_tagstat H1_tagstat H2_tagstat p_tagstat;
    load(matfile{ifiles},'xpttag','ypttag','bintag','taghist','time_tagstat','H1_tagstat','H2_tagstat','p_tagstat');
    if ~isempty(xpttag)
        axes('Position',[axpt(1,mod(ifiles-1,row)+1,1,1)-0.35 axpt(1,mod(ifiles-1,row)+1,1,2) axpt(1,mod(ifiles-1,row)+1,1,3) axpt(1,mod(ifiles-1,row)+1,1,4)]);
            hold on;
            plot(xpttag,ypttag,...
                    'Marker','.','MarkerSize',2,'Color','k');
            set(gca,'XLim',win,'XTick',[],'XColor','w');
            set(gca,'YLim',[0 lighttrial],'YTick',[0 lighttrial],'YTickLabel',{[],lighttrial},'YColor','k');
            set(gca,'box','off','TickDir','out','FontSize',4);
            ylabel('Trials');

        axes('Position',[axpt(1,mod(ifiles-1,row)+1,2,1)-0.35 axpt(1,mod(ifiles-1,row)+1,2,2) axpt(1,mod(ifiles-1,row)+1,2,3) axpt(1,mod(ifiles-1,row)+1,2,4)]);
            hold on;
            h = bar(bintag,taghist,'histc');
            ylims2 = ceil(max(taghist(:)));
            if ylims2 ==0; ylims2=1; end;
            set(h,'FaceColor','k','EdgeAlpha',0);
            set(gca,'XLim',win);
            set(gca,'YLim',[0 ylims2],'YTick',[0 ylims2],'YColor','k');
            set(gca,'Box','off','TickDir','out','FontSize',4);
            ylabel('Spikes s^-^1');

        axes('Position',[axpt(1,mod(ifiles-1,row)+1,1,1)-0.20 axpt(1,mod(ifiles-1,row)+1,2,2) axpt(1,mod(ifiles-1,row)+1,2,3)*0.6 axpt(1,mod(ifiles-1,row)+1,2,4)]);
            hold on;
            stairs(time_tagstat,H1_tagstat,'LineStyle','-','LineWidth',0.5,'Color',[0 0.66 1]);
            stairs(time_tagstat,H2_tagstat,'LineStyle',':','LineWidth',0.5,'Color',[0 0 0]);
            ylimst = max([H1_tagstat;H2_tagstat])*1.1;
            if isempty(ylimst) | ylimst==0; ylimst=1; end;
            set(gca,'Box','off','TickDir','out','FontSize',4);
            set(gca,'XLim',[0 10],'XTick',[0 10]);
            set(gca,'YLim',[0 ylimst],'YTick',[0 ylimst],'YTickLabel',{[0],num2str(ylimst,1)});
            xlabel('Time (ms)');
            ylabel('H(t)');

        axes('Position',[axpt(1,mod(ifiles-1,row)+1,1,1)-0.22 axpt(1,mod(ifiles-1,row)+1,1,2) axpt(1,mod(ifiles-1,row)+1,2,3)*0.6 dy]);
            hold on;
            text(0,0.5,['p value for tag test: ',num2str(p_tagstat,2)],'FontSize',4,'interpreter','none');
            if p_tagstat <= p_value
                if H1_tagstat(end) >= H2_tagstat(end)
                    text(0,0.3,['Activated neuron'],'FontSize',4,'interpreter','none');
                else
                    text(0,0.3,['Inhibited neuron'],'FontSize',4,'interpreter','none');
                end
            end
            set(gca,'visible','off');
    end
%         if pvalueext <= 0.01
%             text(-50,ylims2*(-0.5),['p Value for maximal excitation after ',num2str(extslide-1),' ms = ',num2str(pvalueext,'%.1e')],'FontSize',4,'interpreter','none');
%         elseif pvalueinh <= 0.01
%             text(-50,ylims2*(-0.5),['p Value for maximal inhibition after ',num2str(inhslide-1),' ms = ',num2str(pvalueinh,'%.1e')],'FontSize',4,'interpreter','none');
%         end
%% Waveform
     load(matfile{ifiles},'spkwv','hfvwth','spkpvr','fr_base','fr_task');
     ylims3 = [min(spkwv(:)) max(spkwv(:))];
    
    for ich = 1:4
        axes('Position',[axpt(1,mod(ifiles-1,row)+1,1,1)-0.13+(ich-1)*dx*0.8 axpt(1,mod(ifiles-1,row)+1,2,2) dx*0.8 dy]);
        plot(spkwv(ich,:),'LineStyle','-','LineWidth',0.4,'Color',[0.2 0.2 0.2]);
        
        set(gca,'XLim',[1 32]);
        set(gca,'YLim',ylims3);
        set(gca,'visible','off');
        if ich==4
            line([24 32],[ylims3(2)-50 ylims3(2)-50],'color','k','LineWidth',0.2); 
            line([24 24],[ylims3(2)-50 ylims3(2)],'color','k','LineWidth',0.2);
        end
    end
    
     axes('Position',[axpt(1,mod(ifiles-1,row)+1,1,1)-0.13 axpt(1,mod(ifiles-1,row)+1,1,2) 4*dx dy]);
        hold on;
         text(0,0.9,['Base firing rate: ',num2str(fr_base,3)],'FontSize',4,'interpreter','none');
         text(0,0.7,['Task firing rate: ',num2str(fr_task,3)],'FontSize',4,'interpreter','none');
         text(0,0.5,['Half-valley width: ',num2str(hfvwth,3),' us'],'FontSize',4,'interpreter','none');
         text(0,0.3,['Peak valley ratio: ',num2str(spkpvr,3)],'FontSize',4,'interpreter','none');
         set(gca,'visible','off');
       
%% Title and save image        
    if (mod(ifiles,row)==0 | ifiles == nfiles)
        axes('Position',[axpt(1,1,1,1) axpt(1,1,1,2)+dy+0.005 axpt(1,1,1,3) 0.05]);
            text(0.005,0,'Return','FontSize',4,'interpreter','none');
            text(0.4,0,'Sample start','FontSize',4,'interpreter','none');
            set(gca,'Visible','off');
        axes('Position',[axpt(2,1,1,1) axpt(2,1,1,2)+dy+0.005 axpt(2,1,1,3) 0.1]);
            text(0.35,0,'Sample reward zone','FontSize',4,'interpreter','none');
            set(gca,'Visible','off');
        axes('Position',[axpt(3,1,1,1) axpt(3,1,1,2)+dy+0.005 axpt(3,1,1,3) 0.1]);
            text(0.45,0,'Delay','FontSize',4,'interpreter','none');
            text(0.87,0,'Go','FontSize',4,'interpreter','none');
            set(gca,'Visible','off');
        axes('Position',[axpt(4,1,1,1) axpt(4,1,1,2)+dy+0.005 axpt(4,1,1,3) 0.1]);
            text(0.03,0,'Approach','FontSize',4,'interpreter','none');
            text(0.5,0,'Reward','FontSize',4,'interpreter','none');   
            set(gca,'Visible','off');
        cd(rtdir);
        if nargin == 0
            cd('..');
        end
        ipage = ipage + 1;
        cell_filename = regexp(cellcd,'\','split');
        cellfile = strcat(cell_filename(end-1),'_',cell_filename(end),'_Raster_',num2str(ipage),'.tif');
        print(gcf,'-dtiff','-r600',cellfile{1});
        clf;
    end
end
close all;
cd(rtdir);