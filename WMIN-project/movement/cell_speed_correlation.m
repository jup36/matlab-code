% function out = mouse_speed()
clc; clearvars; close all;

% varibles
binDuration = 1000;

% load cell data
load('C:\users\lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat', 'nspv', 'nssom', 'wssom', 'fs', 'pc');
cells = {nspv, [nssom; wssom], fs, pc};
cellNm = {'nspv', 'som', 'fs', 'pc'};
nCT = length(cellNm);

for iCT = 1:nCT
    nC = length(cells{iCT});
    [tData, tList] = tLoad(cells{iCT});
    
    r = NaN(1,nC);
    p = NaN(1,nC);
    for iC = 1:nC
        out = videoInfo([fileparts(tList{iC}),'\VT1.nvt']);
        timeBin = out.timeStamp(1):binDuration:out.timeStamp(end);
        nBin = length(timeBin);
        
        [binTime, indTime] = histc(out.timeStamp, timeBin);
        inTime = indTime~=0;
        
        mVelocity = cellfun(@nanmean, mat2cell(out.speed(inTime), 1, binTime(1:(end-1))));
        binSpike = histc((tData{iC})', timeBin);
        binSpike = binSpike(1:end-1);
        
%         plot(mVelocity, binSpike, ...
%             'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 4, 'Color', 'k');
        
        outT = isnan(mVelocity) | isnan(binSpike);
        [RHO, PVAL] = corrcoef(mVelocity(~outT), binSpike(~outT));
        
        r(iC) = RHO(1,2);
        p(iC) = PVAL(1,2);
    end
    result.(cellNm{iCT}).r = r;
    result.(cellNm{iCT}).p = p;
end

save('cell_speed_correlation', 'result');