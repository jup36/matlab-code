function psthplotCC(cellFolder)
%psthplotCC draws summary plot for each cell

% Find files
switch nargin
    case 0
        matFile = FindFiles('T*.mat','CheckSubdirs',0); 
    case 1 
        if ~iscell(cellFolder) 
            disp('Input argument is wrong. It should be cell array.');
            return;
        elseif isempty(cellFolder)
            matFile = FindFiles('T*.mat','CheckSubdirs',1);
        else
            nFolder = length(cellFolder);
            matFile = cell(0,1);
            for iFolder = 1:nFolder
                if exist(cellFolder{iFolder})==7
                    cd(cellFolder{iFolder});
                    matFile = [matFile;FindFiles('T*.mat','CheckSubdirs',1)];
                elseif strcmp(cellFolder{iFolder}(end-3:end),'.mat')
                    matFile = [matFile;cellFolder{iFolder}];
                end
            end
        end
end
if isempty(matFile)
    disp('Mat file does not exist!');
    return;
end
nFile = length(matFile);
rtdir = pwd;

% Plot properties
lineClr = {[0.8 0 0], ... % Cue A, Rw, no mod
    [1 0.6 0.6], ... % Cue A, Rw, mod
    [1 0.6 0], ... % Cue A, no Rw, no mod
    [1 0.8 0.4], ... % Cue A, no Rw, mod
    [0 0 0.8], ... % Cue B, Rw, no mod
    [0.6 0.6 1], ... % Cue B, Rw, mod
    [0 0.6 1], ... % Cue B, no Rw, no mod
    [0.4 0.8 1], ... % Cue B, no Rw, mod
    [1 0.6 0], ... % Cue C
    [1 1 0.4], ...
    [1 0.6 0], ...
    [1 1 0.4], ...
    [0 0.6 1], ... % Cue D
    [0.4 1 1], ...
    [0 0.6 1], ...
    [0.4 1 1]};
lineStl = {'-', '-', '-', '-', ...
    '-', '-', '-', '-', ...
    '-', '-', '-', '-', ...
    '-', '-', '-', '-'};
lineWth = [1 0.75 1 0.75 1 0.75 1 0.75 1 0.75 1 0.75 1 0.75 1 0.75];

fontS = 4; % font size small
fontM = 6; % font size middle
fontL = 8; % font size large
lineS = 0.2; % line width small
lineM = 0.5; % line width middle
lineL = 1; % line width large
colorBlue = [0 153 227] ./ 255;
colorLightBlue = [223 239 252] ./ 255;
colorRed = [237 50 52] ./ 255;
colorLightRed = [242 138 130] ./ 255;
colorGray = [204 204 204] ./ 255;
colorYellow = [255 243 3] ./ 255;
tightInterval = [0.02 0.02];
wideInterval = [0.07 0.07];
nCol = 4;
nRowSub = 8; % for the left column
nRowMain = 5; % for the main figure
markerS = 2.2;
markerM = 4.4;
markerL = 6.6;

