function psthplotCC(cellFolder)
%psthplotCC draws summary plot for each cell

% Find files
if nargin == 0; cellFolder = {}; end;
mList = mLoad(cellFolder);
if isempty(mList); return; end;
nFile = length(mList);
rtdir = pwd;

% Plot properties
lineClrMod = {[0.8 0 0], [1 0.4 0.4], [1 0.6 0.6]; ... % Cue A, Rw, (no mod / mod A / mod B)
    [0.8 0 0], [1 0.4 0.4], [1 0.6 0.6]; ... % Cue A, no Rw, (no mod / mod A / mod B)
    [153 204 0]./255, [204 255 102]./255, [204 255 102]./255;... % Cue B, Rw, (no mod / mod A / mod B)
    [153 204 0]./255, [204 255 102]./255, [204 255 102]./255;... % Cue B, no Rw, (no mod / mod A / mod B)
    [1 0.6 0], [1 0.8 0.4], [1 0.8 0.4]; ... % Cue C
    [1 0.6 0], [1 0.8 0.4], [1 0.8 0.4]; ...
    [0 0 0.8], [0.4 0.4 1], [0.6 0.6 1]; ... % Cue D
    [0 0 0.8], [0.4 0.4 1], [0.6 0.6 1]};
lineClrNoMod = {[0.8 0 0]; ... % Cue A, Rw, no mod
    [1 0.6 0.6]; ... % Cue A, no Rw, no mod
    [153 204 0]./255; ... % Cue B, Rw, no mod
    [204 255 102]./255; ... % Cue B, no Rw, no mod
    [1 0.6 0]; ... % Cue C
    [1 0.8 0.4]; ...
    [0 0 0.8]; ... % Cue D
    [0.6 0.6 1]};
lineStlMod = {'-', '-', '-'; ':', ':', ':'; ...
    '-', '-', '-'; ':', ':', ':'; ...
    '-', '-', '-'; ':', ':', ':'; ...
    '-', '-', '-'; ':', ':', ':'};
lineStlNoMod = repmat({'-'}, 8, 3)';
lineWth = repmat([1 0.75 0.75], 8, 1);

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
colorDarkGray = [127 127 127] ./ 255;
colorYellow = [255 243 3] ./ 255;
colorLightYellow = [230 251 133] ./ 255;
tightInterval = [0.02 0.02];
wideInterval = [0.07 0.07];
nCol = 4;
nRowSub = 8; % for the left column
nRowMain = 7; % for the main figure
markerS = 2;
markerM = 4;
markerL = 6;
cueName = {'A','B','C','D'};
transparency = 0.2;

pMarker = {'.', '+', '*'};
pthreshold = [0.05; 0.01; 0.001; 0];

