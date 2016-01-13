function mList = mLoad(tFile)
%mLoad loads T*.mat files
%
%   mList: lists of TT*.mat files
%
%   Author: Dohoung Kim
%   Version 1.0 (2016/1/13)
switch nargin
    case 0
        mList = FindFiles('T*.mat','CheckSubdirs',0); 
    case 1 
        if ~iscell(cellFolder) 
            disp('Input argument is wrong. It should be cell array.');
            return;
        elseif isempty(cellFolder)
            mList = FindFiles('T*.mat','CheckSubdirs',1);
        else
            nFolder = length(cellFolder);
            mList = cell(0,1);
            for iFolder = 1:nFolder
                if exist(cellFolder{iFolder})==7
                    cd(cellFolder{iFolder});
                    mList = [mList;FindFiles('T*.mat','CheckSubdirs',1)];
                elseif strcmp(cellFolder{iFolder}(end-3:end),'.mat')
                    mList = [mList;cellFolder{iFolder}];
                end
            end
        end
end
if isempty(mList)
    disp('Mat file does not exist!');
    return;
end