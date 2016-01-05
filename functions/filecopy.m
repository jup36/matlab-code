clc; clear all; close all;
startFolder = 'D:\Cheetah_data\classical_conditioning\PVCC1\';
sessionFolder = dir([startFolder,'*s3*']);
nSession = length(sessionFolder);

cellList = {};
for iSession = 1:nSession
    if sessionFolder(iSession).isdir
        cellList = [cellList; FindFiles('E*.nev','StartingDirectory',[startFolder,sessionFolder(iSession).name])];
        cellList = [cellList; FindFiles('E*.mat','StartingDirectory',[startFolder,sessionFolder(iSession).name])];
        cellList = [cellList; FindFiles('T*.mat','StartingDirectory',[startFolder,sessionFolder(iSession).name])];
    end
end
nCell = length(cellList);

prevdir = '';
for iCell = 1:nCell
    [celldir,cellnm,~] = fileparts(cellList{iCell});
    fder = strsplit(celldir,'\');
    nwdir = ['D:\Data\',fder{end-1},'\',fder{end},'\'];
    if ~strcmp(prevdir,celldir)
        mkdir(nwdir);
    end
    copyfile(cellList{iCell},nwdir);
    prevdir = celldir;
end