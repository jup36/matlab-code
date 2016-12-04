clc; clearvars; close all;

binSize = 1;
winWidth = 20;
gapS = [0.015 0.05];

nMaxSubFig = 8;
fontS = 5;
fontM = 6;
titleColor = {'r', 'b', 'g'};

eraseBinWidth = [-10, 3000];

load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat', 'nspv', 'nssom', 'wssom');
neuron = mat2tt(nssom);
nN = length(neuron);
[~, neuronName] = cellfun(@fileparts, neuron, 'UniformOutput', false);

% nspv, iN=1, TT7_2 (pc) -> TT7_1 (pv)
% nspv, iN=2, 

for iN = 2
    sessionFolder = {fileparts(neuron{iN})};
    
    % exclude time after light onset
    [eData, eList] = eLoad(sessionFolder);
    lightTime = eData.t(strcmp(eData.s, 'Light'));
    nLight = length(lightTime);
    
    outTime = sortrows([lightTime + eraseBinWidth(1), ones(nLight, 1); lightTime + eraseBinWidth(2), -ones(nLight, 1)]);
    outTimeOffset = find(cumsum(outTime(:, 2))==0);
    nOutTime = length(outTimeOffset);
    outTimeIndex = [[1; outTimeOffset(1:end-1)+1], outTimeOffset];
    outTimeBin = outTime(outTimeIndex)';
    
    % load cell data
    [tData, tList] = tLoad(sessionFolder);
    [~, tName] = cellfun(@fileparts, tList, 'UniformOutput', false);
    nC = length(tList);
    
    for iC = 1:nC
        [~, outSpike] = histc(tData{iC}, outTimeBin);
        tData{iC}(mod(outSpike, 2)==1) = [];
    end
      
    % cross correlation
    tagIndex = find(strcmp(tName, neuronName{iN}));
    nSubFig = ceil(sqrt(nC));
    
    for iS = 1:2
        for iX = 1:nC
            if iS==1
                [cData, cTime] = CrossCorr(tData{tagIndex}, tData{iX}, binSize, floor(2*winWidth/binSize)+1);
            else
                [cData, cTime] = CrossCorr(tData{iX}, tData{tagIndex}, binSize, floor(2*winWidth/binSize)+1);
            end
            
            if iX == tagIndex
                cData(cTime==0) = 0;
            end
            
            figure(iS);
            axes('Position', axpt(nSubFig, nSubFig, mod(iX-1, nSubFig)+1, floor((iX-1)/nSubFig)+1, [], gapS));
            hold on;
            yM = ceil(max(cData)*1.2 + 10^-10);
            plot([0 0], [0 yM], 'LineStyle', ':', 'Color', [0.5 0.5 0.5]);
            hB = bar(cTime, cData, 'histc');
            set(hB, 'FaceColor', 'k', 'LineStyle', 'none');
            
            if iX ~= tagIndex
                if iS==1
                    cJit = CrossCorrJitter(tData{tagIndex}, tData{iX}, binSize, floor(2*winWidth/binSize)+1, 5, 1000);
                else
                    cJit = CrossCorrJitter(tData{iX}, tData{tagIndex}, binSize, floor(2*winWidth/binSize)+1, 5, 1000);
                end
                cJit = sort(cJit');
                lowJitter1 = cJit(11,:);
                lowJitter5 = cJit(51,:);
                highJitter1 = cJit(1000-10, :);
                highJitter5 = cJit(1000-50, :);
                
                plot(cTime, lowJitter1, 'r', 'LineWidth', 1);
                plot(cTime, lowJitter5, 'r:', 'LineWidth', 1);
                plot(cTime, mean(cJit), 'b', 'LineWidth', 1);
                plot(cTime, highJitter5, 'r:', 'LineWidth', 1);
                plot(cTime, highJitter1, 'r', 'LineWidth', 1);
            end
            
            if iS==1
                title([tName{tagIndex}, '¡æ', tName{iX}], 'FontSize', fontM, 'Color', titleColor{iS});
            else
                title([tName{iX}, '¡æ', tName{tagIndex}], 'FontSize', fontM, 'Color', titleColor{iS});
            end
            set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', fontS, 'LineWidth', 0.2, ...
                'XLim', [-winWidth, winWidth], 'XTick', -winWidth:10:winWidth, ...
                'YLim', [0 yM], 'YTick', yM);
        end
    end
end