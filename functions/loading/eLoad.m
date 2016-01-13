function [eData eList] = eLoad(eFile)
%eLoad loads Events.new files
%
%   eData(n).t: time stamp of event in milliseconds
%   eData(n).s: string content of the event
%   eList: list of Events.nev files
%
%   Author: Dohoung Kim
%   Version 1.0 (2016/1/13)
%
%   Requires Nlx2MatEV.m and Nlx2MatEV.mex64 files
%   You should download 'Neuralynx_Matlab_Import_Export' toolbox from Neuralynx homepage.
%   http://neuralynx.com/software/NeuralynxMatlabImportExport_v6.0.0.zip

% Make lists of event files
narginchk(0, 3);
if nargin == 0
    eList = FindFiles('Events.nev','CheckSubdirs',0);
elseif nargin >= 1
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        eList = FindFiles('Events.nev','CheckSubdirs',0);
    else
        nFolder = length(sessionFolder);
        eList = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder},'dir')
                cd(sessionFolder{iFolder});
                eList = [eList;FindFiles('Events.nev','CheckSubdirs',1)];
            end
        end
    end
end
if isempty(eList)
    disp('Event file does not exist!');
    return;
end

nE = length(eList);

for iE = 1:nE
    [timeStamp eventString] = Nlx2MatEV(eList{iE}, [1 0 0 0 1], 0, 1, []);
    timeStamp = timeStamp'/1000;
    
    eData(iE).t = timeStamp;
    eData(iE).s = eventString;
end