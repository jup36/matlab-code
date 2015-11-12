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
tagIndex = [];

% calculate discrimination index and p value
for iFile = 1:nFile
    [cellPath,~,~] = fileparts(matFile{iFile});
    cd(cellPath);
    load(matFile{iFile});
    load('Events.mat');
    
    if find(trialResult==0,1)<9 || find(cueResult==0,1)<5; 
        dCue(iFile,:) = NaN;
        dRw(iFile,:) = NaN;
        tagIndex(iFile) = NaN;
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
   
    cellList{iFile,1} = matFile{iFile};
    
    if p_tagRed<0.05
        tagIndex(iFile) = 1; 
    else
        tagIndex(iFile) = NaN;
    end
end

pRw = NaN(1,4);
[~,pCue(1)] = ttest(dCue(:,1),dCue(:,2)); % |A-B|/Std
[~,pCue(2)] = ttest(dCue(:,3),dCue(:,4)); % |A-B|/|A+B|
[~,pRw(1)] = ttest(dRw(:,1),dRw(:,2)); % in Cue A; |A-B|/Std 
[~,pRw(2)] = ttest(dRw(:,3),dRw(:,4)); % in Cue B; |A-B|/Std
[~,pRw(3)] = ttest(dRw(:,5),dRw(:,6)); % in Cue A; |A-B|/|A+B|
[~,pRw(4)] = ttest(dRw(:,7),dRw(:,8)); % in Cue B; |A-B|/|A+B|

[~,pCueMod(1)] = ttest(dCue(:,1).*tagIndex(:),dCue(:,2).*tagIndex(:));
[~,pRwMod(1)] = ttest(dRw(:,1).*tagIndex(:),dRw(:,2).*tagIndex(:));
[~,pRwMod(2)] = ttest(dRw(:,3).*tagIndex(:),dRw(:,4).*tagIndex(:));


% make plot

fHandle = figure('Position',[500 500 1200 400]);
fCueXMod = axes('Position',axpt(3,1,1,1));
hold on;
axisLim = ceil(max(dCue(:)));
plot([0:axisLim],[0:axisLim],'Color',[0.6 0.8 1.0],'LineWidth',2);
plot(dCue(:,1),dCue(:,2),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0.4 0.4 0.4],'MarkerFaceColor',[0.4 0.4 0.4]);
plot(dCue(:,1).*tagIndex(:),dCue(:,2).*tagIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
set(fCueXMod,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
ylabel('With Modulation');
xlabel('Without Modulation');
title('Cue Discrimination Index');
text(axisLim*0.1,axisLim*0.9,['p =', num2str(pCue(1),3)],'FontSize',8);
axis equal
axis tight

fRewardXModXCueA = axes('Position',axpt(3,1,2,1));
hold on;
axisLim = ceil(max(max(dRw(:,1:2))));
plot([0:axisLim],[0:axisLim],'Color',[0.6 0.8 1.0],'LineWidth',2);
plot(dRw(:,1),dRw(:,2),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0.4 0.4 0.4],'MarkerFaceColor',[0.4 0.4 0.4]);
plot(dRw(:,1).*tagIndex(:),dRw(:,2).*tagIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
set(fRewardXModXCueA,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
xlabel('Without Modulation');
title('Reward Discrimination Index ( CueA )');
text(axisLim*0.1,axisLim*0.9,['p =', num2str(pRw(1),3)],'FontSize',8);
axis equal
axis tight

fRewardXModXCueA = axes('Position',axpt(3,1,3,1));
hold on;
axisLim = ceil(max(max(dRw(:,3:4))));
plot([0:axisLim],[0:axisLim],'Color',[0.6 0.8 1.0],'LineWidth',2);
plot(dRw(:,3),dRw(:,4),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0.4 0.4 0.4],'MarkerFaceColor',[0.4 0.4 0.4]);
plot(dRw(:,3).*tagIndex(:),dRw(:,4).*tagIndex(:),'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
set(fRewardXModXCueA,'XLim',[0 axisLim],'YLim',[0 axisLim],'XTick',[0:axisLim],'YTick',[0:axisLim]);
xlabel('Without Modulation');
title('Reward Discrimination Index ( CueB )');
text(axisLim*0.1,axisLim*0.9,['p =', num2str(pRw(2),3)],'FontSize',8);
axis equal
axis tight

% save files
cd(saveDir);
set(gcf,'PaperPositionMode','auto');
print(fHandle,'-dtiff','-r600',['Discrimination Index_',figName{4},'_tif']);
save('discrimination.mat','dCue','dRw','cellList','pCue','pRw','tagIndex','pCueMod','pRwMod');
end
