clc; clearvars; close all;
startFolder = 'C:\Users\lapis\Dropbox\Dohoung';
sessionFolder = {uigetdir(startFolder, 'Choose session folder to analyse.')};

%% event load
[eData, eList] = eLoad(sessionFolder);
nL = length(eData.s);

ssfoBlueIndex = strcmp(eData.s,'ssfoBlue');
ssfoRedIndex = strcmp(eData.s,'ssfoRed');
chr2Index = strcmp(eData.s,'chr2');

tDiff = diff(eData.t);

dSsfoBlue = tDiff(ssfoBlueIndex);
dSsfoBlueNext = tDiff([false; ssfoBlueIndex(1:end-1)]);
dChr2 = tDiff(chr2Index);
dChr2Next = tDiff([false; chr2Index(1:end-1)]);
dSsfoRed = tDiff(ssfoRedIndex);
dSsfoRedNext = tDiff([false; ssfoRedIndex(1:end-1)]);

dChr2Chr2 = diff(eData.t(chr2Index));
dSsfoBlueBlue = diff(eData.t(ssfoBlueIndex));
dSsfoRedRed = diff(eData.t(ssfoRedIndex));
