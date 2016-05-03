clearvars;

miceType = 'PV';
startingDir = ['C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\Behavior\', miceType, 'ChR'];
findingFile = [miceType, 'ChR*result*.txt'];
sList = FindFiles(findingFile, 'StartingDirectory', startingDir, 'CheckSubdirs', 0);

outCell = cellfun(@(x) ~isempty(strfind(x, 'PVChR4')), sList);
sList(outCell) = [];

[~, cellNm] = cellfun(@fileparts, sList, 'UniformOutput', false);
cellNms = cellfun(@(x) strsplit(x, '_'), cellNm, 'UniformOutput', false);


mouseNm = cellfun(@(x) x{1}, cellNms, 'UniformOutput', false);
% sessionTime = datetime(cellfun(@(x) [x{2} x{3}], cellNms, 'UniformOutput', false), 'InputFormat', 'yyyyMMddHHmmss');
% [~, idx] = sort(sessionTime);

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
fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/1.5 6.375/1.5]);
set(0, 'DefaultAxesFontName', 'Arial');
axes('Position', axpt(1, 11, 1, [1 9]));
hold on;
plot(perf_0', 'Color', [0.5 0.5 0.5], 'Marker', 's', 'MarkerSize', 1, 'LineStyle', 'none');
plot(perf_1', 'Color', [0.5 0.75 1], 'Marker', '.', 'MarkerSize', 4, 'LineStyle', 'none');
plot(mPerf_0, 'Color', 'k', 'LineWidth', 1, 'Marker', 's', 'MarkerSize', 2, 'MarkerFaceColor', 'k');
plot(mPerf_1, 'Color', [0 0.66 1], 'LineWidth', 1, 'Marker', '.', 'MarkerSize', 8);
set(gca, 'LineWidth', 0.2, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 4, ...
    'XLim', [0 21], 'XTick', 0:21, ...
    'YLim', [0.45 1], 'YTick', 0.5:0.1:1, 'YTickLabel', 50:10:100);

ylabel('Performance(%)');

axes('Position', axpt(1, 9, 1, 9));
hold on;
line([0 0], [0.25 1.25], 'LineWidth', 0.4, 'Color', 'k');
text(0, -0.2, 'Handling', 'HorizontalAlign', 'center', 'FontSize', 4);
line([0.75 6.25], [1 1], 'LineWidth', 0.4, 'Color', 'k');
text(3.5, 0.5, 'Training', 'HorizontalAlign', 'center', 'FontSize', 4);
line([6.75 9.25], [1 1], 'LineWidth', 0.4, 'Color', 'k');
text(8, 0.5, 'Test', 'HorizontalAlign', 'center', 'FontSize', 4);
line([9.75 12.25], [1 1], 'LineWidth', 0.4, 'Color', 'k');
text(11, 0.6, '3s + 3mW', 'HorizontalAlign', 'center', 'FontSize', 3);
line([-0.25 2.25]+13, [1 1], 'LineWidth', 0.4, 'Color', 'k');
text(14, 0.6, '5s + 3mW', 'HorizontalAlign', 'center', 'FontSize', 3);
line([-0.25 2.25]+16, [1 1], 'LineWidth', 0.4, 'Color', 'k');
text(17, 0.6, '10s + 3mW', 'HorizontalAlign', 'center', 'FontSize', 3);
line([-0.25 2.25]+19, [1 1], 'LineWidth', 0.4, 'Color', 'k');
text(20, 0.6, '10s + 12mW', 'HorizontalAlign', 'center', 'FontSize', 3);
line([-0.25 11.25]+10, [0.2 0.2], 'LineWidth', 0.4, 'Color', 'k');
text(15.5, -0.2, 'Random test', 'HorizontalAlign', 'center', 'FontSize', 4);
set(gca, 'LineWidth', 0.2, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 4, 'Visible', 'off', ...
    'XLim', [0 21], 'YLim', [0 1]);

print(fHandle, '-depsc', ['C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\manuscript\Neuron\Fig\behavioral_performance_', miceType, '.eps']);