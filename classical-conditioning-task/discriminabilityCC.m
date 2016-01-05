function discriminabilityCC(sessionFolder)

% make discrimination index for cue and reward, in modulation and no
% modulation trials

clf;
saveDir = pwd;
figName = regexp(saveDir,'\','split');

% collect matfiles 
if nargin == 0
    matFile = FindFiles('T*.mat','CheckSubdirs',1); 
else
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        matFile = FindFiles('T*.t','CheckSubdirs',1);
    else
        nFolder = length(sessionFolder);
        matFile = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder})==7 
                cd(sessionFolder{iFolder});
                matFile = [matFile;FindFiles('T*.t','CheckSubdirs',1)];
            elseif strcmp(sessionFolder{iFolder}(end-1:end),'.t') 
                matFile = [matFile;sessionFolder{iFolder}];
            end
        end
    end
end
if isempty(matFile)
    disp('TT file does not exist!');
    return;
end

nFile = length(matFile);

% make variables 
dCue = zeros(nFile,4);
dRw = zeros(nFile,8);
cueWindow = [0 2]*10^3;
cueWinLength = diff(cueWindow);
rewardWindow = [0 1]*10^3;
rewardWinLength = diff(rewardWindow);
cellList = {};
actIndex = [];
inhIndex = [];
totalCellNum = 0;

% calculate discrimination index and p value
for iFile = 1:nFile
    [cellPath,~,~] = fileparts(matFile{iFile});
    cd(cellPath);
    load(matFile{iFile});
    load('Events.mat');
    
    if find(trialResult==0,1)<9 || find(cueResult==0,1)<5 || isempty(H1_tagRed) || isempty(H2_tagRed); 
        dCue(iFile,:) = NaN;
        dRw(iFile,:) = NaN;
        actIndex(iFile) = NaN;
        inhIndex(iFile) = NaN;
        continue;
    end
    
    spikeTime4Cue = [];
    spikeTime4Rw = [];
   
    [~,spikeTime4Cue] = spikeBin(spikeTime, cueWindow, cueWinLength, cueWinLength);
    [~,spikeTime4Rw] = spikeBin(spikeTimeRw, rewardWindow, rewardWinLength, rewardWinLength);
    
    meanFR4Cue = mean(repmat(spikeTime4Cue,1,4).*cueIndex(:,1:4));
    stdFR4Cue = std(repmat(spikeTime4Cue,1,4).*cueIndex(:,1:4));
    meanFR4Rw = mean(repmat(spikeTime4Rw,1,8).*trialIndex(:,1:8));
    stdFR4Rw = std(repmat(spikeTime4Rw,1,8).*trialIndex(:,1:8));
        
    dCue(iFile,1) = abs(meanFR4Cue(1)-meanFR4Cue(3))/sqrt(stdFR4Cue(1)^2/cueResult(1)+stdFR4Cue(3)^2/cueResult(3)); % d' for cue in no mod trials ; |A-B|/Std
    dCue(iFile,2) = abs(meanFR4Cue(2)-meanFR4Cue(4))/sqrt(stdFR4Cue(2)^2/cueResult(2)+stdFR4Cue(4)^2/cueResult(4)); % d' for cue in mod trials ; |A-B|/Std
    
    dCue(iFile,3) = abs(meanFR4Cue(1)-meanFR4Cue(3))/(meanFR4Cue(1)+meanFR4Cue(3)); % d' for cue in no mod trials ; |A-B|/|A+B|
    dCue(iFile,4) = abs(meanFR4Cue(2)-meanFR4Cue(4))/(meanFR4Cue(2)+meanFR4Cue(4)); % d' for cue in mod trials ; |A-B|/|A+B|
    
    for iType = 1:4
        dRw(iFile,iType) = abs(meanFR4Rw(iType)-meanFR4Rw(iType+2))/sqrt(stdFR4Rw(iType)^2/trialResult(iType)+stdFR4Rw(iType+2)^2/trialResult(iType+2));
         % d' for reward in (cueA, no mod trials / cueA,mod trials / ..) ; |A-B|/Std
        dRw(iFile,iType+4) = abs(meanFR4Rw(iType)-meanFR4Rw(iType+2))/(meanFR4Rw(iType)+meanFR4Rw(iType+2)); % |A-B|/|A+B|
    end 
   
    cellList{iFile} = matFile{iFile};
    H1_tagRedEnd = H1_tagRed(~isnan(H1_tagRed));
    H1_tagRedEnd = H1_tagRedEnd(end);
    H2_tagRedEnd = H2_tagRed(~isnan(H2_tagRed));
    H2_tagRedEnd = H2_tagRedEnd(end);
    
    if p_tagRed<0.05 && (H1_tagRedEnd < H2_tagRedEnd)
        inhIndex(iFile) = 1; actIndex(iFile) = NaN;
    elseif p_tagRed<0.05 && (H1_tagRedEnd >= H2_tagRedEnd)
        actIndex(iFile) = 1; inhIndex(iFile) = NaN;
    else
        actIndex(iFile) = NaN; inhIndex(iFile) = NaN;
    end
    totalCellNum = totalCellNum+1;
