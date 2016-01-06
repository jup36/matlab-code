% This m file plots all pv and som cells using color map (imagesc). Peak firing rate will be used to align cells.

rtdir = pwd;

% Variable nspv, nssom, and wssom will be used.
load('D:\Cloud\project\workingmemory_interneuron\data\celllist_20150527.mat');

% 1. Find out whether each cell is right or left preferring

cellList = nspv;

nC = length(cellList);
for iC = 1
    clearvars peth_modconv;
    load(cellLIst{iC});  
end
    