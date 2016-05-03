function fib3b()
% Peak aligned mean firing rate

% Loading
clearvars; close all;
rtdir = pwd;
load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat');

winWidth = 1;
pk = cell(5,1);
pk{1} = psthpeak(nspv, winWidth);
pk{2} = psthpeak(nssom, winWidth);
pk{3} = psthpeak(wssom, winWidth);
pk{4} = psthpeak(fs, winWidth);
pk{5} = psthpeak(pc, winWidth);

fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5 6.375]);
for iC = 4:5
    axes('Position', axpt(3, 3, mod(iC-1, 3)+1, ceil(iC/3)));
    hold on;
    fill(pk{iC}.timeSSE, pk{iC}.SSE, [0.8 0.8 0.8], 'LineStyle', 'none');
    plot(pk{iC}.time, pk{iC}.mean, 'Color', 'k', 'LineWidth', 1);
    set(gca,'box','off','TickDir','out','LineWidth',0.2,'FontSize',4,...
        'XLim', [-winWidth winWidth], 'XTick', -1:0.5:1, ...
        'YLim', [0.4 1], 'YTick', 0.4:0.2:1);
    
    switch iC
        case 1
            title('ns-PV', 'FontSize', 5);
%             xlabel('Time from peak firing (s)');
            ylabel('Relative firing rate');
        case 2
            title('ns-SOM', 'FontSize', 5);
            xlabel('Time from peak firing (s)');
        case 3
            title('ws-SOM', 'FontSize', 5);
%             xlabel('Time from peak firing (s)');
        case 4
            title('Type I', 'FontSize', 5);
            xlabel('Time from peak firing (s)');
            ylabel('Relative firing rate');
        case 5
            title('Type II', 'FontSize', 5);
            xlabel('Time from peak firing (s)');
    end
end

print(gcf,'-depsc','C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\manuscript\Neuron\Fig\extfig3b_20160315.eps');

function out = psthpeak(celllist, winWidth)
binSize = 0.01;
win = [-winWidth:binSize:winWidth] / binSize;
nW = length(win);
epoch = [1 4 5 8];
choice = [1 4];


nC = length(celllist);
peaks = zeros(nC, nW);
for iC = 1:nC
    load(celllist{iC});

    curMax = zeros(4,1);
    curMaxIdx = zeros(4,2);
    for iE = 1:4
        timeBin = bins{epoch(iE)};
        timeWindow = (timeBin >= (timeBin(1)+winWidth)) & (timeBin <= (timeBin(end)-winWidth));
        psth = pethconv{epoch(iE)}([1 4], timeWindow);
        [rPeak, tIdx] = max(psth, [], 2);
        [curMax(iE), cIdx] = max(rPeak);
        curMaxIdx(iE,:) = [cIdx, tIdx(cIdx)+uint16(winWidth/binSize)];
    end

    [pMax,eIdx] = max(curMax);

   peaks(iC, :)  = pethconv{epoch(eIdx)}(choice(curMaxIdx(eIdx,1)), uint16(curMaxIdx(eIdx,2)+win)) / pMax;
end

out.time = win*binSize;
out.mean = mean(peaks);
out.timeSSE = [out.time flip(out.time)];
sse = std(peaks) / sqrt(nC);
out.SSE = [out.mean - sse, flip(out.mean + sse)];