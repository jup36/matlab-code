clc; clearvars; close all;
parentDir = 'C:\Users\Lapis\OneDrive\project\classical_conditioning\data\';
miceList = {'CC-PV-ChR1'; ...
    'CC-PV-ChR2'; ...
    'CC-PV-ChR3'; ...
    'CC-PV-ChR4'; ...
    'CC-SOM-ChR1'; ...
    'CC-SOM-ChR3'; ...
    'CC-SOM-ChR4'; ...
    'CC-SOM-ChR5'};
mouseLine = {'PV', 'PV', 'PV', 'PV', 'SOM', 'SOM', 'SOM', 'SOM'};
nM = length(miceList);

T = table();
for iM = 1:nM
    cellList = FindFiles('T*.mat', 'CheckSubDirs', 1, 'StartingDirectory', [parentDir, miceList{iM}]);
    nC = length(cellList);
    
    [group peakValleyRatio spikeWidth firingRate halfValleyWidth pLR pSalt] = deal(zeros(nC,1));
    spikeWave = cell(nC,1);
    for iC = 1:nC
        load(cellList{iC},'spkwv', 'spkwth','spkpvr','fr_base','hfvwth', 'p_tagBlue', 'p_saltBlue');
        
        yLim = [min(spkwv(:)) max(spkwv(:))]*1.1;
        for iT = 1:4
            subplot(2,4,iT);
            plot(spkwv(iT,:), 'k');
            set(gca, 'Box', 'off', 'TickDir', 'out', ...
                'XLim', [0 32], 'XTick', [], ...
                'YLim', yLim, 'YTick', 0, 'YTickLabel', []);
        end
        subplot(2,2,3);
            text(0, 0, ['Firing rate: ', num2str(fr_base,5)]);
            set(gca, 'Visible', 'off', 'XLim', [0 1], 'YLim', [0 1]);
        
        notok = true;
        while notok
            textInput = input('1: ns, 2: ws, 3: out? ');
            if textInput >=0 | textInput <=4
                group(iC) = textInput;
                notok = false;
            end
        end    
        clf;
        
        peakValleyRatio(iC) = spkpvr;
        spikeWidth(iC) = spkwth;
        if fr_base==0; firingRate(iC) = NaN;
        else
            firingRate(iC) = fr_base;
        end
        if ~isempty(hfvwth); 
            halfValleyWidth(iC) = hfvwth;
        else
            halfValleyWidth(iC) = NaN;
        end
        pLR(iC) = p_tagBlue;
        pSalt(iC) = p_saltBlue;
        spikeWave{iC} = spkwv;
    end
    
    mouseLine = categorical(repmat(mouseLine(iM), nC, 1));
    mouseNm = categorical(repmat(miceList(iM),nC,1));
    Tnew = table(mouseLine, mouseNm, cellList, group, spikeWave, peakValleyRatio, spikeWidth, firingRate, halfValleyWidth, pLR, pSalt);
    T = [T; Tnew];
end

% save('cellTable.mat', 'T');