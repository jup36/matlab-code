clc; clearvars; close all;
tFile = {'D:\Cheetah_data\classical_conditioning\CC-SOM-ChR3\2016-04-01_AD_1.40DV'};
[tData tList] = tLoad(tFile);
nT = length(tList);

binSize = 1;
winWidth = 20;
gapS = [0.01 0.01];

tic;
nSubFig = 5;
nFig = ceil(nT/nSubFig);
hFig = zeros(nFig, nFig);
for iX = 1:nFig
    for iY = 1:nFig
        hFig(iX, iY) = figure;
    end
end

for iX = 1:nT
    for iY = 1:nT
        [cData, cTime] = CrossCorr(tData{iX}, tData{iY}, binSize, floor(2*winWidth/binSize)+1);
        if iX == iY
            cData(cTime==0) = 0;
        end
        
        figure(hFig(ceil(iX/nSubFig), ceil(iY/nSubFig)));
        axes('Position', axpt(nSubFig, nSubFig, mod(iX-1,5)+1, mod(iY-1,5)+1, [], gapS));
        hold on;
        hB = bar(cTime, cData, 'histc');
        set(hB, 'FaceColor', 'k', 'EdgeColor', 'k');
        
        if iX ~= iY
            cJit = CrossCorrJitter(tData{iX}, tData{iY}, binSize, floor(2*winWidth/binSize)+1, 5, 1000);
            cJit = sort(cJit');
        
            lowJitter = cJit(11,:);
            highJitter = cJit(1000-10, :);
            
            
            plot(cTime, lowJitter, 'r:');
            plot(cTime, highJitter, 'r:');
        end
        
        set(gca, 'Box', 'off', 'TickDir', 'out', ...
            'XLim', [-winWidth winWidth], 'XTick', [-winWidth, -1, 0, 1,winWidth]);
    end
end
toc;
