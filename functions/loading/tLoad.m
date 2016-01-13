function [tData tList] = tLoad(tFile)
%tLoad searches t files and load data
%
%   tData: cell array. Timestamp of unit data is inside the cell array.
%   Units in millisecond.
%   tList: shows list of TTx_x.t files
%
%   Author: Dohoung Kim
%   Version 1.0 (2016/1/13)
if nargin == 0
    tList = FindFiles('T*.t','CheckSubdirs',0); 
else
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        tList = FindFiles('T*.t','CheckSubdirs',1);
    else
        nFolder = length(sessionFolder);
        tList = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder})==7 
                cd(sessionFolder{iFolder});
                tList = [tList;FindFiles('T*.t','CheckSubdirs',1)];
            elseif strcmp(sessionFolder{iFolder}(end-1:end),'.t') 
                tList = [tList;sessionFolder{iFolder}];
            end
        end
    end
end
if isempty(tList)
    disp('t file does not exist!');
    return;
end
tLoad = LoadSpikes(tList,'tsflag','ts','verbose',0);

nT = length(tList);
tData = cell(nT,1);
for iT = 1:nT
    tData{iT} = Data(tLoad{iT})/10;
end