end

pRw = NaN(1,4);
[~,pCue(1)] = ttest(dCue(:,1),dCue(:,2)); % |A-B|/Std
[~,pCue(2)] = ttest(dCue(:,3),dCue(:,4)); % |A-B|/|A+B|
[~,pRw(1)] = ttest(dRw(:,1),dRw(:,2)); % in Cue A; |A-B|/Std 
[~,pRw(2)] = ttest(dRw(:,3),dRw(:,4)); % in Cue B; |A-B|/Std
[~,pRw(3)] = ttest(dRw(:,5),dRw(:,6)); % in Cue A; |A-B|/|A+B|
[~,pRw(4)] = ttest(dRw(:,7),dRw(:,8)); % in Cue B; |A-B|/|A+B|

[~,pCueAct(1)] = ttest(dCue(:,1).*actIndex(:),dCue(:,2).*actIndex(:));                                                                                                                     
[~,pRwAct(1)] = ttest(dRw(:,1).*actIndex(:),dRw(:,2).*actIndex(:));
[~,pRwAct(2)] = ttest(dRw(:,3).*actIndex(:),dRw(:,4).*actIndex(:));

[~,pCueInh(1)] = ttest(dCue(:,1).*inhIndex(:),dCue(:,2).*inhIndex(:));
[~,pRwInh(1)] = ttest(dRw(:,1).*inhIndex(:),dRw(:,2).*inhIndex(:));
[~,pRwInh(2)] = ttest(dRw(:,3).*inhIndex(:),dRw(:,4).*inhIndex(:));

[~,pCueAct(2)] = ttest(dCue(:,3).*actIndex(:),dCue(:,4).*actIndex(:));                                                                                                                     
[~,pRwAct(3)] = ttest(dRw(:,5).*actIndex(:),dRw(:,6).*actIndex(:));
[~,pRwAct(4)] = ttest(dRw(:,7).*actIndex(:),dRw(:,8).*actIndex(:));

[~,pCueInh(2)] = ttest(dCue(:,3).*inhIndex(:),dCue(:,4).*inhIndex(:));
[~,pRwInh(3)] = ttest(dRw(:,5).*inhIndex(:),dRw(:,6).*inhIndex(:));
[~,pRwInh(4)] = ttest(dRw(:,7).*inhIndex(:),dRw(:,8).*inhIndex(:));

% make plot

