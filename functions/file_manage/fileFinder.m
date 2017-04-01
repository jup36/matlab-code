function [fileList, fileTime] = fileFinder(startingFolder)
%% FILEFINDER finds all files in starting folders and subfolders
% Dohoung Kim, 2017-03-31

if nargin==0
    startingFolder = pwd;
end

currentFile = struct2table(dir(startingFolder));
fullName = cellfun(@(x, y) fullfile(x, y), currentFile.folder, currentFile.name, 'UniformOutput', false);

fileTime = currentFile.datenum(~currentFile.isdir);
fileList = fullName(~currentFile.isdir);
folderList = fullName(currentFile.isdir & ~strcmp(currentFile.name, '.') & ~strcmp(currentFile.name, '..'));
nF = length(folderList);

if nF > 0
    for iF = 1:nF
        [subFileList, subFileTime] = fileFinder(folderList{iF});
        fileList = [fileList; subFileList];
        fileTime = [fileTime; subFileTime];
    end
end