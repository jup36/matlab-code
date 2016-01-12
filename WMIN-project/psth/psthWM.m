function psthWM
load('D:\Cloud\project\workingmemory_interneuron\data\celllist_20150527.mat');

addSpike(pc);
addSpike(fs);


function addSpike(mFileList)
predir = 'D:\\Cloud\\project\\workingmemory_interneuron\\data\\';
curdir = 'D:\\Cheetah_data\\workingmemory_interneuron\\';
tFL = cellfun(@(x) regexprep(x,predir,curdir),mFileList,'UniformOutput',false);

preext = '.mat';
curext = '.t';
tFL = cellfun(@(x) regexprep(x,preext,curext), tFL, 'UniformOutput',false);
tSP = LoadSpikes(tFL, 'tsflag','ts', 'verbose',0);

eFL = cellfun(@(x) [fileparts(x),'\Events.mat'], mFileList, 'UniformOutput',false);


nC = length(mFileList);
for iC = 1:nC
    load(eFL{iC});
    delayWin = [-1 4]*10^3;
    rewardWin = [-2 10]*10^3;
    
    spikeData = Data(tSP{iC})/10;
    spikeTime = spikeWin(spikeData, eventtime(:,5)/10, delayWin);
    spikeTimeRw = spikeWin(spikeData, eventtime(:,8)/10, rewardWin);

    save(mFileList{iC}, ...
        'spikeTime', 'spikeTimeRw', '-append');
end