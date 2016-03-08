clearvars;

% pvwm_dir = 'C:\Users\lapis\OneDrive\project\workingmemory_interneuron\data\Behavior\PVWM1';

% txtFile = FindFiles('*.txt', 'StartingDirectory', pvwm_dir);
% noR = cellfun(@(x) isempty(x), strfind(txtFile, 'result'));
% tsFile = txtFile(noR);
% resultFile = txtFile(~noR);
rtdir = pwd;

startingFolder = 'C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\Behavior\';
cd(startingFolder);
[nm, dir] = uigetfile({'*.txt'});
oFile = [dir, nm];
[cellDir, cellNm, cellExt] = fileparts(oFile);
cellNmTemp = strsplit(cellNm, '_');
cellNmTemp2 = FindFiles([cellNmTemp{1}, '_', cellNmTemp{2}, '_', cellNmTemp{3}, '*']);
rFile = cellNmTemp2{cellfun(@(x) ~isempty(strfind(x, 'result')), cellNmTemp2)};

formatSpec = '%10s %1f %1f';
fileID = fopen(oFile,'r');
C = textscan(fileID, formatSpec, 'HeaderLines', 1);
fclose(fileID);

resultIndex = dlmread(rFile);
nT = sum(resultIndex(1,:)~=0);
resultIndex = resultIndex(:,1:nT)';
% col1: target, col2: choice, col3-4: for ploting, col5: delay, col6:
% omission, col7: laser

[~, ~, ~, h, mn, s] = datevec(C{1},'HHMMSS.FFF');
time = (3600*h + 60*mn + s)*1000;

sensor = C{2};
run = C{3};

lickT = time(sensor==9);

eventT = time((sensor==5 & run==1) | (sensor==4 & run==1));
trial = sensor((sensor==5 & run==1) | (sensor==4 & run==1));

repEvent = [false; (diff(eventT) < 1000)];
eventT(repEvent) = [];
trial(repEvent) = [];

Rw = resultIndex(:,1)==resultIndex(:,2) & resultIndex(:,6)==1;
Om = resultIndex(:,1)==resultIndex(:,2) & resultIndex(:,6)==0;
Err = resultIndex(:,1)~=resultIndex(:,2);

trialIndex = [Rw Om Err];
nR = size(trialIndex,2);

% psth
win = [0 5000];
binSize = 10;
resolution = 10;
spikeTime = spikeWin(lickT, eventT, win);
[xpt, ypt, spikeBin, spikeHist, spikeConv] =  rasterPSTH(spikeTime, trialIndex, win, binSize, resolution, 1);

% Plot
lineClr = {[1 0 0], ...
    [0 1 0], ...
    [0 0 1]};
lineS = 0.2;

close all;
fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.9 6.88]);
subplot(2,1,1);
hold on;
for iR = 1:nR
    plot(xpt{iR}, ypt{iR}, 'Marker', '.', 'LineStyle', 'none', 'Color', lineClr{iR});
end
set(gca, 'XLim', win, 'XTick', win(1):1000:win(2), 'XTickLabel', win(1)/1000:win(2)/1000, 'YLim', [0 nT]);
title(cellNmTemp{1});
ylabel('Trials');

subplot(2,1,2);
hold on;
for iR = 1:nR
    plot(spikeBin, spikeConv(iR,:), 'Color', lineClr{iR}, 'LineWidth', lineS);
end
set(gca, 'XLim', win, 'XTick', win(1):1000:win(2), 'XTickLabel', win(1)/1000:win(2)/1000);
xlabel('time (s)');
ylabel('Lick rate (Hz)');

cd(rtdir);
print(gcf, '-dtiff', '-r300', [cellNmTemp{1},'_',cellNmTemp{2}, '.tif']);