for iFile = 1:nFile
    [cellDir,cellName,~] = fileparts(matFile{iFile});
    cellDirSplit = regexp(cellDir,'\','split');
    cellFigName = strcat(cellDirSplit(end-1),'_',cellDirSplit(end),'_',cellName);
    
    cd(cellDir);
    load(matFile{iFile});
    load('Events.mat');
    
    % Cell information
    fHandle = figure('PaperUnits','centimeters','PaperPosition',[0 0 18.3 13.725]);
    hText = axes('Position',axpt(1,2,1,1,axpt(nCol,nRowSub,1,1:2,[],wideInterval),tightInterval));
    hold on;
    text(0,1.2,matFile{iFile}, 'FontSize',fontM, 'Interpreter','none');
    text(0,0.9,['p_A = ',num2str(trialResult(1)/(trialResult(1)+trialResult(3)),2), ...
        ', p_B = ',num2str(trialResult(5)/(trialResult(5)+trialResult(7)),2)], 'FontSize', fontS);
    text(0,0.7,['Mean firing rate (baseline): ',num2str(fr_base,3), ' Hz'], 'FontSize',fontS);
    text(0,0.55,['Mean firing rate (task): ',num2str(fr_task,3), ' Hz'], 'FontSize',fontS);
    text(0,0.35,['Spike width: ',num2str(spkwth,3),' us'], 'FontSize',fontS);
    text(0,0.2,['Half-valley width: ',num2str(hfvwth,3),' us'], 'FontSize',fontS);
    text(0,0.05,['Peak valley ratio: ',num2str(spkpvr,3)], 'FontSize',fontS);
    set(hText,'Visible','off');
    
    % Waveform
    yLimWaveform = [min(spkwv(:)) max(spkwv(:))];
    for iCh = 1:4
        hWaveform(iCh) = axes('Position',axpt(4,2,iCh,2,axpt(nCol,nRowSub,1,1:2,[],wideInterval),tightInterval));
        plot(spkwv(iCh,:), 'LineWidth', lineL, 'Color','k');
        if iCh == 4
            line([24 32], [yLimWaveform(2)-50 yLimWaveform(2)-50], 'Color','k', 'LineWidth', lineM);
            line([24 24],[yLimWaveform(2)-50 yLimWaveform(2)], 'Color','k', 'LineWidth',lineM);
        end
    end
    set(hWaveform, 'Visible', 'off', ...
        'XLim',[1 32], 'YLim',yLimWaveform*1.05);
    
    %% Tagging
    % Blue tag
    if ~isempty(blueOnsetTime)
        nBlue = length(blueOnsetTime);
        winBlue = [min(psthtimeTagBlue) max(psthtimeTagBlue)];
                
        % Blue tag raster
        hTag(1) = axes('Position',axpt(1,2,1,1,axpt(nCol,nRowSub,1,3:4,[],wideInterval),tightInterval));
        plot(xptTagBlue{1}, yptTagBlue{1}, ...
            'LineStyle', 'none', 'Marker', '.', 'MarkerSize', markerS, 'Color', 'k');
        set(hTag(1), 'XLim', winBlue, 'XTick', [], ...
            'YLim', [0 nBlue], 'YTick', [0 nBlue], 'YTickLabel', {[], nBlue});
        ylabel('Trials', 'FontSize', fontS);
        
        % Blue tag psth
        hTag(2) = axes('Position',axpt(1,2,1,2,axpt(nCol,nRowSub,1,3:4,[],wideInterval),tightInterval));
        hold on;
        yLimBarBlue = ceil(max(psthTagBlue(:))*1.05+0.0001);
        bar(2.5, 1000, 'BarWidth', 5, 'LineStyle', 'none', 'FaceColor', colorLightBlue);
        rectangle('Position', [0 yLimBarBlue*0.925 5 yLimBarBlue*0.075], 'LineStyle', 'none', 'FaceColor', colorBlue);
        hBarBlue = bar(psthtimeTagBlue, psthTagBlue, 'histc');
        set(hBarBlue, 'FaceColor','k', 'EdgeAlpha',0);
        set(hTag(2), 'XLim', winBlue, 'XTick', [winBlue(1) 0 winBlue(2)], ...
            'YLim', [0 yLimBarBlue], 'YTick', [0 yLimBarBlue], 'YTickLabel', {[], yLimBarBlue});
        xlabel('Time (ms)', 'FontSize', fontS);
        ylabel('Rate (Hz)', 'FontSize', fontS);
        
        % Blue tag hazard function
        hTag(3) = axes('Position',axpt(nCol,nRowSub,1,5,[],wideInterval));
        hold on;
        ylimH = min([ceil(max([H1_tagBlue;H2_tagBlue])*1100+0.0001)/1000 1]);
        winHBlue = [0 ceil(max(time_tagBlue))];
        stairs(time_tagBlue, H2_tagBlue, 'LineStyle',':', 'LineWidth', lineL, 'Color', 'k');
        stairs(time_tagBlue, H1_tagBlue, 'LineStyle','-', 'LineWidth', lineL, 'Color', colorBlue);
        text(winHBlue(2)*0.1,ylimH*1.1,['p = ',num2str(p_tagBlue,3),' (log-rank)'], 'FontSize',fontS, 'Interpreter','none');
        set(hTag(3), 'XLim', winHBlue, 'XTick', winHBlue, ...
            'YLim', [0 ylimH], 'YTick', [0 ylimH], 'YTickLabel', {[], ylimH});
        xlabel('Time (ms)', 'FontSize', fontS);
        ylabel('H(t)', 'FontSize', fontS);
    end

    % Red tag
    if ~isempty(redOnsetTime)
        nRed = length(redOnsetTime);
        winRed = [min(psthtimeTagRed) max(psthtimeTagRed)];
                
        % Red tag raster
        hTag(4) = axes('Position',axpt(1,2,1,1,axpt(nCol,nRowSub,1,6:7,[],wideInterval),tightInterval));
        plot(xptTagRed{1}, yptTagRed{1}, ...
            'LineStyle', 'none', 'Marker', '.', 'MarkerSize', markerS, 'Color', 'k');
        set(hTag(4), 'XLim', winRed, 'XTick', [], ...
            'YLim', [0 nRed], 'YTick', [0 nRed], 'YTickLabel', {[], nRed});
        ylabel('Trials', 'FontSize', fontS);
        
        % Red tag psth
        hTag(5) = axes('Position',axpt(1,2,1,2,axpt(nCol,nRowSub,1,6:7,[],wideInterval),tightInterval));
        hold on;
        yLimBarRed = ceil(max(psthTagRed(:))*1.05+0.0001);
        bar(250, 1000, 'BarWidth', 500, 'LineStyle', 'none', 'FaceColor', colorLightRed);
        rectangle('Position', [0 yLimBarRed*0.925 500 yLimBarRed*0.075], 'LineStyle', 'none', 'FaceColor', colorRed);
        hBarRed = bar(psthtimeTagRed, psthTagRed, 'histc');
        set(hBarRed, 'FaceColor','k', 'EdgeAlpha',0);
        set(hTag(5), 'XLim', winRed, 'XTick', [winRed(1) 0 winRed(2)], ...
            'YLim', [0 yLimBarRed], 'YTick', [0 yLimBarRed], 'YTickLabel', {[], yLimBarRed});
        xlabel('Time (ms)', 'FontSize', fontS);
        ylabel('Rate (Hz)', 'FontSize', fontS);
        
        % Red tag hazard function
        hTag(6) = axes('Position',axpt(nCol,nRowSub,1,8,[],wideInterval));
        hold on;
        ylimH = min([ceil(max([H1_tagRed;H2_tagRed])*1100+0.0001)/1000 1]);
        winHRed = [0 ceil(max(time_tagRed))];
        stairs(time_tagRed, H2_tagRed, 'LineStyle',':', 'LineWidth', lineL, 'Color', 'k');
        stairs(time_tagRed, H1_tagRed, 'LineStyle','-', 'LineWidth', lineL, 'Color', colorRed);
        text(winHRed(2)*0.1,ylimH*1.1,['p = ',num2str(p_tagRed,3),' (log-rank)'], 'FontSize',fontS, 'Interpreter','none');
        set(hTag(6), 'XLim', winHRed, 'XTick', winHRed, ...
            'YLim', [0 ylimH], 'YTick', [0 ylimH], 'YTickLabel', {[], ylimH});
        xlabel('Time (ms)', 'FontSize', fontS);
        ylabel('H(t)', 'FontSize', fontS);
    end
    set(hTag, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS);
    align_ylabel(hTag)

    %% Cue aligned
    % Raster
    hMain(1) = axes('Position',axpt(nCol,nRowMain,2:3,1:2,[],wideInterval));
    hold on;
    for iDur = 2:4
        plot([eventDuration(iDur) eventDuration(iDur)],[0.01 nTrial], ...
            'LineStyle',':', 'LineWidth', lineM, 'Color', colorGray);
    end
    for iType = find(trialResult~=0)
        plot(xpt{iType}, ypt{iType}, ...
            'Marker', '.', 'MarkerSize', markerS, 'LineStyle', 'none', 'Color', lineClr{iType});
    end
    set(hMain(1), 'YLim', [0 nTrial], 'YTick', [0 nTrial], 'YTickLabel', {[], nTrial});
    ylabel('Trial', 'FontSize', fontS);
    
    % Psth 1 (Cue x Rw | Mod=0)
    hMain(2) = axes('Position',axpt(nCol,nRowMain,2:3,3,[],wideInterval));
    hold on;
    ylimpsth = ceil(max(psthconv(:))*1.1+0.0001);
    for iDur = 2:4
        plot([eventDuration(iDur) eventDuration(iDur)],[0.01 nTrial], ...
            'LineStyle',':', 'LineWidth', lineM, 'Color', colorGray);
    end
    rectangle('Position', [eventDuration(2) ylimpsth*0.925 eventDuration(3)-eventDuration(2) ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorYellow);
    rectangle('Position', [eventDuration(4) ylimpsth*0.925 0.1 ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorBlue);
    for jType = find(trialResult~=0)
        if mod(jType,2)==1
            plot(psthtime, psthconv(jType,:), ...
                'LineStyle', lineStl{jType}, 'LineWidth', lineWth(jType), 'Color', lineClr{jType});
        end
    end
    set(hMain(2), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
    title('Cue x Rw | Mod = 0', 'FontSize', fontM);
    ylabel('Rate (Hz)', 'FontSize', fontS);
    
    % Psth 2 (Cue x Mod)
    hMain(3) = axes('Position',axpt(nCol,nRowMain,2:3,4,[],wideInterval));
    hold on;
    ylimpsth = ceil(max(psthconvCue(:))*1.1+0.0001);
    
    for iDur = 2:4
        plot([eventDuration(iDur) eventDuration(iDur)],[0.01 nTrial], ...
            'LineStyle',':', 'LineWidth', lineM, 'Color', colorGray);
    end
    rectangle('Position', [eventDuration(1) ylimpsth*0.925 5 ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorLightRed);
    rectangle('Position', [eventDuration(2) ylimpsth*0.85 eventDuration(3)-eventDuration(2) ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorYellow);
    rectangle('Position', [eventDuration(4) ylimpsth*0.85 0.1 ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorBlue);
    for jType = find(cueResult~=0)
        plot(psthtime, psthconvCue(jType,:), ...
            'LineStyle', lineStl{floor((jType-1)/2)*4+mod(jType-1,2)+1}, 'LineWidth', lineWth(floor((jType-1)/2)*4+mod(jType-1,2)+1), 'Color', lineClr{floor((jType-1)/2)*4+mod(jType-1,2)+1});
    end
    set(hMain(3), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
    title('Cue x Mod', 'FontSize', fontM);
    xlabel('Time from cue onset (s)', 'FontSize', fontS);
    ylabel('Rate (Hz)', 'FontSize', fontS);
    
    set(hMain, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS, ...
        'XLim', eventDuration([1 end]), 'XTick', eventDuration([1:4 end]));
    
    %% Reward aligned
    %Reward raster
    hRw(1) = axes('Position',axpt(nCol,nRowMain,4,1:2,[],wideInterval));
    hold on;
    plot([0 0], [0.01 nTrial], ...
        'LineStyle',':', 'LineWidth',lineM, 'Color', colorGray);
    for iType = find(trialResult~=0)
        plot(xptRw{iType}, yptRw{iType}, ...
            'Marker', '.', 'MarkerSize', markerS, 'LineStyle', 'none', 'Color', lineClr{iType});
    end
    set(hRw(1), 'YLim', [0 nTrialRw], 'YTick', [0 nTrialRw], 'YTickLabel', {[], nTrialRw});
    
    % PsthRw 1 (Cue x Rw | Mod=0)
    hRw(2) = axes('Position',axpt(nCol,nRowMain,4,3,[],wideInterval));
    hold on;
    ylimpsth = ceil(max(psthconvRw(:))*1.1+0.0001);
    plot([0 0], [0.01 nTrial], ...
        'LineStyle',':', 'LineWidth',lineM, 'Color', colorGray);
    rectangle('Position', [0 ylimpsth*0.925 0.1/3*4 ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorBlue);
    for jType = find(trialResult~=0)
        if mod(jType,2)==1
            plot(psthtimeRw, psthconvRw(jType,:), ...
                'LineStyle', lineStl{jType}, 'LineWidth', lineWth(jType), 'Color', lineClr{jType});
        end
    end
    set(hRw(2), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
    title('Cue x Rw | Mod = 0', 'FontSize', fontM);
    ylabel('Rate (Hz)', 'FontSize', fontS);
    
    % PsthRw 2 (Rw x Mod | Cue=A)
    hRw(3) = axes('Position',axpt(nCol,nRowMain,4,4,[],wideInterval));
    hold on;
    ylimpsth = ceil(max(psthconvRw(:))*1.1+0.0001);
    plot([0 0], [0.01 nTrial], ...
        'LineStyle',':', 'LineWidth',lineM, 'Color', colorGray);
    rectangle('Position', [0 ylimpsth*0.85 0.1/3*4 ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorBlue);
    rectangle('Position', [winRw(1)/1000+1 ylimpsth*0.925 3.5 ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorLightRed);
    for jType = 1:4
        if trialResult(jType)~=0
            plot(psthtimeRw, psthconvRw(jType,:), ...
                'LineStyle', lineStl{jType}, 'LineWidth', lineWth(jType), 'Color', lineClr{jType});
        end
    end
    set(hRw(3), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
    title('Rw x Mod | Cue=A', 'FontSize', fontM);
    ylabel('Rate (Hz)', 'FontSize', fontS);
    
    % PsthRw 3 (Rw x Mod | Cue=B)
    hRw(4) = axes('Position',axpt(nCol,nRowMain,4,5,[],wideInterval));
    hold on;
    ylimpsth = ceil(max(psthconvRw(:))*1.1+0.0001);
    plot([0 0], [0.01 nTrial], ...
        'LineStyle',':', 'LineWidth',lineM, 'Color', colorGray);
    rectangle('Position', [0 ylimpsth*0.85 0.1/3*4 ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorBlue);
        rectangle('Position', [winRw(1)/1000+1 ylimpsth*0.925 3.5 ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorLightRed);
    for jType = 5:8
        if trialResult(jType)~=0
            plot(psthtimeRw, psthconvRw(jType,:), ...
                'LineStyle', lineStl{jType}, 'LineWidth', lineWth(jType), 'Color', lineClr{jType});
        end
    end
    set(hRw(4), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
    title('Rw x Mod | Cue = B', 'FontSize', fontM);
    xlabel('Time from reward onset (s)', 'FontSize', fontS);
    ylabel('Rate (Hz)', 'FontSize', fontS);
    
    set(hRw, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS, ...
        'XLim', [winRw(1)/1000+1 winRw(2)/1000-1], 'XTick', [winRw(1)/1000+1 0 winRw(2)/1000-1]);

    print(gcf,'-dtiff','-r300',[cellFigName{1},'.tif']);
    close;
end
cd(rtdir);