function statDelayReward
% This function calculates total significant duration of differential firing

% Variable to be used: pc, fs
load('D:\Cloud\project\workingmemory_interneuron\data\celllist_20150527.mat');

openSpikeFile(pc);
openSpikeFile(fs);

function openSpikeFile(mFL)
warning off;

binWindow = 500;
binStep = 100;

eFL = cellfun(@(x) [fileparts(x),'\Events.mat'], mFL, 'UniformOutput',false);

nC = length(mFL);
for iC = 1:nC
    clearvars index_mod;
    load(mFL{iC});
    load(eFL{iC});
    
    [reg_time, reg_spk] = spikeBin(spikeTime, window(5,:)*1000, binWindow, binStep);
    [regRw_time, regRw_spk] = spikeBin(spikeTimeRw, window(8,:)*1000, binWindow, binStep);
    
    inRegress = (trialresult(:,3)==1 & trialresult(:,4)==0);
    
    reg_spk = reg_spk(inRegress,:);
    regRw_spk = regRw_spk(inRegress,:);
    target = trialresult(inRegress,2);
    
    statDelay = slideStat(reg_time, reg_spk, target);
    statReward = slideStat(regRw_time, regRw_spk, target);
    save(mFL{iC}, 'statDelay', 'statReward', '-append');
end

function stats = slideStat(time, spk, group)
nBin = length(time);
p_ranksum = zeros(1, nBin);
p_ttest = zeros(1, nBin);

for iBin = 1:nBin
    p_ranksum(iBin) = ranksum(spk(group==1,iBin), spk(group==2,iBin));
    [~,p_ttest(iBin)] = ttest2(spk(group==1,iBin), spk(group==2,iBin));
end

stats = struct('time',time, 'p_ranksum',p_ranksum, 'p_ttest',p_ttest);