for iFile = 1:nFile
    [cellDir,cellName,~] = fileparts(mList{iFile});
    cellDirSplit = regexp(cellDir,'\','split');
    cellFigName = strcat(cellDirSplit(end-1),'_',cellDirSplit(end),'_',cellName);
    
    cd(cellDir);
    load(mList{iFile});
    load('Events.mat');
    
    if nMod==1
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
        %         xlabel('Time (ms)', 'FontSize', fontS);
        ylabel('Rate (Hz)', 'FontSize', fontS);
        
        % Blue tag hazard function
        hTagBlue(3) = axes('Position',axpt(nCol,nRowSub,1,5,[],wideInterval));
        hold on;
        yLimH = min([ceil(max([H1_tagBlue;H2_tagBlue])*1100+0.0001)/1000 1]);
        winHBlue = [0 ceil(max(time_tagBlue))];
        stairs(time_tagBlue, H2_tagBlue, 'LineStyle',':', 'LineWidth', lineL, 'Color', 'k');
        stairs(time_tagBlue, H1_tagBlue, 'LineStyle','-', 'LineWidth', lineL, 'Color', colorBlue);
        text(winHBlue(2)*0.1,yLimH*1.1,['p = ',num2str(p_tagBlue,3),' (log-rank)'], 'FontSize',fontS, 'Interpreter','none');
        text(winHBlue(2)*0.1,yLimH*1.0,['p = ',num2str(p_saltBlue,2),' (SALT)'], 'FontSize',fontS, 'Interpreter','none');
        set(hTagBlue(3), 'XLim', winHBlue, 'XTick', winHBlue, ...
            'YLim', [0 yLimH], 'YTick', [0 yLimH], 'YTickLabel', {[], yLimH});
        %         xlabel('Time (ms)', 'FontSize', fontS);
        ylabel('H(t)', 'FontSize', fontS);
        
        % Blue tag cumulative curve
        hTagBlue(4) = axes('Position',axpt(nCol,nRowSub,1,6,[],wideInterval));
        hold on;
        yLimCum = min([ceil(max([cumSpikeBlue.base(:, 2); cumSpikeBlue.test(:, 2)])*1.05+0.0001), 0.1]);
        winCumBlue = [0 ceil(max([cumSpikeBlue.base(:, 1); cumSpikeBlue.test(:, 2)]))];
        stairs(cumSpikeBlue.base(:, 1), cumSpikeBlue.base(:, 2), 'LineStyle', ':', 'LineWidth', lineL, 'Color', 'k');
        stairs(cumSpikeBlue.test(:, 1), cumSpikeBlue.test(:, 2), 'LineStyle', '-', 'LineWidth', lineL, 'Color', colorBlue);
        set(hTagRed(4), 'XLim', winCumBlue, 'XTick', winCumBlue, ...
            'YLim', [0 yLimCum], 'YTick', [0 yLimCum], 'YTickLabel', {[], yLimCum});
        xlabe('Time (ms)', 'FontSize', fontS);
        ylabel('Cumulative spikes', 'FontSize', fontS);
        
        set(hTagBlue, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS);
        align_ylabel(hTagBlue)
    end
    
    % Red tag (here, I assumed blue and reg tagging are not done together)
    if ~isempty(redOnsetTime) && ~isempty(xptTagRed{1})
        nRed = length(redOnsetTime);
        winRed = [min(psthtimeTagRed) max(psthtimeTagRed)];
        
        % Red tag raster
        hTagRed(1) = axes('Position',axpt(1,2,1,1,axpt(nCol,nRowSub,1,3:4,[],wideInterval),tightInterval));
        plot(xptTagRed{1}, yptTagRed{1}, ...
            'LineStyle', 'none', 'Marker', '.', 'MarkerSize', markerS, 'Color', 'k');
        set(hTagRed(1), 'XLim', winRed, 'XTick', [], ...
            'YLim', [0 nRed], 'YTick', [0 nRed], 'YTickLabel', {[], nRed});
        ylabel('Trials', 'FontSize', fontS);
        
        % Red tag psth
        hTagRed(2) = axes('Position',axpt(1,2,1,2,axpt(nCol,nRowSub,1,3:4,[],wideInterval),tightInterval));
        hold on;
        yLimBarRed = ceil(max(psthTagRed(:))*1.05+0.0001);
        bar(250, 1000, 'BarWidth', 500, 'LineStyle', 'none', 'FaceColor', colorLightRed);
        rectangle('Position', [0 yLimBarRed*0.925 500 yLimBarRed*0.075], 'LineStyle', 'none', 'FaceColor', colorRed);
        hBarRed = bar(psthtimeTagRed, psthTagRed, 'histc');
        set(hBarRed, 'FaceColor','k', 'EdgeAlpha',0);
        set(hTagRed(2), 'XLim', winRed, 'XTick', [winRed(1) 0 winRed(2)], ...
            'YLim', [0 yLimBarRed], 'YTick', [0 yLimBarRed], 'YTickLabel', {[], yLimBarRed});
        ylabel('Rate (Hz)', 'FontSize', fontS);
        
        % Red tag cumulative curve
        hTagRed(3) = axes('Position',axpt(nCol,nRowSub,1,5,[],wideInterval));
        hold on;
        yLimCum = max([ceil(max([cumSpikeRed.base(:, 2); cumSpikeRed.test(:, 2)])*1.05+0.0001), 0.1]);
        winCumRed = [0 ceil(max([cumSpikeRed.base(:, 1); cumSpikeRed.test(:, 2)]))];
        stairs(cumSpikeRed.base(:, 1), cumSpikeRed.base(:, 2), 'LineStyle', ':', 'LineWidth', lineL, 'Color', 'k');
        stairs(cumSpikeRed.test(:, 1), cumSpikeRed.test(:, 2), 'LineStyle', '-', 'LineWidth', lineL, 'Color', colorRed);
        set(hTagRed(3), 'XLim', winCumRed, 'XTick', winCumRed, ...
            'YLim', [0 yLimCum], 'YTick', [0 yLimCum], 'YTickLabel', {[], yLimCum});
        title('Cumulative spike per trial', 'FontSize', fontS);
        ylabel('Spike number', 'FontSize', fontS);
        
        % Red tag hazard function
        hTagRed(4) = axes('Position',axpt(nCol,nRowSub,1,6,[],wideInterval));
        hold on;
        yLimH = min([ceil(max([H1_tagRed;H2_tagRed])*1100+0.0001)/1000 1]);
        winHRed = [0 ceil(max(time_tagRed))];
        stairs(time_tagRed, H2_tagRed, 'LineStyle',':', 'LineWidth', lineL, 'Color', 'k');
        stairs(time_tagRed, H1_tagRed, 'LineStyle','-', 'LineWidth', lineL, 'Color', colorRed);
        text(winHRed(2)*0.1,yLimH*0.95,['p = ',num2str(p_tagRed,2),' (log-rank)'], 'FontSize',fontS, 'Interpreter','none');
        set(hTagRed(4), 'XLim', winHRed, 'XTick', winHRed, ...
            'YLim', [0 yLimH], 'YTick', [0 yLimH], 'YTickLabel', {[], yLimH});
        title('All tag period', 'FontSize', fontS);
        ylabel('H(t)', 'FontSize', fontS);
        
        % Red tag hazard function (onset period)
        hTagRed(5) = axes('Position',axpt(nCol,nRowSub,1,7,[],wideInterval));
        hold on;
        yLimH = min([ceil(max([H1_tagRedOnset;H2_tagRedOnset])*1100+0.0001)/1000 1]);
        winHRed = [0 ceil(max(time_tagRedOnset))];
        stairs(time_tagRedOnset, H2_tagRedOnset, 'LineStyle',':', 'LineWidth', lineL, 'Color', 'k');
        stairs(time_tagRedOnset, H1_tagRedOnset, 'LineStyle','-', 'LineWidth', lineL, 'Color', colorRed);
        text(winHRed(2)*0.1,yLimH*0.95,['p = ',num2str(p_tagRedOnset,3),' (log-rank)'], 'FontSize',fontS, 'Interpreter','none');
        set(hTagRed(5), 'XLim', winHRed, 'XTick', winHRed, ...
            'YLim', [0 yLimH], 'YTick', [0 yLimH], 'YTickLabel', {[], yLimH});
        title('Tag onset', 'FontSize', fontS);
        ylabel('H(t)', 'FontSize', fontS);
        
        % Red tag hazard function (offset period)
        hTagRed(6) = axes('Position',axpt(nCol,nRowSub,1,8,[],wideInterval));
        hold on;
        yLimH = min([ceil(max([H1_tagRedOffset;H2_tagRedOffset])*1100+0.0001)/1000 1]);
        winHRed = [0 ceil(max(time_tagRedOffset))];
        stairs(time_tagRedOffset, H2_tagRedOffset, 'LineStyle',':', 'LineWidth', lineL, 'Color', 'k');
        stairs(time_tagRedOffset, H1_tagRedOffset, 'LineStyle','-', 'LineWidth', lineL, 'Color', colorRed);
        text(winHRed(2)*0.1,yLimH*0.95,['p = ',num2str(p_tagRedOffset,3),' (log-rank)'], 'FontSize',fontS, 'Interpreter','none');
        set(hTagRed(6), 'XLim', winHRed, 'XTick', winHRed, ...
            'YLim', [0 yLimH], 'YTick', [0 yLimH], 'YTickLabel', {[], yLimH});
        title('Tag offset', 'FontSize', fontS);
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
            'Marker', '.', 'MarkerSize', markerS, 'LineStyle', 'none', 'Color', lineClr{ceil(iType/nMod), mod(iType-1, nMod)+1});
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
    
    varNum = [1, nMod-1, nMod, nMod, nMod]; % intercept (1), modulation (nMod-1), cue (nMod), reward (nMod), punishment (nMod)
    varPosition = cumsum(varNum) - varNum;
    p_crm = cell(1, 3);
    for iP = 1:3
        p_crm{iP} = double(reg_crm.p < pthreshold(iP) & reg_crm.p >= pthreshold(iP+1)); p_crm{iP}(p_crm{iP}==0) = NaN;
        plot(reg_crm.time/1000, p_crm{iP}(varPosition(3)+1,:)*ylimpsth*0.95, ...
            'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
            'MarkerFaceColor', colorYellow, 'Color', colorYellow); % cue
        plot(reg_crm.time/1000, p_crm{iP}(varPosition(4)+1,:)*ylimpsth*0.90, ...
            'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
            'MarkerFaceColor', colorRed, 'Color', colorRed); % reward
        plot(reg_crm.time/1000, p_crm{iP}(varPosition(5)+1,:)*ylimpsth*0.85, ...
            'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
            'MarkerFaceColor', colorBlue, 'Color', colorBlue); % punishment
    end
    
    for jType = find(trialResult~=0)
        if mod(jType,2)==1
            fill([psthtime flip(psthtime)], psthsem(jType, :), lineClr{ceil(jType/nMod), mod(jType-1, nMod)+1}, ...
                'LineStyle', 'none', 'FaceAlpha', transparency);
            plot(psthtime, psthconv(jType,:), ...
                'LineStyle', lineStl{ceil(jType/nMod), mod(jType-1, nMod)+1}, 'LineWidth', lineWth(ceil(jType/nMod), mod(jType-1, nMod)+1), 'Color', lineClr{ceil(jType/nMod), mod(jType-1, nMod)+1});
        end
    end
    set(hMain(2), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
    title('Cue x Rw | Mod = 0', 'FontSize', fontM);
    ylabel('Rate (Hz)', 'FontSize', fontS);
    
    % Psth 2 (Cue x Mod)
    for iMod = 1:nMod-1
        hMain(2+iMod) = axes('Position',axpt(1,4,1,1+iMod,axpt(nCol,nRowMain,2:3,[3 7],[],wideInterval),wideInterval));
        hold on;
        ylimpsth = ceil(max(psthconvCue(:))*1.1+0.0001);
        for iDur = 2:4
            plot([eventDuration(iDur) eventDuration(iDur)],[0.01 nTrial], ...
                'LineStyle',':', 'LineWidth', lineM, 'Color', colorGray);
        end
        
        pMod_crm = cell(1, 2);
        for iP = 1:3
            % non-mod p value
            plot(reg_crm.time/1000, p_crm{iP}(varPosition(3)+1,:)*ylimpsth*0.95, ...
                'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
                'MarkerFaceColor', colorYellow, 'Color', colorYellow);
            pMod_crm{iP} = double(reg_crm.pMod < pthreshold(iP) & reg_crm.pMod >= pthreshold(iP+1)); pMod_crm{iP}(pMod_crm{iP}==0) = NaN;
            
            % mod p value
            plot(reg_crm.time/1000, p_crm{iP}(varPosition(3)+iMod+1,:)*ylimpsth*0.90, ...
                'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
                'MarkerFaceColor', colorLightYellow, 'Color', colorLightYellow);
            plot(reg_crm.time/1000, p_crm{iP}(varPosition(2)+iMod, :)*ylimpsth*0.05, ...
                'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
                'MarkerFaceColor', colorGray, 'Color', colorGray);
            plot(reg_crm.time/1000, squeeze(pMod_crm{iP}(1, iMod, :))*ylimpsth*0.10, ...
                'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
                'MarkerFaceColor', colorDarkGray, 'Color', colorDarkGray);
        end
        
        for jType = find(cueResult~=0 & repmat((1:nMod)==1 | (1:nMod)==(iMod+1), 1, 4))
            fill([psthtime flip(psthtime)], psthsemCue(jType, :), lineClr{ceil(jType/nMod)*2-1, mod(jType-1, nMod)+1}, ...
                'LineStyle', 'none', 'FaceAlpha', transparency);
            plot(psthtime, psthconvCue(jType,:), ...
                'LineStyle', lineStl{ceil(jType/nMod)*2-1, mod(jType-1, nMod)+1}, ...
                'LineWidth', lineWth(ceil(jType/nMod)*2-1, mod(jType-1, nMod)+1), ...
                'Color', lineClr{ceil(jType/nMod)*2-1, mod(jType-1, nMod)+1});
        end
        set(hMain(2+iMod), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
        title(['Cue x Mod = ',num2str(iMod)], 'FontSize', fontM);
%         xlabel('Time (s)', 'FontSize', fontS);
        ylabel('Rate (Hz)', 'FontSize', fontS);   
    end
    
    set(hMain, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS, ...
        'XLim', eventDuration([1 end]), 'XTick', eventDuration([1:4 end]));
    
    % Psth 3 (Spikes per trial plot - early delay period)
    hTrial(1) = axes('Position',axpt(1,4,1,4,axpt(nCol,nRowMain,2:3,[3 7],[],wideInterval),wideInterval));
    hold on;
    [~, delaySpike] = spikeBin(spikeTime, [500 1500], 1000, 1000);
    yMaxTrial = ceil(max(delaySpike)*1.05);
    for jType = find(cueResult~=0)
        trialX = find(cueIndex(:, jType));
        plot(trialX, delaySpike(cueIndex(:, jType)), ...
            'LineStyle', 'none', 'Marker', '+', 'MarkerSize', markerM, ...
            'MarkerFaceColor', lineClr{ceil(jType/nMod)*2-1, mod(jType-1, nMod)+1}, ...
            'Color', lineClr{ceil(jType/nMod)*2-1, mod(jType-1, nMod)+1});
    end
    title('Firing rate during cue period per trial', 'FontSize', fontM);
    xlabel('Trial', 'FontSize', fontS);
    ylabel('Rate (Hz)', 'FontSize', fontS);
    set(hTrial, 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS, ...
        'XLim', [0 nTrial], 'XTick', 0:100:nTrial, ...
        'YLim', [0 yMaxTrial], 'YTick', [0 yMaxTrial]);
    
    align_ylabel([hMain hTrial]);
    
    
    %% Reward aligned
    % Reward raster
    hRw(1) = axes('Position',axpt(nCol,nRowMain,4,1:2,[],wideInterval));
    hold on;
    plot([0 0], [0.01 nTrial], ...
        'LineStyle',':', 'LineWidth',lineM, 'Color', colorGray);
    for iType = find(trialResult~=0)
        plot(xptRw{iType}, yptRw{iType}, ...
            'Marker', '.', 'MarkerSize', markerS, 'LineStyle', 'none', 'Color', lineClr{ceil(iType/nMod), mod(iType-1, nMod)+1});
    end
    set(hRw(1), 'YLim', [0 nTrialRw], 'YTick', [0 nTrialRw], 'YTickLabel', {[], nTrialRw});
    
    % PsthRw 2-3 (Rw x Mod | Cue)
    cues = unique(cue);
    nCue = length(cues);
    for iMod = 1:nMod-1
        for iCue = 1:nCue
            hRw((iCue-1)*(nMod-1)+iMod+1) = axes('Position',axpt(1,4,1,(iCue-1)*(nMod-1)+iMod,axpt(nCol,nRowMain,4,[3 7],[],wideInterval),wideInterval));
            hold on;
            ylimpsth = ceil(max(psthconvRw(:))*1.1+0.0001);
            plot([0 0], [0.01 nTrial], ...
                'LineStyle',':', 'LineWidth',lineM, 'Color', colorGray);
            
            [pRw_crm, pRwMod_crm] = deal(cell(1, 3));
            for iP = 1:3
                pRw_crm{iP} = double(regRw_crm.p < pthreshold(iP) & regRw_crm.p >= pthreshold(iP+1)); pRw_crm{iP}(pRw_crm{iP}==0) = NaN;
                pRwMod_crm{iP} = double(regRw_crm.pMod < pthreshold(iP) & regRw_crm.pMod >= pthreshold(iP+1)); pRwMod_crm{iP}(pRwMod_crm{iP}==0) = NaN;
                
                plot(regRw_crm.time/1000, pRw_crm{iP}(varPosition(3+iCue)+1,:)*ylimpsth*0.95, ...
                    'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
                    'MarkerFaceColor', lineClr{(cues(iCue)-1)*2+1, 1}, 'Color', lineClr{(cues(iCue)-1)*2+1, 1});
                
                plot(regRw_crm.time/1000, pRw_crm{iP}(varPosition(3+iCue)+iMod+1,:)*ylimpsth*0.90, ...
                    'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
                    'MarkerFaceColor', lineClr{(cues(iCue)-1)*2+1, 2}, 'Color', lineClr{(cues(iCue)-1)*2+1, 2});
                plot(regRw_crm.time/1000, pRw_crm{iP}(varPosition(2)+iMod, :)*ylimpsth*0.05, ...
                    'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
                    'MarkerFaceColor', colorGray, 'Color', colorGray);
                plot(regRw_crm.time/1000, squeeze(pRwMod_crm{iP}(1+iCue, iMod, :))*ylimpsth*0.10, ...
                    'LineStyle', 'none', 'Marker', pMarker{iP}, 'MarkerSize', markerM, ...
                    'MarkerFaceColor', colorDarkGray, 'Color', colorDarkGray);
            end
            
            selectPlot = 2*nMod*(cues(iCue)-1)+(1:(2*nMod));
            for jType = selectPlot(repmat((1:nMod)==1 | (1:nMod)==(iMod+1), 1, 2))
                if trialResult(jType)~=0
                    fill([psthtimeRw flip(psthtimeRw)], psthsemRw(jType, :), lineClr{ceil(jType/nMod), mod(jType-1, nMod)+1}, ...
                        'LineStyle', 'none', 'FaceAlpha', transparency);
                    plot(psthtimeRw, psthconvRw(jType,:), ...
                        'LineStyle', lineStl{ceil(jType/nMod), mod(jType-1, nMod)+1}, ...
                        'LineWidth', lineWth(ceil(jType/nMod), mod(jType-1, nMod)+1), ...
                        'Color', lineClr{ceil(jType/nMod), mod(jType-1, nMod)+1});
                end
            end
            set(hRw((iCue-1)*(nMod-1)+iMod+1), 'YLim', [0 ylimpsth], 'YTick', [0 ylimpsth], 'YTickLabel', {[], ylimpsth});
            title(['Rw x Mod = ', num2str(iMod), ' | Cue=',cueName{iCue}], 'FontSize', fontM);
            ylabel('Rate (Hz)', 'FontSize', fontS);
%             if iCue==nCue & iMod==nMod-1
%                 xlabel('Time from reward onset (s)', 'FontSize', fontS);
%             end
        end
    end
    set(hRw, 'Box', 'off', 'TickDir', 'out', 'LineWidth', lineS, 'FontSize', fontS, ...
        'XLim', [winRw(1)/1000+1 winRw(2)/1000-1], 'XTick', [winRw(1)/1000+1 0 winRw(2)/1000-1]);
    align_ylabel(hRw(1:end))
    
    print(gcf,'-dtiff','-r300',[cellFigName{1},'.tif']);
    close;
end
cd(rtdir);