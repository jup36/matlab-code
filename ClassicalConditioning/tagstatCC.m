function tagstatCC(sessionFolder)
%tagstatCC calculates statistical significance using log-rank test

% Variables
testRangeBlue = 10; % unit: ms
baseRangeBlue = 400; % baseline
testRangeRed = 100;
baseRangeRed = 4000;

% Find files
if nargin == 0
    ttFile = FindFiles('T*.t','CheckSubdirs',0); 
else
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        ttFile = FindFiles('T*.t','CheckSubdirs',1);
    else
        nFolder = length(sessionFolder);
        ttFile = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder})==7 
                cd(sessionFolder{iFolder});
                ttFile = [ttFile;FindFiles('T*.t','CheckSubdirs',1)];
            elseif strcmp(sessionFolder{iFolder}(end-1:end),'.t') 
                ttFile = [ttFile;sessionFolder{iFolder}];
            end
        end
    end
end
if isempty(ttFile)
    disp('TT file does not exist!');
    return;
end
ttData = LoadSpikes(ttFile,'tsflag','ts','verbose',0);

nCell = length(ttFile);
for iCell = 1:nCell
    disp(['### Log-rank test: ',ttFile{iCell}]);
    [cellPath,cellName,~] = fileparts(ttFile{iCell});
    cd(cellPath);
    
    clear blueOnsetTime redOnsetTime
    load('Events.mat','blueOnsetTime','redOnsetTime');
    spikeData = Data(ttData{iCell})/10;
    
    [p_tagBlue,time_tagBlue,H1_tagBlue,H2_tagBlue] = logRankTest(spikeData, blueOnsetTime, testRangeBlue, baseRangeBlue);
    save([cellName,'.mat'],...
        'p_tagBlue','time_tagBlue','H1_tagBlue','H2_tagBlue',...
        '-append');
    
    [p_tagRed,time_tagRed,H1_tagRed,H2_tagRed] = logRankTest(spikeData, redOnsetTime, testRangeRed, baseRangeRed);
    save([cellName,'.mat'],...
        'p_tagRed','time_tagRed','H1_tagRed','H2_tagRed',...
        '-append');
end
disp('### Log-rank test done!');

function [p,time,H1,H2] = logRankTest(spikeData, onsetTime, testRange, baseRange)
%logRankTest makes dataset for log-rank test
%   spikeData: raw data from MClust t file (in msec)
%   onsetTime: time of light stimulation (in msec)
%   testRange: binning time range for test (in msec)
%   baseRange: binning time range for baseline (in msec)
narginchk(4,4);
if isempty(onsetTime); p = []; time = []; H1 = []; H2 = []; return; end;

% if onsetTime interval is shorter than test+baseline range, omit.
outBin = find(diff(onsetTime)<=(testRange+baseRange));
outBin = [outBin;outBin+1];
onsetTime(outBin(:))=[];
if isempty(onsetTime); p = []; time = []; H1 = []; H2 = []; return; end;
nLight = length(onsetTime);

bin = [-floor(baseRange/testRange):testRange:0];
nBin = length(bin);

binMat = ones(nLight,nBin)*diag(bin);
lightBin = (repmat(onsetTime',nBin,1)+binMat');
time = zeros(nBin,nLight);
censor = zeros(nBin,nLight);

for iLight=1:nLight
    for iBin=1:nBin
        idx = find(spikeData > lightBin(iBin,iLight), 1, 'first');
        if isempty(idx)
            time(iBin,iLight) = testRange;
            censor(iBin,iLight) = 1;
        else
            time(iBin,iLight) = spikeData(idx) - lightBin(iBin,iLight);
            if time(iBin,iLight) > testRange
                time(iBin,iLight) = testRange;
                censor(iBin,iLight) = 1;
            end
        end     
    end
end
base = [reshape(time(1:nBin,:),1,[]);reshape(censor(1:nBin,:),1,[])]';
test = [time(end,:);censor(end,:)]';

[p,time,H1,H2] = logrank(test,base);