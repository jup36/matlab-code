function tagstatCC(sessionFolder)
%tagstatCC calculates statistical significance using log-rank test

% Variables
dt = 0.2;
testRangeBlue = 5; % unit: ms
baseRangeBlue = [-400 0]; % baseline
testRangeRed = 400;
baseRangeRed = [-4000 0];

testRangeRedOnset = 20;
baseRangeRedOnset = [-4000 0];

testRangeRedOffset = 20;
baseRangeRedOffset = [-4500 -520];

% Find files
if nargin == 0; sessionFolder = {}; end;
[tData, tList] = tLoad(sessionFolder);
if isempty(tList); return; end;

nCell = length(tList);
for iCell = 1:nCell
    disp(['### Tag stat test: ',tList{iCell}]);
    [cellPath,cellName,~] = fileparts(tList{iCell});
    cd(cellPath);
    
    clear blueOnsetTime redOnsetTime
    load('Events.mat','blueOnsetTime','redOnsetTime', 'redOffsetTime');
    spikeData = tData{iCell};
    
    [timeBlue, censorBlue] = tagDataLoad(spikeData, blueOnsetTime, testRangeBlue, baseRangeBlue);
    [timeRed, censorRed] = tagDataLoad(spikeData, redOnsetTime, testRangeRed, baseRangeRed);
    [timeRedOnset, censorRedOnset] = tagDataLoad(spikeData, redOnsetTime, testRangeRedOnset, baseRangeRedOnset);
    [timeRedOffset, censorRedOffset] = tagDataLoad(spikeData, redOffsetTime, testRangeRedOffset, baseRangeRedOffset);
    
    [p_tagBlue,time_tagBlue,H1_tagBlue,H2_tagBlue] = logRankTest(timeBlue, censorBlue);
    save([cellName,'.mat'],...
        'p_tagBlue','time_tagBlue','H1_tagBlue','H2_tagBlue',...
        '-append');
    
    [p_saltBlue, l_saltBlue] = saltTest(timeBlue, testRangeBlue, dt);
    save([cellName,'.mat'],...
        'p_saltBlue','l_saltBlue',...
        '-append');
    
    [p_tagRed,time_tagRed,H1_tagRed,H2_tagRed] = logRankTest(timeRed, censorRed);
    save([cellName,'.mat'],...
        'p_tagRed','time_tagRed','H1_tagRed','H2_tagRed',...
        '-append');
    
    [p_tagRedOnset,time_tagRedOnset,H1_tagRedOnset,H2_tagRedOnset] = logRankTest(timeRedOnset, censorRedOnset);
    save([cellName,'.mat'],...
        'p_tagRedOnset','time_tagRedOnset','H1_tagRedOnset','H2_tagRedOnset',...
        '-append');
    
    [p_saltRedOnset, l_saltRedOnset] = saltTest(timeRedOnset, testRangeRedOnset, dt);
    save([cellName,'.mat'],...
        'p_saltRedOnset','l_saltRedOnset',...
        '-append');
    
    [p_tagRedOffset,time_tagRedOffset,H1_tagRedOffset,H2_tagRedOffset] = logRankTest(timeRedOffset, censorRedOffset);
    save([cellName,'.mat'],...
        'p_tagRedOffset','time_tagRedOffset','H1_tagRedOffset','H2_tagRedOffset',...
        '-append');
end
disp('### Tag stat test done!');

function [time, censor] = tagDataLoad(spikeData, onsetTime, testRange, baseRange)
%tagDataLoad makes dataset for statistical tests
%   spikeData: raw data from MClust t file (in msec)
%   onsetTime: time of light stimulation (in msec)
%   testRange: binning time range for test (in msec)
%   baseRange: binning time range for baseline --> [startTime endTime] (in msec)
%
%   time: nBin (nBin-1 number of baselines and 1 test) x nLightTrial
%
narginchk(4,4);
if isempty(onsetTime); time = []; censor = []; return; end;

% If onsetTime interval is shorter than test+baseline range, omit.
outBin = find(diff(onsetTime)<=(testRange-baseRange(1)));
outBin = [outBin;outBin+1];
onsetTime(outBin(:))=[];
if isempty(onsetTime); time = []; censor = []; return; end;
nLight = length(onsetTime);

% Rearrange data
bin = [ceil(baseRange(1)/testRange)*testRange:testRange:floor(baseRange(2)/testRange)];
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

function [p,time,H1,H2] = logRankTest(time, censor)
%logRankTest makes dataset for log-rank test

if isempty(time) || isempty(censor); p = []; time = []; H1 = []; H2 = []; return; end;

base = [reshape(time(1:(end-1),:),1,[]);reshape(censor(1:(end-1),:),1,[])]';
test = [time(end,:);censor(end,:)]';

[p,time,H1,H2] = logrank(test,base);

function [p, l] = saltTest(time, wn, dt)
if isempty(time) ; p = []; l= []; return; end;

base = time(1:(end-1),:)';
test = time(end,:)';

[p, l] = salt2(test, base, wn, dt);