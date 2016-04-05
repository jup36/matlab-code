function psthplotCC(cellFolder)
%psthplotCC draws summary plot for each cell

% Find files
if nargin == 0; cellFolder = {}; end;
mList = mLoad(cellFolder);
if isempty(mList); return; end;
nFile = length(mList);
rtdir = pwd;

% Plot properties
lineClrMod = {[0.8 0 0], ... % Cue A, Rw, no mod
    [1 0.6 0.6], ... % Cue A, Rw, mod
    [0.8 0 0], ... % Cue A, no Rw, no mod
    [1 0.6 0.6], ... % Cue A, no Rw, mod
    [153 204 0]./255, ... % Cue B, Rw, no mod
    [204 255 102]./255, ... % Cue B, Rw, mod
    [153 204 0]./255, ... % Cue B, no Rw, no mod
    [204 255 102]./255, ... % Cue B, no Rw, mod
    [1 0.6 0], ... % Cue C
    [1 0.8 0.4], ...
    [1 0.6 0], ...
    [1 0.8 0.4], ...
    [0 0 0.8], ... % Cue D
    [0.6 0.6 1], ...
    [0 0 0.8], ...
    [0.6 0.6 1]};
lineClrNoMod = {[0.8 0 0], ... % Cue A, Rw, no mod
    [1 0.6 0.6], ... % Cue A, Rw, mod
    [1 0.6 0.6], ... % Cue A, no Rw, no mod
    [1 0.6 0.6], ... % Cue A, no Rw, mod
    [153 204 0]./255, ... % Cue B, Rw, no mod
    [204 255 102]./255, ... % Cue B, Rw, mod
    [204 255 102]./255, ... % Cue B, no Rw, no mod
    [204 255 102]./255, ... % Cue B, no Rw, mod
    [1 0.6 0], ... % Cue C
    [1 0.8 0.4], ...
    [1 0.8 0.4], ...
    [1 0.8 0.4], ...
    [0 0 0.8], ... % Cue D
    [0.6 0.6 1], ...
    [0.6 0.6 1], ...
    [0.6 0.6 1]};
lineStlMod = {'-', '-', ':', ':', ...
    '-', '-', ':', ':', ...
    '-', '-', ':', ':', ...
    '-', '-', ':', ':'};
