function error_sessions()
% total / error sessions
load('C:\users\lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat');

result.nspv = loadEvent(nspv);
result.nssom = loadEvent(nssom);
result.wssom = loadEvent(wssom);
result.pc = loadEvent(pc);
result.fs = loadEvent(fs);

save('error_sessions.mat', 'result');


function result = loadEvent(celllist)
cellDir = cellfun(@fileparts, celllist, 'UniformOutput', false);
eMat = cellfun(@(x) [x, '\Events.mat'], cellDir, 'UniformOutput', false);
% eMat = unique(eMat);

nS = length(eMat);
result.total = zeros(nS, 24);
result.summary = zeros(nS, 3);
for iS = 1:nS
    load(eMat{iS}, 'trialresult');
    target = trialresult(:,1);
    choice = trialresult(:,2);
    reward = trialresult(:,3);
    modulation = trialresult(:,4);
    
    idx = 0;
    for iM = 0:2
        for iT = 1:2
            for iC = [3-iT iT]
                for iR = 1:-1:0
                    idx = idx + 1;
                    result.total(iS, idx) = sum((target==iT) & (choice==iC) & (reward==iR) & (modulation==iM));
                end
            end
        end
    end    
end
result.summary(:, 1) = result.total(:, 1) + result.total(:,5);
result.summary(:, 2) = result.total(:, 4) + result.total(:,8);
result.summary(:, 3) = result.total(:, 2) + result.total(:,6);

% LR rewarded / LR omission / LL rewarded / LL unrewarded
% RL rewarded / RL omission / RR rewarded / RR unrewarded