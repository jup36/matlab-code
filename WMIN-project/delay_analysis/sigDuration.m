function sigDuration
%sigDuration plots duration of significant difference between targets during delay

load('D:\Cloud\project\workingmemory_interneuron\data\celllist_20150527.mat');

durPC = loadSpikeFile(pc);
durFS = loadSpikeFile(fs);

sum(durPC.RS==0)/length(durPC.RS)
sum(durFS.RS==0)/length(durFS.RS)

close all;
fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.9/2 6.88/2]);
[histData1,t1] = hist(durPC.RS,30);
bar(t1, histData1, 'LineStyle', 'none', 'FaceColor', 'k');
max1 = max(histData1);
xlabel('Significant duration (s)');
ylabel('Cell number');

% h(2) = subplot(2,1,2);
% [histData2, t2] = hist(durPC.RS_BF,30, 'LineStyle', 'none', 'FaceColor', 'k');
% bar(t2, histData2, 'LineStyle', 'none', 'FaceColor', 'k');
% max2 = max(histData2);
% xlabel('Significant duration (s)');
% ylabel('Cell number');
% title('Bonferroni corrected');

set(gca, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 0.02, 'FontSize', 4, ...
    'XLim', [0 3], 'XTick', [0 1 2 3]);
set(gca, 'YLim', [0 max1], 'YTick', [0 max1]);
% set(h(2), 'YLim', [0 max2], 'YTick', [0 max2]);

print(gcf,'-dtiff', '-r600', 'significant_duration.tif');
close all;

function durationStat = loadSpikeFile(mFL)
alpha = 0.05;
k = 30;

nC = length(mFL);
durationRS = zeros(nC, 1);
durationRS_bonferoni = zeros(nC, 1);
durationTT = zeros(nC, 1);
durationTT_bonferoni = zeros(nC, 1);
for iC = 1:nC
    load(mFL{iC}, 'statDelay');
    inTime = statDelay.time >=0 & statDelay.time <= 3000;
    durationRS(iC) = sum(statDelay.p_ranksum(inTime) < alpha) / 10;
    durationTT(iC) = sum(statDelay.p_ttest(inTime) < alpha) / 10;
    durationRS_bonferroni(iC) = sum(statDelay.p_ranksum(inTime) < alpha/k) / 10;
    durationTT_bonferroni(iC) = sum(statDelay.p_ttest(inTime) < alpha/k) / 10;
end

durationStat = struct('time', statDelay.time(inTime), 'RS', durationRS, 'TT', durationTT, ...
    'RS_BF', durationRS_bonferroni, 'TT_BF', durationTT_bonferroni);