lineStlNoMod = {'-', '-', '-', '-', ...
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
colorLightYellow = [230 251 133] ./ 255;
tightInterval = [0.02 0.02];
wideInterval = [0.07 0.07];
nCol = 4;
nRowSub = 8; % for the left column
nRowMain = 7; % for the main figure
markerS = 2.2;
markerM = 4.4;
markerL = 6.6;
cueName = {'A','B','C','D'};

pthreshold = 0.05;

for iFile = 1:nFile
    [cellDir,cellName,~] = fileparts(mList{iFile});
    cellDirSplit = regexp(cellDir,'\','split');
    cellFigName = strcat(cellDirSplit(end-1),'_',cellDirSplit(end),'_',cellName);
    
    cd(cellDir);
    clear regRw_cr_mod regRw_crm
    load(mList{iFile});
    load('Events.mat');
        
    if ~any(trialResult(2:2:end))
        lineClr = lineClrNoMod;
        lineStl = lineStlNoMod;
    else
        lineClr = lineClrMod;
        lineStl = lineStlMod;
    end
    
    % Cell information
    fHandle = figure('PaperUnits','centimeters','PaperPosition',[0 0 18.3 13.725]);
    hText = axes('Position',axpt(1,2,1,1,axpt(nCol,nRowSub,1,1:2,[],wideInterval),tightInterval));
    hold on;
    text(0,1.2,mList{iFile}, 'FontSize',fontM, 'Interpreter','none');
    pText = '';
    for iCue = 1:4
        if sum(trialResult(4*(iCue-1)+(1:4)))>0
            if iCue>1
                pText = [pText,', '];
            end
            pText = [pText,'p_',cueName{iCue},' = ',num2str(sum(trialResult(4*(iCue-1)+[1 2]))/sum(trialResult(4*(iCue-1)+(1:4))),2)];
        end
    end
    text(0,0.9,pText, 'FontSize', fontS);
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
    if ~isempty(blueOnsetTime) && ~isempty(xptTagBlue{1})
        nBlue = length(blueOnsetTime);
        winBlue = [min(psthtimeTagBlue) max(psthtimeTagBlue)];
                
        % Blue tag raster
        hTagBlue(1) = axes('Position',axpt(1,2,1,1,axpt(nCol,nRowSub,1,3:4,[],wideInterval),tightInterval));
        plot(xptTagBlue{1}, yptTagBlue{1}, ...
            'LineStyle', 'none', 'Marker', '.', 'MarkerSize', markerS, 'Color', 'k');
        set(hTagBlue(1), 'XLim', winBlue, 'XTick', [], ...
            'YLim', [0 nBlue], 'YTick', [0 nBlue], 'YTickLabel', {[], nBlue});
        ylabel('Trials', 'FontSize', fontS);
        
        % Blue tag psth
        hTagBlue(2) = axes('Position',axpt(1,2,1,2,axpt(nCol,nRowSub,1,3:4,[],wideInterval),tightInterval));
        hold on;
        yLimBarBlue = ceil(max(psthTagBlue(:))*1.05+0.0001);
        bar(2.5, 1000, 'BarWidth', 5, 'LineStyle', 'none', 'FaceColor', colorLightBlue);
        rectangle('Position', [0 yLimBarBlue*0.925 5 yLimBarBlue*0.075], 'LineStyle', 'none', 'FaceColor', colorBlue);
        hBarBlue = bar(psthtimeTagBlue, psthTagBlue, 'histc');
        set(hBarBlue, 'FaceColor','k', 'EdgeAlpha',0);
        set(hTagBlue(2), 'XLim', winBlue, 'XTick', [winBlue(1) 0 winBlue(2)], ...
            'YLim', [0 yLimBarBlue], 'YTick', [0 yLimBarBlue], 'YTickLabel', {[], yLimBarBlue});
        xlabel('Time (ms)', 'FontSize', fontS);
        ylabel('Rate (Hz)', 'FontSize', fontS);
        
        % Blue tag hazard function
        hTagBlue(3) = axes('Position',axpt(nCol,nRowSub,1,5,[],wideInterval));
        hold on;
        ylimH = min([ceil(max([H1_tagBlue;H2_tagBlue])*1100+0.0001)/1000 1]);
        winHBlue = [0 ceil(max(time_tagBlue))];
        stairs(time_tagBlue, H2_tagBlue, 'LineStyle',':', 'LineWidth', lineL, 'Color', 'k');
        stairs(time_tagBlue, H1_tagBlue, 'LineStyle','-', 'LineWidth', lineL, 'Color', colorBlue);
        text(winHBlue(2)*0.1,ylimH*1.1,['p = ',num2str(p_tagBlue,3),' (log-rank)'], 'FontSize',fontS, 'Interpreter','none');
        set(hTagBlue(3), 'XLim', winHBlue, 'XTick', winHBlue, ...
            'YLim', [0 ylimH], 'YTick', [0 ylimH], 'YTickLabel', {[], ylimH});
        xlabel('Time (ms)', 'FontSize', fontS);
        ylabel('H(t)', 'FontSize', fontS);
        
        set(hTagBlue, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS);
        align_ylabel(hTagBlue)
    end

    % Red tag
    if ~isempty(redOnsetTime) && ~isempty(xptTagRed{1})
        nRed = length(redOnsetTime);
        winRed = [min(psthtimeTagRed) max(psthtimeTagRed)];
                
        % Red tag raster
        hTagRed(1) = axes('Position',axpt(1,2,1,1,axpt(nCol,nRowSub,1,6:7,[],wideInterval),tightInterval));
        plot(xptTagRed{1}, yptTagRed{1}, ...
            'LineStyle', 'none', 'Marker', '.', 'MarkerSize', markerS, 'Color', 'k');
        set(hTagRed(1), 'XLim', winRed, 'XTick', [], ...
            'YLim', [0 nRed], 'YTick', [0 nRed], 'YTickLabel', {[], nRed});
        ylabel('Trials', 'FontSize', fontS);
        
        % Red tag psth
        hTagRed(2) = axes('Position',axpt(1,2,1,2,axpt(nCol,nRowSub,1,6:7,[],wideInterval),tightInterval));
        hold on;
        yLimBarRed = ceil(max(psthTagRed(:))*1.05+0.0001);
        bar(250, 1000, 'BarWidth', 500, 'LineStyle', 'none', 'FaceColor', colorLightRed);
        rectangle('Position', [0 yLimBarRed*0.925 500 yLimBarRed*0.075], 'LineStyle', 'none', 'FaceColor', colorRed);
        hBarRed = bar(psthtimeTagRed, psthTagRed, 'histc');
        set(hBarRed, 'FaceColor','k', 'EdgeAlpha',0);
        set(hTagRed(2), 'XLim', winRed, 'XTick', [winRed(1) 0 winRed(2)], ...
            'YLim', [0 yLimBarRed], 'YTick', [0 yLimBarRed], 'YTickLabel', {[], yLimBarRed});
        xlabel('Time (ms)', 'FontSize', fontS);
        ylabel('Rate (Hz)', 'FontSize', fontS);
        
        % Red tag hazard function
        hTagRed(3) = axes('Position',axpt(nCol,nRowSub,1,8,[],wideInterval));
        hold on;
        ylimH = min([ceil(max([H1_tagRed;H2_tagRed])*1100+0.0001)/1000 1]);
        winHRed = [0 ceil(max(time_tagRed))];
        stairs(time_tagRed, H2_tagRed, 'LineStyle',':', 'LineWidth', lineL, 'Color', 'k');
        stairs(time_tagRed, H1_tagRed, 'LineStyle','-', 'LineWidth', lineL, 'Color', colorRed);
        text(winHRed(2)*0.1,ylimH*1.1,['p = ',num2str(p_tagRed,3),' (log-rank)'], 'FontSize',fontS, 'Interpreter','none');
        set(hTagRed(3), 'XLim', winHRed, 'XTick', winHRed, ...
            'YLim', [0 ylimH], 'YTick', [0 ylimH], 'YTickLabel', {[], ylimH});
        xlabel('Time (ms)', 'FontSize', fontS);
        ylabel('H(t)', 'FontSize', fontS);
        set(hTagRed, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS);
        align_ylabel(hTagRed)
    end


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
    hMain(2) = axes('Position',axpt(1,4,1,1,axpt(nCol,nRowMain,2:3,[3 7],[],wideInterval),wideInterval));
    hold on;
    ylimpsth = ceil(max(psthconv(:))*1.1+0.0001);
    for iDur = 2:4
        plot([eventDuration(iDur) eventDuration(iDur)],[0.01 nTrial], ...
            'LineStyle',':', 'LineWidth', lineM, 'Color', colorGray);
    end
%     rectangle('Position', [eventDuration(2) ylimpsth*0.925 eventDuration(3)-eventDuration(2) ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorYellow);
%     rectangle('Position', [eventDuration(4) ylimpsth*0.925 0.1 ylimpsth*0.075], 'LineStyle','none', 'FaceColor', colorBlue);
    p_cr = double(reg_cr_nomod.p < pthreshold); p_cr(p_cr==0) = NaN;
    plot(reg_cr_nomod.time/1000, p_cr(1,:)*ylimpsth*0.95, ...
        'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', markerS, ... 
        'MarkerFaceColor', colorYellow, 'Color', colorYellow);
    plot(reg_cr_nomod.time/1000, p_cr(2,:)*ylimpsth*0.90, ...
        'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', markerS, ... 
        'MarkerFaceColor', colorBlue, 'Color', colorBlue);
    plot(reg_cr_nomod.time/1000, p_cr(3,:)*ylimpsth*0.85, ...
        'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', markerS, ... 
        'MarkerFaceColor', colorBlue, 'Color', colorBlue);
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
    hMain(3) = axes('Position',axpt(1,4,1,2,axpt(nCol,nRowMain,2:3,[3 7],[],wideInterval),wideInterval));
    hold on;
    ylimpsth = ceil(max(psthconvCue(:))*1.1+0.0001);
    for iDur = 2:4
        plot([eventDuration(iDur) eventDuration(iDur)],[0.01 nTrial], ...
            'LineStyle',':', 'LineWidth', lineM, 'Color', colorGray);
    end
    if exist('reg_cr_mod')
        p_cr_mod = double(reg_cr_mod.p < pthreshold); p_cr_mod(p_cr_mod==0) = NaN;
        p_crm = double(reg_crm.p < pthreshold); p_crm(p_crm==0) = NaN;
        plot(reg_cr_nomod.time/1000, p_cr(1,:)*ylimpsth*0.95, ...
            'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', markerS, ... 
            'MarkerFaceColor', colorYellow, 'Color', colorYellow);
        plot(reg_cr_mod.time/1000, p_cr_mod(1,:)*ylimpsth*0.90, ...
            'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', markerS, ... 
            'MarkerFaceColor', colorLightYellow, 'Color', colorLightYellow);
        plot(reg_crm.time/1000, p_crm(4,:)*ylimpsth*0.05, ...
            'LineStyle', 'none', 'Marker', '^', 'MarkerSize', markerS, ... 
            'MarkerFaceColor', colorRed, 'Color', colorRed);
        plot(reg_crm.time/1000, p_crm(5,:)*ylimpsth*0.10, ...
            'LineStyle', 'none', 'Marker', '^', 'MarkerSize', markerS, ... 
            'MarkerFaceColor', colorLightRed, 'Color', colorLightRed);
    end
    for jType = find(cueResult~=0)
        plot(psthtime, psthconvCue(jType,:), ...
            'LineStyle', lineStl{floor((jType-1)/2)*4+mod(jType-1,2)+1}, 'LineWidth', lineWth(floor((jType-1)/2)*4+mod(jType-1,2)+1), 'Color', lineClr{floor((jType-1)/2)*4+mod(jType-1,2)+1});
    end
    set(hMain(3), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
    title('Cue x Mod', 'FontSize', fontM);
    ylabel('Rate (Hz)', 'FontSize', fontS);
    
    % Psth 3 (Regression plot)
    hMain(4) = axes('Position',axpt(1,4,1,3,axpt(nCol,nRowMain,2:3,[3 7],[],wideInterval),wideInterval));
    hold on;
    ylimRegress = [min(reg_cr_nomod.sse(1,:)) max(reg_cr_nomod.sse(1,:))]*1.1;
    if ~any(ylimRegress); ylimRegress = [-1 1]; end;
    hFill(1) = fill(reg_cr_nomod.timesse/1000,reg_cr_nomod.sse(1,:),colorYellow);
    plot(win/1000, [0 0], 'LineStyle', ':', 'LineWidth', lineS, 'Color', colorGray);
    plot(reg_cr_nomod.time/1000,reg_cr_nomod.src(1,:), ...
        'LineWidth', lineL, 'Color', colorYellow);
    if exist('reg_cr_mod')
        ylimRegress = [min([reg_cr_nomod.sse(1,:) reg_cr_mod.sse(1,:)]) max([reg_cr_nomod.sse(1,:) reg_cr_mod.sse(1,:)])]*1.1;
        hFill(2) = fill(reg_cr_mod.timesse/1000,reg_cr_mod.sse(1,:),colorLightYellow);
        plot(reg_cr_mod.time/1000,reg_cr_mod.src(1,:), ...
            'LineWidth', lineL, 'Color', colorLightYellow);
        
%        hFill(3) = fill(reg_crm.timesse/1000,reg_crm.sse(5,:),colorLightRed);
%        plot(reg_crm.time/1000,reg_crm.src(5,:), ...
%             'LineWidth', lineL, 'Color', colorLightRed);
    end
    set(hFill, 'LineStyle', 'none', 'FaceAlpha', 0.5);
    set(hMain(4), 'YLim', ylimRegress);
    ylabel('SRC', 'FontSize', fontS);
    
    % PsthRw 1 (Cue | Rw=1, Mod=0)
    hRw(1) = axes('Position',axpt(2,4,1,4,axpt(nCol,nRowMain,2:3,[3 7],[],wideInterval),wideInterval));
    hold on;
    ylimpsth = ceil(max(psthconvRw(:))*1.1+0.0001);
    plot([0 0], [0.01 nTrial], ...
        'LineStyle',':', 'LineWidth',lineM, 'Color', colorGray);
    pRw_cr = double(regRw_cr_nomod.p < pthreshold); pRw_cr(pRw_cr==0) = NaN;
    plot(regRw_cr_nomod.time/1000, pRw_cr(1,:)*ylimpsth*0.95, ...
        'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', markerS, ... 
        'MarkerFaceColor', colorYellow, 'Color', colorYellow);
    plot(regRw_cr_nomod.time/1000, pRw_cr(2,:)*ylimpsth*0.90, ...
        'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', markerS, ... 
        'MarkerFaceColor', colorBlue, 'Color', colorBlue);
    plot(regRw_cr_nomod.time/1000, pRw_cr(3,:)*ylimpsth*0.85, ...
        'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', markerS, ... 
        'MarkerFaceColor', colorBlue, 'Color', colorBlue);
    for jType = find(trialResult~=0)
        if mod(jType,4)==1
            plot(psthtimeRw, psthconvRw(jType,:), ...
                'LineStyle', lineStl{jType}, 'LineWidth', lineWth(jType), 'Color', lineClr{jType});
        end
    end
    set(hRw(1), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
    title('Cue | Rw = 1, Mod = 0', 'FontSize', fontM);
    ylabel('Rate (Hz)', 'FontSize', fontS);

    % PsthRw 2 (Cue | Rw=0, Mod=0)
    hRw(2) = axes('Position',axpt(2,4,2,4,axpt(nCol,nRowMain,2:3,[3 7],[],wideInterval),wideInterval));
    hold on;
    ylimpsth = ceil(max(psthconvRw(:))*1.1+0.0001);
    plot([0 0], [0.01 nTrial], ...
        'LineStyle',':', 'LineWidth',lineM, 'Color', colorGray);
    pRw_cr = double(regRw_cr_nomod.p < pthreshold); pRw_cr(pRw_cr==0) = NaN;
    plot(regRw_cr_nomod.time/1000, pRw_cr(1,:)*ylimpsth*0.95, ...
        'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', markerS, ... 
        'MarkerFaceColor', colorYellow, 'Color', colorYellow);
    plot(regRw_cr_nomod.time/1000, pRw_cr(2,:)*ylimpsth*0.90, ...
        'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', markerS, ... 
        'MarkerFaceColor', colorBlue, 'Color', colorBlue);
    plot(regRw_cr_nomod.time/1000, pRw_cr(3,:)*ylimpsth*0.85, ...
        'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', markerS, ... 
        'MarkerFaceColor', colorBlue, 'Color', colorBlue);
    for jType = find(trialResult~=0)
        if mod(jType,4)==3
            plot(psthtimeRw, psthconvRw(jType,:), ...
                'LineStyle', '-', 'LineWidth', lineWth(jType), 'Color', lineClr{jType});
        end
    end
    set(hRw(2), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
    title('Cue | Rw = 0, Mod = 0', 'FontSize', fontM);
    
    set(hMain, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS, ...
        'XLim', eventDuration([1 end]), 'XTick', eventDuration([1:4 end]));
    align_ylabel([hMain hRw(1:2)]);
  
    %% Reward aligned
    %Reward raster
    hRw(3) = axes('Position',axpt(nCol,nRowMain,4,1:2,[],wideInterval));
    hold on;
    plot([0 0], [0.01 nTrial], ...
        'LineStyle',':', 'LineWidth',lineM, 'Color', colorGray);
    for iType = find(trialResult~=0)
        plot(xptRw{iType}, yptRw{iType}, ...
            'Marker', '.', 'MarkerSize', markerS, 'LineStyle', 'none', 'Color', lineClr{iType});
    end
    set(hRw(3), 'YLim', [0 nTrialRw], 'YTick', [0 nTrialRw], 'YTickLabel', {[], nTrialRw});
    
    % PsthRw 2-5 (Rw x Mod | Cue)
    cues = unique(cue);
    nCue = length(cues);
    if nCue < 3
        mCue = 3;
    else
        mCue = nCue;
    end
    for iCue = 1:nCue
        hRw(iCue+3) = axes('Position',axpt(1,mCue,1,iCue,axpt(nCol,nRowMain,4,[3 7],[],wideInterval),wideInterval));
        hold on;
        ylimpsth = ceil(max(psthconvRw(:))*1.1+0.0001);
        plot([0 0], [0.01 nTrial], ...
            'LineStyle',':', 'LineWidth',lineM, 'Color', colorGray);
        if exist('reg_cr_mod')
            pRw_cr_mod = double(regRw_cr_mod.p < pthreshold); pRw_cr_mod(pRw_cr_mod==0) = NaN;
            pRw_crm = double(regRw_crm.p < pthreshold); pRw_crm(pRw_crm==0) = NaN;
            if iCue == 1 
                plot(regRw_cr_nomod.time/1000, pRw_cr(2,:)*ylimpsth*0.95, ...
                    'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', markerS, ... 
                    'MarkerFaceColor', colorBlue, 'Color', colorBlue);
                plot(regRw_cr_mod.time/1000, pRw_cr_mod(2,:)*ylimpsth*0.90, ...
                    'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', markerS, ... 
                    'MarkerFaceColor', colorLightBlue, 'Color', colorLightBlue);
                plot(regRw_crm.time/1000, pRw_crm(6,:)*ylimpsth*0.10, ...
                'LineStyle', 'none', 'Marker', '^', 'MarkerSize', markerS, ... 
                'MarkerFaceColor', colorLightRed, 'Color', colorLightRed);
            elseif iCue == nCue
                plot(regRw_cr_nomod.time/1000, pRw_cr(3,:)*ylimpsth*0.95, ...
                    'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', markerS, ... 
                    'MarkerFaceColor', colorBlue, 'Color', colorBlue);
                plot(regRw_cr_mod.time/1000, pRw_cr_mod(3,:)*ylimpsth*0.90, ...
                    'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', markerS, ... 
                    'MarkerFaceColor', colorLightBlue, 'Color', colorLightBlue);
                plot(regRw_crm.time/1000, pRw_crm(7,:)*ylimpsth*0.10, ...
                'LineStyle', 'none', 'Marker', '^', 'MarkerSize', markerS, ... 
                'MarkerFaceColor', colorLightRed, 'Color', colorLightRed);
            end   
            plot(regRw_crm.time/1000, pRw_crm(4,:)*ylimpsth*0.05, ...
                'LineStyle', 'none', 'Marker', '^', 'MarkerSize', markerS, ... 
                'MarkerFaceColor', colorRed, 'Color', colorRed);
        end
        for jType = 4*(cues(iCue)-1)+(1:4)
            if trialResult(jType)~=0
                plot(psthtimeRw, psthconvRw(jType,:), ...
                    'LineStyle', lineStl{jType}, 'LineWidth', lineWth(jType), 'Color', lineClr{jType});
            end
        end
        set(hRw(iCue+3), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
        title(['Rw x Mod | Cue=',cueName{iCue}], 'FontSize', fontM);
        ylabel('Rate (Hz)', 'FontSize', fontS);
        if iCue==nCue
            xlabel('Time from reward onset (s)', 'FontSize', fontS);
        end
    end
    set(hRw, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS, ...
        'XLim', [winRw(1)/1000+1 winRw(2)/1000-1], 'XTick', [winRw(1)/1000+1 0 winRw(2)/1000-1]);
    align_ylabel(hRw(3:end))

    print(gcf,'-dtiff','-r300',[cellFigName{1},'.tif']);
    close;
end
cd(rtdir);