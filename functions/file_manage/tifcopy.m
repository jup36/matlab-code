clc; clearvars; close all;

startFolder = 'C:\CheetahData';
folderToMove = uigetdir(startFolder, 'Choose folders to move. All tif at files in subdirectory will be moved.');

targetStartFolder = 'C:\Users\lapis\Dropbox\Dohoung\reuniens_prelimbic_project\data\';
targetFolder = uigetdir(targetStartFolder, 'Choose folder where selected files will be moved.');

cellList = FindFiles('*.tif','StartingDirectory',folderToMove, 'CheckSubdirs', true);
nC = length(cellList);

prevdir = '';
for iCell = 1:nC
    [cellDir, cellNm,~] = fileparts(cellList{iCell});
    
    newCellDir = strrep(cellDir, folderToMove, targetFolder);
    
    if ~strcmp(prevdir,newCellDir)
        mkdir(newCellDir);
    end
    copyfile(cellList{iCell},newCellDir);
    prevdir = newCellDir;
end