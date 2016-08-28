% target specificity during trial start, sample period, reward period
clc; clearvars; close all;

%% variable
% global MClust_ClusterSeparationFeatures
ChannelValidity = [1 1 1 1];

%% load cell data
load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');
aC = T.cellList;

predir = 'C:\\Users\\Lapis\\OneDrive\\project\\classical_conditioning\\data\\';
curdir = 'D:\\Cheetah_data\\classical_conditioning\\';
mFile = cellfun(@(x) regexprep(x,predir,curdir), aC, 'UniformOutput', false);

[mFolder, mFileName] = cellfun(@(x) fileparts(x), mFile, 'UniformOutput', false);
ttName = cellfun(@(x) strsplit(x, '_'), mFileName, 'UniformOutput', false);

nC = length(aC);
[Lratio, ID] = deal(zeros(nC, 1));
for iC = 1:nC
    disp(iC);
    load([mFolder{iC}, '\', ttName{iC}{1}, '.clusters'], 'MClust_Clusters', '-mat');
    cellIdx = FindInCluster(MClust_Clusters{str2num(ttName{iC}{2})});
    nttName = [mFolder{iC}, '\', ttName{iC}{1}, '.ntt'];
    [~, Lratio(iC), ID(iC)] = ClusterSeparation(cellIdx, nttName, ChannelValidity); 
end

nC_lr = sum(~isnan(Lratio));
nanmean(Lratio)
std(Lratio) / sqrt(nC_lr)

nC_ID = sum(~isnan(ID));
nanmean(ID)
nanstd(ID) / sqrt(nC_ID)

LratioCC = Lratio;
IDCC = ID;
save('method_calc_Lratio_id.mat', 'LratioCC', 'IDCC', '-append');