clc; clearvars; close all;

binSize = 0.5;
winWidth = 20;
gapS = [0.015 0.05];

nMaxSubFig = 8;
fontS = 5;
fontM = 6;
titleColor = {'k', 'r', 'b', 'g'};

eraseBinWidth = [-10, 40];

load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat', 'wssom');
neuron = mat2tt(wssom);
nN = length(neuron);
[~, neuronName] = cellfun(@fileparts, neuron, 'UniformOutput', false);

for iN = 5  
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
    
    iX = 1;
    iY = 2;
    
    [cData, cTime] = CrossCorr(tData{iX}, tData{iY}, binSize, floor(2*winWidth/binSize)+1);
    [cData_my, cTime_my] = crossCorrelation(tData{iX}, tData{iY}, binSize, winWidth);
    
    subplot(1, 2, 1);
    bar(cTime, cData, 'histc');
    set(gca, 'XLim', [-winWidth winWidth]);
    
    subplot(1, 2, 2);
    bar(cTime_my, cData_my, 'histc');    
    set(gca, 'XLim', [-winWidth winWidth]);
end
    