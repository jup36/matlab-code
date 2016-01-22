function spikeLatency
% Spike latency and jitter

% Variable nspv, nssom, and wssom will be used.
load('D:\Cloud\project\workingmemory_interneuron\data\celllist_20150527.mat');

s_pv = spkLatency(nspv);
s_nssom = spkLatency(nssom);
s_wssom = spkLatency(wssom);

npv = size(s_pv,1);
nnssom = size(s_nssom,1);
nwssom = size(s_wssom,1);

group = [ones(npv,1);2*ones(nnssom,1);3*ones(nwssom,1)];
all = [s_pv; s_nssom; s_wssom];

xColor = {[0.494 0.184 0.556], [0.929 0.694 0.125], [0.078 .447 0.188]};

close all;
fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.9/2 6.88/2]);
ha(1) = axes('Position', axpt(2,1,1,1,[0.1 0.2 0.85 0.75]));
hb1 = MyScatterBarPlot(all.L, group, 0.5, xColor);
xticklabel_rotate([],45,{'PV', 'ns-SOM', 'ws-SOM'}, 'FontSize',4);
set(gca, 'YLim', [0 4], 'YTick', 0:4, 'YTickLabel', {0, [], [], [], 4});
ylabel('Latency (ms)');

ha(2) = axes('Position', axpt(2,1,2,1,[0.1 0.2 0.85 0.75]));
hb2 = MyScatterBarPlot(all.J, group, 0.5, xColor);
% set(ha, 'XTickLabel', {'PV', 'ns-SOM', 'ws-SOM'});
xticklabel_rotate([],45, {'PV', 'ns-SOM', 'ws-SOM'}, 'FontSize',4);
set(gca, 'YLim', [0 2], 'YTick', 0:0.5:2, 'YTickLabel', {0, [], [], [], 2});
ylabel('Jitter (ms)');
print(fHandle, '-dtiff', '-r300', 'spikeLatency.tif');

function stats = spkLatency(mFile)
lightwin = 5;

[tData tList] = tLoad(mFile);
eList = cellfun(@(x) [fileparts(x),'\Events.mat'], tList, 'UniformOutput',false);

nT = length(tList);
[L J] = deal(zeros(nT,1));
for iT = 1:nT
    load(eList{iT}, 'lighttime');
    lighttime = lighttime/1000;
    
    nL = length(lighttime);
    fstspk = zeros(nL, 1);
    for iL = 1:nL
        inRange = (tData{iT} >= lighttime(iL)) & (tData{iT} < lighttime(iL)+lightwin);
        if any(inRange)
            fstspk(iL) = tData{iT}(find(inRange, 1, 'first')) - lighttime(iL);
        else
            fstspk(iL) = NaN;
        end
    end
    nonan = sum(~isnan(fstspk));
    L(iT) = nanmean(fstspk);
    J(iT) = nanstd(fstspk);
end
stats = table(L, J);
