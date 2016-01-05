clc; clear all; close all;
sessionFolder = {'D:\Cheetah_data\classical_conditioning\PVMD2\2015-09-22_s4_1.60DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-09-23_s4_1.65DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-09-24_s5_1.70DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-09-25_s5_1.75DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-10-01_s5_1.80DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-10-02_s5_1.85DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-10-05_s5_1.90DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-10-06_s5_1.95DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-10-07_s5_2.00DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-09-22_s4_1.45DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-09-23_s4_1.50DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-09-24_s5_1.55DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-09-25_s5_1.60DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-10-01_s5_1.65DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-10-02_s5_1.70DV'};
nSession = length(sessionFolder);

cellList = {};
for iSession = 1:nSession
    cellList = [cellList; FindFiles('T*.mat','StartingDirectory',sessionFolder{iSession})];
end
nCell = length(cellList);

C_nomod = zeros(nCell,76);
R_nomod = zeros(nCell,76);
X_nomod = zeros(nCell,76);

C_mod = zeros(nCell,76);
R_mod = zeros(nCell,76);
X_mod = zeros(nCell,76);

C_Rw = zeros(nCell,56);
R_Rw = zeros(nCell,56);
X_Rw = zeros(nCell,56);

C_Rw_mod = zeros(nCell,56);
R_Rw_mod = zeros(nCell,56);
X_Rw_mod = zeros(nCell,56);

for iCell = 1:nCell
    load(cellList{iCell});
    
    if iCell == 1;
        time = reg_cr_nomod.time / 1000;
        timeRw = regRw_cr_nomod.time / 1000;
    end
    C_nomod(iCell,:) = reg_cr_nomod.p(1,:);
    R_nomod(iCell,:) = reg_cr_nomod.p(2,:);
    X_nomod(iCell,:) = reg_cr_nomod.p(3,:);
    
    C_mod(iCell,:) = reg_cr_mod.p(1,:);
    R_mod(iCell,:) = reg_cr_mod.p(2,:);
    X_mod(iCell,:) = reg_cr_mod.p(3,:);
    
    C_Rw(iCell,:) = regRw_cr_nomod.p(1,:);
    R_Rw(iCell,:) = regRw_cr_nomod.p(2,:);
    X_Rw(iCell,:) = regRw_cr_nomod.p(3,:);
    
    C_Rw_mod(iCell,:) = regRw_cr_mod.p(1,:);
    R_Rw_mod(iCell,:) = regRw_cr_mod.p(2,:);
    X_Rw_mod(iCell,:) = regRw_cr_mod.p(3,:);
end

threshold = 0.05;
fon_C_nomod = mean(C_nomod <= threshold);
fon_R_nomod = mean(R_nomod <= threshold);
fon_X_nomod = mean(X_nomod <= threshold);

fon_C_mod = mean(C_mod <= threshold);
fon_R_mod = mean(R_mod <= threshold);
fon_X_mod = mean(X_mod <= threshold);

fonRw_C_nomod = mean(C_Rw <= threshold);
fonRw_R_nomod = mean(R_Rw <= threshold);
fonRw_X_nomod = mean(X_Rw <= threshold);

fonRw_C_mod = mean(C_Rw_mod <= threshold);
fonRw_R_mod = mean(R_Rw_mod <= threshold);
fonRw_X_mod = mean(X_Rw_mod <= threshold);

fHandle = figure('PaperUnits','centimeters','PaperPosition',[0 0 18.3 13.725]);
ha(1) = axes('Position',axpt(2,3,1,1,[],[0.1 0.1]));
hold on;
plot(time,fon_C_nomod,'Color','k','LineWidth',2);
plot(time,fon_C_mod,'Color','r','LineWidth',2);
plot([0 0], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
plot([1 1], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
plot([2 2], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
title('Cue');

ha(2) = axes('Position',axpt(2,3,1,2,[],[0.1 0.1]));
hold on;
plot(time,fon_R_nomod,'Color','k','LineWidth',2);
plot(time,fon_R_mod,'Color','r','LineWidth',2);
plot([0 0], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
plot([1 1], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
plot([2 2], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
title('Reward');

ha(3) = axes('Position',axpt(2,3,1,3,[],[0.1 0.1]));
hold on;
plot(time,fon_X_nomod,'Color','k','LineWidth',2);
plot(time,fon_X_mod,'Color','r','LineWidth',2);
plot([0 0], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
plot([1 1], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
plot([2 2], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
title('Interaction');
set(ha,'Box','off','TickDir','out','LineWidth',0.2,'FontSize',8,...
    'XLim', [-0.5 5.5], 'XTick', [-0.5 0 1 2 5.5], ...
    'YLim', [0 1], 'YTick', [0 1]);

hb(1) = axes('Position',axpt(2,3,2,1,[],[0.1 0.1]));
hold on;
plot(timeRw,fonRw_C_nomod,'Color','k','LineWidth',2);
plot(timeRw,fonRw_C_mod,'Color','r','LineWidth',2);
plot([0 0], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
title('Cue');

hb(2) = axes('Position',axpt(2,3,2,2,[],[0.1 0.1]));
hold on;
plot(timeRw,fonRw_R_nomod,'Color','k','LineWidth',2);
plot(timeRw,fonRw_R_mod,'Color','r','LineWidth',2);
plot([0 0], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
title('Reward');

hb(3) = axes('Position',axpt(2,3,2,3,[],[0.1 0.1]));
hold on;
plot(timeRw,fonRw_X_nomod,'Color','k','LineWidth',2);
plot(timeRw,fonRw_X_mod,'Color','r','LineWidth',2);
plot([0 0], [0 1], 'Color', [0.2 0.2 0.2], 'LineWidth', 0.5, 'LineStyle', ':');
title('Interaction');
set(hb,'Box','off','TickDir','out','LineWidth',0.2,'FontSize',8,...
    'XLim', [-1 3], 'XTick', [-1 0 3], ...
    'YLim', [0 1], 'YTick', [0 1]);

print(gcf,'-dtiff', '-r300', 'fon_2_cue_1_delay.tif');