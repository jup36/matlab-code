clearvars;

startingDir = 'C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\Behavior\SOMChR';
findingFile = 'SOMChR*result*.txt';
sList = FindFiles(findingFile, 'StartingDirectory', startingDir, 'CheckSubdirs', 0);
[~, cellNm] = cellfun(@fileparts, sList, 'UniformOutput', false);
cellNms = cellfun(@(x) strsplit(x, '_'), cellNm, 'UniformOutput', false);

mouseNm = cellfun(@(x) x{1}, cellNms, 'UniformOutput', false);
sessionTime = datetime(cellfun(@(x) [x{2} x{3}], cellNms, 'UniformOutput', false), 'InputFormat', 'yyyyMMddHHmmss');
[~, idx] = sort(sessionTime);

mList = unique(mouseNm);
nM = length(mList);
[perf_0, perf_1] = deal(NaN(nM, 40));
for iM = 1:nM
    inS = find(strcmp(mouseNm, mList{iM}));
    nS = length(inS);
    if nS > 40; nS=40; end;
    
    for iS = 1:nS
        sData = importdata(sList{inS(iS)});
        if isempty(sData); continue; end;
        inT = sData(1,:)~=0;
        target = sData(1,inT)';
        choice = sData(2,inT)';
        correct = target==choice;
        light = sData(7,inT)';

        perf_0(iM, iS) = nanmean(correct(light==0));
        if iS >= 8
            perf_1(iM, iS) = nanmean(correct(light==1));
        end
    end
end
mPerf_0 = nanmean(perf_0);
mPerf_1 = nanmean(perf_1);

close all;
hold on;
plot(perf_0', 'Color', [0.5 0.5 0.5], 'Marker', 's', 'MarkerSize', 4, 'LineStyle', 'none');
plot(perf_1', 'Color', [0.5 0.5 1], 'Marker', 'o', 'MarkerSize', 4, 'LineStyle', 'none');
plot(mPerf_0, 'Color', 'k', 'LineWidth', 2, 'Marker', 's', 'MarkerSize', 8);
plot(mPerf_1, 'Color', 'b', 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 8);
