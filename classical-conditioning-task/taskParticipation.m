function taskParticipation(sessionFolder)
%psthplotCC licking rate and cell firing rate trend analysis
% find out where there's resting state

lineClrMod = {[0.8 0 0], [1 0.4 0.4], [1 0.6 0.6], ... % Cue A, Rw, (no mod / mod A / mod B)
    [153 204 0]./255, [204 255 102]./255, [204 255 102]./255,... % Cue B, Rw, (no mod / mod A / mod B)
    [1 0.6 0], [1 0.8 0.4], [1 0.8 0.4], ... % Cue C
    [0 0 0.8], [0.4 0.4 1], [0.6 0.6 1]};
markerMod = repmat({'o','v','v','s','^', '^'}, 1, 2);
lineS = 0.2;
lineL = 0.5;
colorGray = [204 204 204] ./ 255;

% Make lists of event files
narginchk(0, 2);
if nargin == 0
    eventFile = FindFiles('Events.nev','CheckSubdirs',0);
elseif nargin >= 1
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        eventFile = FindFiles('Events.nev','CheckSubdirs',0);
    else
        nFolder = length(sessionFolder);
        eventFile = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder},'dir')
                cd(sessionFolder{iFolder});
                eventFile = [eventFile;FindFiles('Events.nev','CheckSubdirs',1)];
            end
        end
    end
end
rtdir = pwd;

nFile = length(eventFile);
for iFile = 1:nFile
    [cellDir,cellName,~] = fileparts(eventFile{iFile});
    cellDirSplit = regexp(cellDir,'\','split');
    cellFigName = strcat(cellDirSplit(end-1),'_',cellDirSplit(end),'_fr_pattern_plot');
    
    cd(fileparts(eventFile{iFile}));
    load('Events.mat');
    tFile = FindFiles('T*.t');
    nCell = length(tFile);
    tData = LoadSpikes(tFile,'tsflag','sec','verbose',0);

    % convert all units to minutes
    baseTime = baseTime / (60*1000);
    taskTime = taskTime / (60*1000);
    tagTime = tagTime / (60*1000);
    lickOnsetTime = lickOnsetTime / (60*1000);
    eventTime = eventTime / (60*1000);

    binSize = 1/60;
    bin = baseTime(1):binSize:tagTime(2);
    resolution = 10;

    % mean lick rate
    lickTemp = histc(lickOnsetTime,bin)/(binSize*60);
    lickPlot = conv(lickTemp,fspecial('Gaussian',[1 5*resolution],resolution),'same');
    
    nCue = length(cueResult);
    lickCue = cell(nCue,2);
    for iCue = 1:nCue
        if cueResult(iCue)==0; continue; end;
        trialBin = [eventTime(cueIndex(:,iCue),2) eventTime(cueIndex(:,iCue),4)]';
        lickTrial = histc(lickOnsetTime,trialBin);
        lickTrial = reshape(lickTrial,2,[]);
        
        lickCue{iCue,1} = find(cueIndex(:,iCue));
        lickCue{iCue,2} = lickTrial(1,:);
    end
        
    % spike mean firing rate
    spikePlot = cell(nCell,1);
    for iCell = 1:nCell
        spikeData = Data(tData{iCell})/60;
        spikeTemp = histc(spikeData,bin)/(binSize*60);
        spikePlot{iCell} = conv(spikeTemp,fspecial('Gaussian',[1 5*resolution],resolution),'same');
    end
    
    % plot
    fHandle = figure('PaperUnits','centimeters','PaperPosition',[0 0 18.3 13.725]);
    axes('Position',axpt(2,ceil((nCell+2)/2),1,1));
    hold on;
    yLims = ceil(max(lickPlot)+0.00001);
    plot(bin,lickPlot,'LineWidth', lineL, 'Color','k');
    plot([baseTime(2) baseTime(2)],[0 yLims],'LineStyle', ':', 'LineWidth', lineL, 'Color',colorGray);
    plot([taskTime(1) taskTime(1)], [0 yLims],'LineStyle', ':', 'LineWidth', lineL, 'Color',colorGray);
    plot([taskTime(2) taskTime(2)],[0 yLims],'LineStyle', ':', 'LineWidth', lineL, 'Color',colorGray);
    plot([tagTime(1) tagTime(1)],[0 yLims],'LineStyle', ':', 'LineWidth', lineL, 'Color',colorGray);
    set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 4, ...
        'XLim', [bin(1) bin(end)], ...
        'YLim', [0 yLims]);
    title('Lick rate plot', 'FontSize', 4);
    
    axes('Position',axpt(2,ceil((nCell+2)/2),2,1));
    hold on;
    for jCue = 1:nCue
        if cueResult(jCue)==0; continue; end;
        plot(lickCue{jCue,1},lickCue{jCue,2}, ...
            'Marker', markerMod{jCue}, 'MarkerSize', 2.2, ...
            'LineWidth', lineL, 'Color', lineClrMod{jCue});
    end
    set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 4);
    title('Lick rate by cue', 'FontSize', 4);

    for jCell = 1:nCell
        axes('Position',axpt(2,ceil((nCell+2)/2),mod(jCell-1,2)+1,ceil(jCell/2)+1));
        hold on;
        yLims = ceil(max(spikePlot{jCell})+0.00001);
        plot(bin,spikePlot{jCell}, 'LineWidth', lineL, 'Color','k');
        plot([baseTime(2) baseTime(2)],[0 yLims],'LineStyle', ':', 'LineWidth', lineL, 'Color',colorGray);
        plot([taskTime(1) taskTime(1)], [0 yLims],'LineStyle', ':', 'LineWidth', lineL, 'Color',colorGray);
        plot([taskTime(2) taskTime(2)],[0 yLims],'LineStyle', ':', 'LineWidth', lineL, 'Color',colorGray);
        plot([tagTime(1) tagTime(1)],[0 yLims],'LineStyle', ':', 'LineWidth', lineL, 'Color',colorGray);
        set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 4, ...
            'XLim', [bin(1) bin(end)], ...
            'YLim', [0 yLims]);
        title(tFile{jCell},'FontSize', 4);
    end
    
    print(gcf,'-dtiff', '-r300', [cellFigName{1},'.tif']);
    close;
end
cd(rtdir);