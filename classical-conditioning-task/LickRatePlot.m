function LickRatePlot(sessionFolder)

% Find files
switch nargin
    case 0
        eventFile = FindFiles('Events.mat','CheckSubdirs',1); 
    case 1 
        if ~iscell(cellFolder) 
            disp('Input argument is wrong. It should be cell array.');
            return;
        elseif isempty(cellFolder)
            eventFile = FindFiles('Events.mat','CheckSubdirs',0);
        else
            nFolder = length(cellFolder);
            eventFile = cell(0,1);
            for iFolder = 1:nFolder
                if exist(sessionFolder{iFolder},'dir')
                cd(sessionFolder{iFolder});
                eventFile = [eventFile;FindFiles('Events.mat','CheckSubdirs',1)];
                end
            end
        end
end

if isempty(eventFile)
    disp('Mat file does not exist!');
    return;
end

nFile = length(eventFile);
rtdir = pwd;

colorBlue = [0 153 227] ./ 255;
colorLightBlue = [223 239 252] ./ 255;
colorRed = [237 50 52] ./ 255;
colorLightRed = [242 138 130] ./ 255;
colorGray = [204 204 204] ./ 255;
lineClr = {[0.8 0 0], [1 0.4 0.4], [1 0.6 0.6], ... % Cue A, Rw, (no mod / mod A / mod B)
    [153 204 0]./255, [204 255 102]./255, [204 255 102]./255,... % Cue B, Rw, (no mod / mod A / mod B)
    [1 0.6 0], [1 0.8 0.4], [1 0.8 0.4], ... % Cue C
    [0 0 0.8], [0.4 0.4 1], [0.6 0.6 1]};

binSize = 10; % ms
resolution = 10; % sigma = resolution * binSize = 100ms 

for iFile = 1:nFile
    cd(fileparts(eventFile{iFile}));
    load(eventFile{iFile});

    % Lick Raster, PSTH
    xptLick = {}; yptLick = {}; 
    lickRateTime = []; lickRateBar = []; lickRateConv = []; lickRateConvz = []; 
    
    nType = length(cueResult);
    lickWindow = [eventDuration(1)-0.5 maxTrialDuration]*10^3; % ms
    lickBin = lickWindow(1):binSize:lickWindow(2); % ms
    lickTime = spikeWin(lickOnsetTime, eventTime(:,2), lickWindow); % align to cue onset
    lickHistTemp = cellfun(@(x) reshape(histc(x,lickBin),1,length(lickBin)), lickTime, 'UniformOutput', false);
    lickHist = cell2mat(lickHistTemp)/(binSize/10^3);
    
    [xptLick, yptLick, lickRateTime, lickRateBar, lickRateConv, lickRateConvz] = rasterPSTH(lickTime,cueIndex,lickWindow,binSize,resolution,1);
    xptLick = cellfun(@(x) x/1000, xptLick, 'UniformOutput', false);
    lickRateTime = lickRateTime/10^3;
    
    lickRateSem = NaN(nType,length(lickBin));
    for iType = find(cueResult~=0)
        lickRateSem(iType,:) = std(lickHist(cueIndex(:,iType),:))/sqrt(cueResult(iType));
        lickRateSem(iType,:) = conv(lickRateSem(iType,:),fspecial('Gaussian', [1 5*resolution],resolution), 'same');
    end       
    
    save('Events.mat','xptLick','yptLick','lickRateTime','lickRateBar','lickRateConv','lickRateConvz','lickRateSem','-append');
    
    % Plot
    fHandle = figure('PaperUnits','centimeters','PaperPosition',[0 0 18.3 13.725]);

    hRaster = axes('Position',axpt(1,2,1,1));
    for iType = find(cueResult~=0)
        plot(xptLick{iType},yptLick{iType},...
            'Marker', '.', 'MarkerSize', 3, 'LineStyle', 'none', 'Color', lineClr{iType});
        hold on;
    end
    yLimRaster = [0 sum(cueResult)];
    set(hRaster, 'XLim', lickWindow/10^3, 'YLim', yLimRaster,'XTick',[],'YTick',yLimRaster(end),'Box','off');
    plot([0 0], yLimRaster,'Color',colorGray,'LineStyle','--');
    plot([1 1], yLimRaster,'Color',colorGray,'LineStyle','--');
    plot([2 2], yLimRaster,'Color',colorGray,'LineStyle','--');    
    ylabel('Trials');
    
    hPSTH = axes('Position',axpt(1,2,1,2));
    for iType = find(cueResult~=0)
        fill([lickRateTime flip(lickRateTime)], [lickRateConv(iType,:)-lickRateSem(iType,:), flip(lickRateConv(iType,:)+lickRateSem(iType,:))], ...
            lineClr{iType},'LineStyle','none','FaceAlpha',0.2);
        hold on;
        plot(lickRateTime,lickRateConv(iType,:),'Color', lineClr{iType},'LineWidth',3);
    end
    yLimPSTH = [floor(min(min(lickRateConv-lickRateSem))), ceil(max(max(lickRateConv+lickRateSem)))];
    set(hPSTH, 'XLim', lickWindow/10^3,'YLim',yLimPSTH,'Box','off');
    plot([0 0], yLimPSTH,'Color',colorGray,'LineStyle','--');
    plot([1 1], yLimPSTH,'Color',colorGray,'LineStyle','--');
    plot([2 2], yLimPSTH,'Color',colorGray,'LineStyle','--');   
    ylabel('Firing Rate [Hz]');
    xlabel('Time [s]');
  
    cellcd = strsplit(fileparts(eventFile{iFile}),'\');
    cellfile = strcat(cellcd(end-1),'_',cellcd(end),'_lickplot');
    print(fHandle,'-dtiff','-r600',[cellfile{1},'.tif']);
    cd(fileparts(eventFile{iFile}));
    close all;
end

% licking statistics
%     warning('off');
%     lickNum = zeros(nTrial,2);
%     for iTrial = 1:nTrial
%         lickNum(iTrial,:) = histc(lickOnsetTime,eventTime(iTrial,[2 4]));
%     end
%     lickNum = lickNum(:,1);
%     [pRankSum4Cue] = ranksum(lickNum(cueIndex(:,1)),lickNum(cueIndex(:,3)));
% %     [~,pTtest] = ttest2(lickNum(cueIndex(:,1)),lickNum(cueIndex(:,2)));
% %     [b, dev, stats] = glmfit([2-cue cumsum(reward)],lickNum,'poisson');
% 
%     [lickReg,lickRegXpt] = sliding(lickHist,50,10);
%     pValueReg = zeros(length(lickReg(1,:)),3);
%     pValueRegIndex = zeros(length(lickReg(1,:)),3);
%     for iRegBin = 1: length(lickReg(1,:))
%         [~,~,stat] = glmfit([cue-1 reward modulation],lickReg(:,iRegBin),'poisson');
%         pValueReg(iRegBin,:) = stat.p(2:4)';
%         pValueRegIndex(iRegBin,:) = stat.p(2:4)'<0.05;
%         pValueRegIndex(iRegBin,pValueRegIndex(iRegBin,:)==0) = NaN;
%     end
% 
%     save('Events.mat', ...
%         'xLickRaster','yLickRaster', ...
%         'lickHist','lickMean','lickSem','lickMeanConv','lickSemConv','-append');    
    


