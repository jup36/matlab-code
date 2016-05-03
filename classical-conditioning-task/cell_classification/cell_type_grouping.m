clc; clearvars; close all;
load('cellTable');

nT = height(T);
normWv = zeros(nT, 32);
for iT = 1:nT
    spkwv = T.spikeWave{iT};
    [maxW, maxTT] = max(max([max(spkwv,[],2) abs(min(spkwv,[],2))], [], 2));
    
    wvTemp = spkwv(maxTT, :) / maxW;
    [~, peakTime] = max(wvTemp);
    if peakTime > 8 & peakTime <= 10
        wvTemp = circshift(wvTemp', 8-peakTime);
        wvTemp((end-(peakTime-9)):end) = NaN;
    end
    
    normWv(iT,:) = wvTemp;
    

end
T.normWv = normWv;

D = [T.peakValleyRatio, T.firingRate, T.halfValleyWidth];
D2 = D(T.group == 1 | T.group == 2, :);
outD = any(isnan(D2), 2);
D2(outD, :) = [];
G = T.group(T.group == 1 | T.group == 2);
G(outD, :) = [];
obj = fitgmdist(D2, 2, 'CovType', 'diagonal', 'Start', G);
P = posterior(obj, D);
group = zeros(nT, 1);
if mean(T.halfValleyWidth(P(:,1)<=0.05)) <= mean(T.halfValleyWidth(P(:,2)<=0.05))
    group(P(:,1)<0.5)=1;
    group(P(:,2)<0.5)=2;
else
    group(P(:,1)<0.5)=2;
    group(P(:,2)<0.5)=1;
end
lineClr = {[0.5 0.5 0.5], [1 0 0], [0 0 0], [0 1 0]};
hold on;
for iT = 1:2
    plot3(T.peakValleyRatio(group==iT), T.firingRate(group==iT), T.halfValleyWidth(group==iT), ...
    'LineStyle', 'none', 'Marker', 'o', 'Color', lineClr{iT+1});
end
set(gca, 'XLim', [0 4], 'YLim', [0 60]);
xlabel('Half-valley width');
ylabel('Firing rate (Hz)');
zlabel('Peak-valley ratio');

T.class = group;

save('cellTable.mat', 'T');

% hold on;
% lineClr = {[0.5 0.5 0.5], [1 0 0], [0 0 0], [0 1 0]};
% for iT = 1:2
%     plot3(log(T.peakValleyRatio(T.group==iT)), T.firingRate(T.group==iT), T.halfValleyWidth((T.group==iT),1), 'LineStyle', 'none', 'Marker', 'o', 'Color', lineClr{iT+1});
% end
% xlabel('Peak-valley ratio');
% ylabel('Firing rate (Hz)');
% zlabel('Half-valley width');

% hold on;
% for iT = 1:2
%     plot3(T.halfValleyWidth(label==iT), T.firingRate(label==iT), T.peakValleyRatio(label==iT), ...
%     'LineStyle', 'none', 'Marker', 'o', 'Color', lineClr{iT+1});
% end
% xlabel('Half-valley width');
% ylabel('Firing rate (Hz)');
% zlabel('Peak-valley ratio');