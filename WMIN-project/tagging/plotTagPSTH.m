% plot tagging psth
clearvars; close all;
load('C:\users\lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat', 'pv');

load(pv{18});

subplot(211);
plot(xpttag, ypttag, 'Color', 'k', 'LineWidth', 2, 'Marker', '.');
set(gca, 'XLim', [0 20]);

subplot(212);
hold on;
stairs(time_tagstat,H1_tagstat);
stairs(time_tagstat,H2_tagstat);