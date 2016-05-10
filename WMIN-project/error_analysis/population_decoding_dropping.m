% error decoding
clc; clearvars; close all;
load('C:\users\lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat', 'nspv', 'nssom', 'wssom', 'fs', 'pc');
load('C:\users\lapis\OneDrive\git\matlab-code\WMIN-project\error_analysis\error_sessions.mat');

stat_test = 1; % 1: Bayesian decoding, 2: LDA
timeWindow = [0000 1000]; % in ms
binWindow = timeWindow(2) - timeWindow(1);
binStep = binWindow;
nTest = 1;
nTrain = 10;
nIter = 100;

cells = {nspv, [nssom; wssom], fs, pc};
result.som.total = [result.nssom.total; result.wssom.total];
cellNm = {'nspv', 'som', 'fs', 'pc'};
nT = length(cellNm);
% groupTest = [ones(2*nTest, 1); 2*ones(2*nTest, 1)];

T01 = struct;
for iT = 1:4
    trialSummary = result.(cellNm{iT}).total(:,[1 4 5 8]);
    
    for iL = 1:2
        if iL == 1
            Cs = find(trialSummary(:,1)>=(nTrain+nTest) & trialSummary(:,3)>=nTrain & trialSummary(:,2)>=nTest);
        else
            Cs = find(trialSummary(:,1)>=nTrain & trialSummary(:,3)>=(nTrain+nTest) & trialSummary(:,4)>=nTest);
        end
        nC = length(Cs);
        
        T01(iT, iL).cellName = cells{iT}(Cs);
        T01(iT, iL).trialSummary = trialSummary(Cs,:);
        
        spkData = cell(nC, 3);
        for iC = 1:nC
            load([fileparts(T01(iT, iL).cellName{iC}),'\Events.mat'], 'trialresult');
            load(T01(iT, iL).cellName{iC}, 'spikeTime');
            [bin, spk] = spikeBin(spikeTime, timeWindow, binWindow, binStep);
            
            for iP = [1:3; iL (3-iL) iL; (3-iL) iL iL]
                inTrial = trialresult(:, 1)==iP(2) & trialresult(:,2)==iP(3) & trialresult(:,4)==0;
                spkData{iC, iP(1)} = spk(inTrial, :);
            end
        end
        nB = length(bin);
        T01(iT, iL).spk = spkData;
        
        performanceCorrect = zeros(nIter, nC);
        performanceError = zeros(nIter, nC);
        for iI = 1:nIter
            disp(['Cell type: ', cellNm{iT}, ', Cue: ', num2str(iL), ', Iteration: ', num2str(iI)]);
            decodingResult = zeros(2*nTest, nC);
            for jC = 1:nC
                spkSubgroup = T01(iT, iL).spk(randperm(nC, jC), :);
                spkSample = cell2mat(cellfun(@(x, y) datasample(x, y, 'Replace', false), spkSubgroup, repmat([{nTrain+nTest} {nTrain} {nTest}], jC, 1), 'UniformOutput', false)');
                
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
                    decodingResult(:, jC) = label==(iL*ones(2*nTest, 1));
                catch err
                    decodingResult(:, jC) = NaN;
                    disp(err.message);
                end
            end
            performanceCorrect(iI, :) = nanmean(decodingResult(1:nTest, :), 1);
            performanceError(iI, :) = nanmean(decodingResult((1:nTest)+nTest, :), 1);
        end
        T01(iT, iL).nCell = nC;
        T01(iT, iL).performance.correct = performanceCorrect;
        T01(iT, iL).performance.error = performanceError;
    end
end

save('error_decoding.mat', 'T01', '-append');