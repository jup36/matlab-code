function runBackup(backuplist)
nS = size(backuplist, 1);
sync = strcmp(backuplist(:, 2), 'Sync');
renameFiles = strcmp(backuplist(:, 3), 'Rename old file');
sourcePaths = backuplist(:, 4);
targetPaths = backuplist(:, 5);

for iS = 1:nS
    extension = strsplit(backuplist{iS, 6}, {',',';'});
    nExt = length(extension);
    
    for iE = 1:nExt
        if ~isempty(extension{iE})
            copyFiles(sourcePaths{iS}, targetPaths{iS},  extension{iE}, renameFiles(iS), sync(iS));
            if sync(iS)
                copyFiles(targetPaths{iS}, sourcePaths{iS}, extension{iE}, renameFiles(iS), sync(iS)+1);
            end
        end
    end
end
msgbox('Finished!');


function [fileList, fileTime] = fileFinder(startingFolder, extension)
%% FILEFINDER finds all files in starting folders and subfolders
% Dohoung Kim, 2017-03-31

if nargin==0
    startingFolder = pwd;
    extension = '*.*';
end

currentFile = struct2table(dir(startingFolder));
if isempty(currentFile)
    fileList = {};
    fileTime = {};
    return;
elseif iscell(currentFile.folder)
    fullName = cellfun(@(x, y) fullfile(x, y), currentFile.folder, currentFile.name, 'UniformOutput', false);
elseif ischar(currentFile.folder)
    fullName = fullfile(currentFile.folder, currentFile.name);
end

fileTime = currentFile.datenum(~currentFile.isdir);
fileList = fullName(~currentFile.isdir);
folderList = fullName(currentFile.isdir & ~strcmp(currentFile.name, '.') & ~strcmp(currentFile.name, '..'));
nF = length(folderList);

if nF > 0
    for iF = 1:nF
        [subFileList, subFileTime] = fileFinder(folderList{iF}, extension);
        fileList = [fileList; subFileList];
        fileTime = [fileTime; subFileTime];
    end
end

[~, ~, extensionList] = cellfun(@fileparts, fileList, 'UniformOutput', false);
[~, ~, extensionExtension] = fileparts(extension);
extensionIndex = strcmp(extensionList, extensionExtension);

fileList = fileList(extensionIndex);
fileTime = fileTime(extensionIndex);


function copyFiles(sourcePath, targetPath, extension, renameFiles, sync)

stopCopy = false;
[sourceFileList, sourceFileTime] = fileFinder(sourcePath, extension);
[targetFileList, targetFileTime] = fileFinder(targetPath, extension);
nFile = length(sourceFileList);

newTargetFileList = strrep(sourceFileList, sourcePath, targetPath);
[overlapSourceIndex, overlapSourceLoc] = ismember(newTargetFileList, targetFileList);

copyIndex = zeros(nFile, 1);
copyIndex(~overlapSourceIndex) = 1;

isNewFile = sourceFileTime(overlapSourceIndex) - targetFileTime(overlapSourceLoc(overlapSourceIndex)) > 0;    
copyIndex(overlapSourceIndex) = isNewFile*2;

overwrite = 'No';
hWait = waitbar(0, 'Start copying...', 'Name', 'Copying...');
for iFile = 1:nFile
    if sync==0
        waitbar(iFile/nFile, hWait, [num2str(iFile),' / ',num2str(nFile),' files copied.']);
    elseif sync==1
        waitbar(iFile/nFile/2, hWait, [num2str(iFile),' / ',num2str(nFile),' files copied.']);
    elseif sync==2
        waitbar((iFile+nFile)/nFile/2, hWait, [num2str(iFile),' / ',num2str(nFile),' files copied.']);
    end
    if copyIndex(iFile)==1
        targetDir = fileparts(newTargetFileList{iFile});
        if ~exist(targetDir, 'dir')
            mkdir(targetDir);
        end
        copyfile(sourceFileList{iFile}, targetDir);
    elseif copyIndex(iFile)==2
        targetDir = fileparts(newTargetFileList{iFile});
        if ~exist(targetDir, 'dir')
            mkdir(targetDir);
        end
        if renameFiles
            movefile(newTargetFileList{iFile}, [newTargetFileList{iFile},'.bak']);
            copyfile(sourceFileList{iFile}, targetDir);
        else
            if strcmp(overwrite, 'Yes to all')
                copyfile(sourceFileList{iFile}, targetDir);
            else
                overwrite = questdlg('Overwrite on existing file?', 'Warning', 'Yes to all', 'No', 'No');
                if strcmp(overwrite, 'Yes to all')
                    copyfile(sourceFileList{iFile}, targetDir);
                end
            end
        end
    end
end
delete(hWait);