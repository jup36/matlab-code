function plotHazardFunc
load('tagstatWM.mat');

plotHz(stats_pc);


function plotHz(stats)
pC = find(stats.pSalt <= 0.01);
nC = length(pC);
for iC = 1:nC
    subplot(nC, 1, iC);
    hold on;
    plot(stats.timeLR{pC(iC)}, stats.H1LR{pC(iC)}, 'Color', [0 0.66 1]);
    plot(stats.timeLR{pC(iC)}, stats.H2LR{pC(iC)}, 'Color', 'k');
end