fHandle = figure('Position',[500 500 1200 400]);
fCueXMod = axes('Position',axpt(3,1,1,1));
hold on;
axisLim = ceil(max(dCue(:,1:2)));
plot([0:axisLim],[0:axisLim],'Color',[0.6 0.8 1.0],'LineWidth',2);
plot(dCue(:,1),dCue(:,2),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0.4 0.4 0.4],'MarkerFaceColor',[0.4 0.4 0.4])
plot(dCue(:,1).*actIndex(:),dCue(:,2).*actIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
plot(dCue(:,1).*inhIndex(:),dCue(:,2).*inhIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1]);
set(fCueXMod,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
ylabel('With Modulation');
xlabel('Without Modulation');
title('Cue Discrimination Index');
text(axisLim*0.03,axisLim*0.9,[ 'Total        : ', num2str(totalCellNum), ' cells   ','p =', num2str(pCue(1),3)],'FontSize',8);
text(axisLim*0.03,axisLim*0.85,['Activated : ', num2str(sum(actIndex==1)), ' cells     ','p =', num2str(pCueAct(1),3)],'FontSize',8,'Color',[1 0 0]);
text(axisLim*0.03,axisLim*0.8,[ 'Inhibited  : ', num2str(sum(inhIndex==1)), ' cells       ','p =', num2str(pCueInh(1),3)],'FontSize',8,'Color',[0 0 1]);
axis equal
axis tight

fRewardXModXCueA = axes('Position',axpt(3,1,2,1));
hold on;
axisLim = ceil(max(max(dRw(:,1:2))));
plot([0:axisLim],[0:axisLim],'Color',[0.6 0.8 1.0],'LineWidth',2);
plot(dRw(:,1),dRw(:,2),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0.4 0.4 0.4],'MarkerFaceColor',[0.4 0.4 0.4]);
plot(dRw(:,1).*actIndex(:),dRw(:,2).*actIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
plot(dRw(:,1).*inhIndex(:),dRw(:,2).*inhIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1]);set(fRewardXModXCueA,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
set(fRewardXModXCueA,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
xlabel('Without Modulation');
title('Reward Discrimination Index ( CueA )');
text(axisLim*0.1,axisLim*0.9,['p =', num2str(pRw(1),3)],'FontSize',8);
text(axisLim*0.1,axisLim*0.85,['p =', num2str(pRwAct(1),3)],'FontSize',8,'Color',[1 0 0]);
text(axisLim*0.1,axisLim*0.8,['p =', num2str(pRwInh(1),3)],'FontSize',8,'Color',[0 0 1]);
axis equal
axis tight

fRewardXModXCueB = axes('Position',axpt(3,1,3,1));
hold on;
axisLim = ceil(max(max(dRw(:,3:4))));
plot([0:axisLim],[0:axisLim],'Color',[0.6 0.8 1.0],'LineWidth',2);
plot(dRw(:,3),dRw(:,4),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0.4 0.4 0.4],'MarkerFaceColor',[0.4 0.4 0.4]);
plot(dRw(:,3).*actIndex(:),dRw(:,4).*actIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
plot(dRw(:,3).*inhIndex(:),dRw(:,4).*inhIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1]);set(fRewardXModXCueA,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
set(fRewardXModXCueB,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
xlabel('Without Modulation');
title('Reward Discrimination Index ( CueB )');
text(axisLim*0.1,axisLim*0.9,['p =', num2str(pRw(2),3)],'FontSize',8);
text(axisLim*0.1,axisLim*0.85,['p =', num2str(pRwAct(2),3)],'FontSize',8,'Color',[1 0 0]);
text(axisLim*0.1,axisLim*0.8,['p =', num2str(pRwInh(2),3)],'FontSize',8,'Color',[0 0 1]);
axis equal
axis tight



fHandle2 = figure('Position',[500 500 1200 400]);
fCueXMod2 = axes('Position',axpt(3,1,1,1));
hold on;
axisLim = ceil(max(max(dCue(:,3:4))));
plot([0:axisLim],[0:axisLim],'Color',[0.6 0.8 1.0],'LineWidth',2);
plot(dCue(:,3),dCue(:,4),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0.4 0.4 0.4],'MarkerFaceColor',[0.4 0.4 0.4])
plot(dCue(:,3).*actIndex(:),dCue(:,4).*actIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
plot(dCue(:,3).*inhIndex(:),dCue(:,4).*inhIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1]);
set(fCueXMod2,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
ylabel('With Modulation');
xlabel('Without Modulation');
title('Cue Discrimination Index');
text(axisLim*0.03,axisLim*0.9,[ 'Total        : ', num2str(totalCellNum), ' cells   ','p =', num2str(pCue(2),3)],'FontSize',8);
text(axisLim*0.03,axisLim*0.85,['Activated : ', num2str(sum(actIndex==1)), ' cells     ','p =', num2str(pCueAct(1),3)],'FontSize',8,'Color',[1 0 0]);
text(axisLim*0.03,axisLim*0.8,[ 'Inhibited  : ', num2str(sum(inhIndex==1)), ' cells       ','p =', num2str(pCueInh(1),3)],'FontSize',8,'Color',[0 0 1]);
axis equal
axis tight

fRewardXModXCueA2 = axes('Position',axpt(3,1,2,1));
hold on;
axisLim = ceil(max(max(dRw(:,5:6))));
plot([0:axisLim],[0:axisLim],'Color',[0.6 0.8 1.0],'LineWidth',2);
plot(dRw(:,5),dRw(:,6),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0.4 0.4 0.4],'MarkerFaceColor',[0.4 0.4 0.4]);
plot(dRw(:,5).*actIndex(:),dRw(:,6).*actIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
plot(dRw(:,5).*inhIndex(:),dRw(:,6).*inhIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1]);set(fRewardXModXCueA,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
set(fRewardXModXCueA2,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
xlabel('Without Modulation');
title('Reward Discrimination Index ( CueA )');
text(axisLim*0.1,axisLim*0.9,['p =', num2str(pRw(3),3)],'FontSize',8);
text(axisLim*0.1,axisLim*0.85,['p =', num2str(pRwAct(1),3)],'FontSize',8,'Color',[1 0 0]);
text(axisLim*0.1,axisLim*0.8,['p =', num2str(pRwInh(1),3)],'FontSize',8,'Color',[0 0 1]);
axis equal
axis tight

fRewardXModXCueB2 = axes('Position',axpt(3,1,3,1));
hold on;
axisLim = ceil(max(max(dRw(:,7:8))));
plot([0:axisLim],[0:axisLim],'Color',[0.6 0.8 1.0],'LineWidth',2);
plot(dRw(:,7),dRw(:,8),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0.4 0.4 0.4],'MarkerFaceColor',[0.4 0.4 0.4]);
plot(dRw(:,7).*actIndex(:),dRw(:,8).*actIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
plot(dRw(:,7).*inhIndex(:),dRw(:,8).*inhIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1]);set(fRewardXModXCueA,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
set(fRewardXModXCueB2,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
xlabel('Without Modulation');
title('Reward Discrimination Index ( CueB )');
text(axisLim*0.1,axisLim*0.9,['p =', num2str(pRw(4),3)],'FontSize',8);
text(axisLim*0.1,axisLim*0.85,['p =', num2str(pRwAct(2),3)],'FontSize',8,'Color',[1 0 0]);
text(axisLim*0.1,axisLim*0.8,['p =', num2str(pRwInh(2),3)],'FontSize',8,'Color',[0 0 1]);
axis equal
axis tight




% save files
cd(saveDir);
set(gcf,'PaperPositionMode','auto');
print(fHandle,'-dtiff','-r600',['Discrimination Index_',figName{4},'_std']);
print(fHandle2,'-dtiff','-r600',['Discrimination Index_',figName{4},'_A+B']);
save('discrimination.mat','dCue','dRw','cellList','pCue','pRw','actIndex','inhIndex','pCueAct','pCueInh','pRwAct','pRwInh');
end
