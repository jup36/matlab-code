% parfor test
% iL=1: contralateral cue, iL=2: ipsilateral cue
clc; clearvars; close all;
tic;
load('C:\users\lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat', 'nspv', 'nssom', 'wssom', 'fs', 'pc');
load('C:\users\lapis\OneDrive\git\matlab-code\WMIN-project\error_analysis\error_sessions.mat');

stat_test = 2; % 1: Bayesian decoding, 2: LDA
statName = {'bayes', 'lda'};
timeWindow = [3000 4000]; % in ms
binWindow = timeWindow(2) - timeWindow(1);
binStep = binWindow;
nTest = 1;
nTrain = 10;
nIter = 100;
frThres = 0.5;

cells = {nspv, [nssom; wssom], fs, pc};
cellNm = {'nspv', 'som', 'fs', 'pc'};
nT = length(cellNm);
for iT = 1:nT
    trialSummary = result.(cellNm{iT}).total(:,[1 4 5 8]);
    
%     LRreverse = ~cellfun(@isempty, strfind(cells{iT}, 'PV36')) | ~cellfun(@isempty, strfind(cells{iT}, 'Sst10'));
%     trialSummary(LRreverse, :) = trialSummary(LRreverse, [3 4 1 2]);
    
    fr = result.(cellNm{iT}).fr;
    for iL = 1:2
        if iL == 1
            Cs = find(trialSummary(:,1)>=(nTrain+nTest) & trialSummary(:,3)>=nTrain & trialSummary(:,2)>=nTest & fr>=frThres);
        else
            Cs = find(trialSummary(:,1)>=nTrain & trialSummary(:,3)>=(nTrain+nTest) & trialSummary(:,4)>=nTest & fr>=frThres);
        end
        nC = length(Cs);
        
        T(iT, iL).cellName = cells{iT}(Cs);
        T(iT, iL).trialSummary = trialSummary(Cs,:);
        
        spkData = cell(nC, 3);
        for iC = 1:nC
            load([fileparts(T(iT, iL).cellName{iC}),'\Events.mat'], 'trialresult');
            load(T(iT, iL).cellName{iC}, 'spikeTime');
            [bin, spk] = spikeBin(spikeTime, timeWindow, binWindow, binStep);
            
            for iP = [1:3; iL (3-iL) iL; (3-iL) iL iL] % contra>ipsi, ipsi>contra, contra>contra
%                 if (~isempty(strfind(T(iT, iL).cellName{iC},'PV36')) || ~isempty(strfind(T(iT, iL).cellName{iC},'Sst10')))
%                     inTrial = trialresult(:, 1)==(3-iP(2)) & trialresult(:,2)==(3-iP(3)) & trialresult(:,4)==0;
%                 else
                    inTrial = trialresult(:, 1)==iP(2) & trialresult(:,2)==iP(3) & trialresult(:,4)==0;
%                 end
                spkData{iC, iP(1)} = spk(inTrial, :);
            end
        end
        nB = length(bin);
        T(iT, iL).spk = spkData;
        T(iT, iL).nCell = nC;
    end
end
disp('Data set done');

% parpool(3);

parfor iI = 1:nIter
    disp(['Iteration: ', num2str(iI)]);
    performance = repmat({}, 4, 2);
    for iT = 1:4
        for iL = 1:2 
            decodingResult = zeros(2*nTest, T(iT, iL).nCell);
            for iC = 1:T(iT, iL).nCell
                spkSubgroup = T(iT,iL).spk(randperm(T(iT, iL).nCell, iC), :);
                spkSample = cell2mat(cellfun(@(x, y) datasample(x, y, 'Replace', false), spkSubgroup, repmat([{nTrain+nTest} {nTrain} {nTest}], iC, 1), 'UniformOutput', false)');
                
                spkTrain = spkSample([1:nTrain, (1:nTrain) + (nTrain+nTest)], :);
                spkTest = spkSample([(1:nTest)+nTrain, (1:nTest)+(2*nTrain+nTest)], :);
                
                outCell = std(spkTrain(1:nTrain,:))==0 | std(spkTrain((1+nTrain):(2*nTrain),:))==0;
                spkTrain(:, outCell) = [];
                spkTest(:,outCell) = [];
                
                try
                    if stat_test==1
                        obj = fitcnb(spkTrain, [iL*ones(nTrain, 1); (3-iL)*ones(nTrain, 1)]);
                        [label, score] = predict(obj, spkTest);
                    else
                        label = classify(spkTest, spkTrain, [iL*ones(nTrain, 1); (3-iL)*ones(nTrain, 1)], 'diaglinear');
                    end
                    decodingResult(:, iC) = label==(iL*ones(2*nTest, 1));
                catch err
                    decodingResult(:, iC) = NaN;
                    disp(err.message);
                end
            end
            performance{iT, iL} = decodingResult;
        end 
    end
    pC11(iI, :) = performance{1, 1}(1, :);
    pC12(iI, :) = performance{1, 2}(1, :);
    pC21(iI, :) = performance{2, 1}(1, :);
    pC22(iI, :) = performance{2, 2}(1, :);
    pC31(iI, :) = performance{3, 1}(1, :);
    pC32(iI, :) = performance{3, 2}(1, :);
    pC41(iI, :) = performance{4, 1}(1, :);
    pC42(iI, :) = performance{4, 2}(1, :);
    
    pE11(iI, :) = performance{1, 1}(2, :);
    pE12(iI, :) = performance{1, 2}(2, :);
    pE21(iI, :) = performance{2, 1}(2, :);
    pE22(iI, :) = performance{2, 2}(2, :);
    pE31(iI, :) = performance{3, 1}(2, :);
    pE32(iI, :) = performance{3, 2}(2, :);
    pE41(iI, :) = performance{4, 1}(2, :);
    pE42(iI, :) = performance{4, 2}(2, :);
end

T(1, 1).performance.correct = pC11;
T(1, 2).performance.correct = pC12;
T(2, 1).performance.correct = pC21;
T(2, 2).performance.correct = pC22;
T(3, 1).performance.correct = pC31;
T(3, 2).performance.correct = pC32;
T(4, 1).performance.correct = pC41;
T(4, 2).performance.correct = pC42;

T(1, 1).performance.error = pE11;
T(1, 2).performance.error = pE12;
T(2, 1).performance.error = pE21;
T(2, 2).performance.error = pE22;
T(3, 1).performance.error = pE31;
T(3, 2).performance.error = pE32;
T(4, 1).performance.error = pE41;
T(4, 2).performance.error = pE42;

eval(['T_', statName{stat_test},'_', num2str(timeWindow(1)/1000, 1), num2str(timeWindow(2)/1000, 1),'_fr05_lr = T;']);
save('error_decoding.mat', ['T_', statName{stat_test},'_', num2str(timeWindow(1)/1000, 1), num2str(timeWindow(2)/1000, 1),'_fr05_lr'], '-append');
toc;