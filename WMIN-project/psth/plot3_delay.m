function plot3_delay
% This m file plots all pv and som cells using color map (imagesc). Peak firing rate will be used to align cells.

% Variable nspv, nssom, and wssom will be used.
load('D:\Cloud\project\workingmemory_interneuron\data\celllist_20150527.mat');

C1 = sortunit(pv,1);
C2 = sortunit(nssom,1);
C3 = sortunit(wssom,1);

nC(1) = sum(C1.pref==1);
nC(2) = sum(C1.pref==2);

nC(3) = sum(C2.pref==1);
nC(4) = sum(C2.pref==2);

nC(5) = sum(C3.pref==1);
nC(6) = sum(C3.pref==2);

scale = 100;
gap_s = 1;
gap_l = 5;
interval_s = 0.075;
color_red = [0.906 0.184 0.153];
color_blue = [0.012 0.337 0.608];
font_s = 3;
font_m = 4;
font_l = 5;
title_pos = 325;


close all;
fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.9/2 6.88]);
colormap jet;

h(1) = axes('Position',axpt(2,scale,1,[gap_l+1 gap_l+nC(1)]+3,axpt(2,1,1,1),[interval_s 0]));
plot3(C1.time(C1.pref==1,:), C1.LR(C1.pref==1,:), 1:sum(C1.pref==1));
% text(title_pos, -4, 'PV', ...
%     'FontSize', font_l, 'Color', 'k', 'HorizontalAlign', 'center');
% text(301/2, -1.25, 'Right target', ...
%     'FontSize', font_s, 'Color', color_red, 'HorizontalAlign', 'center');

% h(2) = axes('Position',axpt(2,scale,2,[gap_l+1 gap_l+nC(1)]+3,axpt(2,1,1,1),[interval_s 0]));
% imagesc(C1.RL(C1.pref==1,:));
% text(301/2,-1.25,'Left target', ...
%     'FontSize', font_s, 'Color', color_blue, 'HorizontalAlign', 'center');
% 
% h(3) = axes('Position',axpt(2,scale,1,[gap_l+gap_s+nC(1)+1 gap_l+gap_s+sum(nC(1:2))]+3,axpt(2,1,1,1),[interval_s 0]));
% imagesc(C1.LR(C1.pref==2,:));
% text(title_pos, nC(2)+6, 'Time from delay onset (s)', ...
%     'FontSize', font_m, 'Color', 'k', 'HorizontalAlign', 'center');
% 
% h(4) = axes('Position',axpt(2,scale,2,[gap_l+gap_s+nC(1)+1 gap_l+gap_s+sum(nC(1:2))]+3,axpt(2,1,1,1),[interval_s 0]));
% imagesc(C1.RL(C1.pref==2,:));
% 
% h(5) = axes('Position',axpt(2,scale,1,[gap_l+1 gap_l+nC(3)],axpt(2,1,2,1),[interval_s 0]));
% imagesc(C2.LR(C2.pref==1,:));
% text(title_pos, -4, 'ns-SOM', ...
%     'FontSize', font_l, 'Color', 'k', 'HorizontalAlign', 'center');
% text(301/2, -1.25, 'Right target', ...
%     'FontSize', font_s, 'Color', color_red, 'HorizontalAlign', 'center');
% 
% h(6) = axes('Position',axpt(2,scale,2,[gap_l+1 gap_l+nC(3)],axpt(2,1,2,1),[interval_s 0]));
% imagesc(C2.RL(C2.pref==1,:));
% text(301/2,-1.25,'Left target', ...
%     'FontSize', font_s, 'Color', color_blue,  'HorizontalAlign', 'center');
% 
% h(7) = axes('Position',axpt(2,scale,1,[gap_l+gap_s+nC(3)+1 gap_l+gap_s+sum(nC(3:4))],axpt(2,1,2,1),[interval_s 0]));
% imagesc(C2.LR(C2.pref==2,:));
% 
% h(8) = axes('Position',axpt(2,scale,2,[gap_l+gap_s+nC(3)+1 gap_l+gap_s+sum(nC(3:4))],axpt(2,1,2,1),[interval_s 0]));
% imagesc(C2.RL(C2.pref==2,:));
% 
% h(9) = axes('Position',axpt(2,scale,1,[gap_l*2+gap_s+sum(nC(3:4))+1 gap_l*2+gap_s+sum(nC(3:5))],axpt(2,1,2,1),[interval_s 0]));
% imagesc(C3.LR(C3.pref==1,:));
% text(title_pos, -2, 'ws-SOM', ...
%     'FontSize', font_l, 'Color', 'k', 'HorizontalAlign', 'center');
% 
% h(10) = axes('Position',axpt(2,scale,2,[gap_l*2+gap_s+sum(nC(3:4))+1 gap_l*2+gap_s+sum(nC(3:5))],axpt(2,1,2,1),[interval_s 0]));
% imagesc(C3.RL(C3.pref==1,:));
% 
% h(11) = axes('Position',axpt(2,scale,1,[gap_l*2+gap_s*2+sum(nC(3:5))+1 gap_l*2+gap_s*2+sum(nC(3:6))],axpt(2,1,2,1),[interval_s 0]));
% imagesc(C3.LR(C3.pref==2,:));
% text(title_pos, nC(6)+6, 'Time from delay onset (s)', ...
%     'FontSize', font_m, 'Color', 'k', 'HorizontalAlign', 'center');
% 
% h(12) = axes('Position',axpt(2,scale,2,[gap_l*2+gap_s*2+sum(nC(3:5))+1 gap_l*2+gap_s*2+sum(nC(3:6))],axpt(2,1,2,1),[interval_s 0]));
% imagesc(C3.RL(C3.pref==2,:));

