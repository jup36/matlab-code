clc; clearvars; close all;
% Red: PV or SOM
% Green: ChR2

RG = [35 30 36; 47 49 50]'; % row 1: PV-cre, row 2: SOM-cre
R = [2 3 3; 2 0 0]';
G = [2 2 2; 10 5 2]';

PVorSOM = RG ./ (RG + R);
ChR2 = RG ./ (RG + G);

PVorSOMmean = mean(PVorSOM);
PVorSOMsse = std(PVorSOM) ./ sqrt(3);

ChR2mean = mean(ChR2);
ChR2sse = std(PVorSOM) ./ sqrt(3);

fhandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5 6.375]);
subplot(1,2,1);
hold on;

hb1 = bar(1:2, [PVorSOMmean(1) ChR2mean(1)]);
heb1 = errorbar(1:2, [PVorSOMmean(1) ChR2mean(1)], [PVorSOMsse(1) ChR2sse(1)]);
set(hb1, 'LineWidth', 0.2, 'FaceColor', [0.5 0.5 0.5]);

subplot(1,2,2);
hold on;
bar(1:2, [PVorSOMmean(2) ChR2mean(2)]);
errorbar(1:2, [PVorSOMmean(2) ChR2mean(2)], [PVorSOMsse(2) ChR2sse(2)]);
