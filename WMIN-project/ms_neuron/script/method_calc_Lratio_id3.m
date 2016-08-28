% target specificity during trial start, sample period, reward period
clc; clearvars; close all;

%% variable
% global MClust_ClusterSeparationFeatures
ChannelValidity = [1 1 1 1];

%% load cell data
load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat');
load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');
tag.p = T.pLR < 0.01 & T.pSalt < 0.01;
tag.pv = tag.p & T.mouseLine=='PV';
tag.nspv = tag.p & T.mouseLine=='PV' & T.class == 1;
tag.som = tag.p & T.mouseLine=='SOM';
tag.nssom = tag.p & T.mouseLine=='SOM' & T.class == 1;
tag.wssom = tag.p & T.mouseLine=='SOM' & T.class == 2;
tag.fs = ~tag.p & T.class == 1;
tag.pc = ~tag.p & T.class == 2;
load('method_calc_Lratio_id.mat');

aC = [pv; som; fs; pc; nongrouped];
nPv = length(pv);
nSom = length(som);

Lratio = [LratioWM(1:nPv); LratioCC(tag.nspv)];

nC_lr = sum(~isnan(Lratio))
nanmean(Lratio)
std(Lratio) / sqrt(nC_lr)

Lratio = [LratioWM(nPv+(1:nSom)); LratioCC(tag.nssom | tag.wssom)];

nC_lr = sum(~isnan(Lratio))
nanmean(Lratio)
std(Lratio) / sqrt(nC_lr)

ID = [IDWM(1:nPv); IDCC(tag.nspv)];

nC_ID = sum(~isnan(ID))
nanmean(ID)
nanstd(ID) / sqrt(nC_ID)

ID = [IDWM(nPv+(1:nSom)); IDCC(tag.nssom | tag.wssom)];

nC_ID = sum(~isnan(ID))
nanmean(ID)
nanstd(ID) / sqrt(nC_ID)