% set(h, 'Box', 'off', 'TickDir', 'out', 'FontSize', font_s, 'LineWidth', 0.2, ...
%     'XTick', [], 'XColor', 'w', ...
%     'YTick', [], 'YColor', 'w');
% set(h([3 4 11 12]), 'XColor', 'k', 'XTick', [1 101 201 301], 'XTickLabel', [0 1 2 3]);
% 
% print(gcf,'-dtiff', '-r600', 'plot3_delay.tif');
% close all;
disp('hi');

% -------------------------------------------------------------------------
function T = sortunit(cellList, delayreward)
% Variables
choice = [1 4];
choicemod = [1 5];
if delayreward == 1
    epoch = 5;
    epochtime = [0 3];
elseif delayreward == 2;
    epoch = 8;
    epochtime = [-1 2];
end
    
nC = length(cellList);

pref = zeros(nC,1);
peaktime = zeros(nC,1);
for iC = 1:nC
    % Load peth during delay period.
    warning('off');
    clearvars peth_modconv;
        
    if iC == 1
        load(cellList{iC}, 'bins', 'pethconv', 'peth_modconv');
        timebin = (bins{epoch} >= epochtime(1)) & (bins{epoch} <= epochtime(2));
        time = repmat(bins{epoch}(timebin),nC,1);
        nT = length(bins{epoch}(timebin));
        LR = zeros(nC, nT);
        RL = zeros(nC, nT);
    else
        load(cellList{iC}, 'pethconv', 'peth_modconv');
    end
    
    if exist('peth_modconv','var')
        peth = peth_modconv{epoch}(choicemod,timebin);
    else
        peth = pethconv{epoch}(choice,timebin);
    end
    
    % Find preference and time of maximum firing rate during delay period.
    [peakfr,idx_peak] = max(peth,[],2);
    [pethmax,idx_pref] = max(peakfr);
    pref(iC) = idx_pref;
    peaktime(iC) = idx_peak(idx_pref);
       
    % normalize (max 1 / min 0);
    peth = peth / pethmax;
    
    LR(iC, :) = peth(1,:);
    RL(iC, :) = peth(2,:);
end

% Divide preferring cells
T = table(pref, peaktime, LR, RL, time);
T = sortrows(T, [1 2]);
