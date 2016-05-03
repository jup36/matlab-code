% error decoding
clc; clearvars; close all;
load('C:\users\lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat', 'nspv', 'nssom', 'wssom', 'fs', 'pc');
load('C:\users\lapis\OneDrive\git\matlab-code\WMIN-project\error_analysis\error_sessions.mat');

stat_test = 2;
timeWindow = [2000 3000];
binWindow = timeWindow(2) - timeWindow(1);
binStep = binWindow;
nTest = 1;
nTrain = 20 - nTest;
nIter = 100;

cells = {nspv, [nssom; wssom], fs, pc};
result.som.total = [result.nssom.total; result.wssom.total];
cellNm = {'nspv', 'som', 'fs', 'pc'};
nT = length(cellNm);
groupTrain = [ones(nTrain, 1); 2*ones(nTrain, 1)];
groupTest = [ones(2*nTest, 1); 2*ones(2*nTest, 1)];

for iT = 1:4
    T = table();
    trialSummary =result.(cellNm{iT}).total(:,[1 4 5 8]);
    Cs = find(trialSummary(:,1)>=(nTrain+nTest) & trialSummary(:,3)>=(nTrain+nTest) & trialSummary(:,2)>=nTest & trialSummary(:,4)>=nTest);
    nC = length(Cs);
    
    T.cellName = cells{iT}(Cs);
    T.trialSummary = trialSummary(Cs,:);
    
    spkData = cell(nC, 4);
    for iC = 1:nC
        load([fileparts(T.cellName{iC}),'\Events.mat'], 'trialresult');
        load(T.cellName{iC}, 'spikeTime');
        [bin, spk] = spikeBin(spikeTime, timeWindow, binWindow, binStep);
        
        index = 0;
        for iP = 1:2
            for iF = [3-iP iP]
                index = index + 1;
                inTrial = trialresult(:, 1)==iP & trialresult(:,2)==iF & trialresult(:,4)==0;
                spkData{iC, index} = spk(inTrial, :);
            end
        end
    end
    nB = length(bin);
    T.spk = spkData;
    
    performanceCorrect = zeros(nIter, nC);
    performanceError = zeros(nIter, nC);
    for iI = 1:nIter
        disp(['Iteration: ', num2str(iI)]);
        decodingResult = zeros(4*nTest, nC);
        for jC = 1:nC
            spkSubgroup = T.spk(randperm(nC, jC), :);
            spkSample = cell2mat(cellfun(@(x, y) datasample(x, y, 'Replace', false), spkSubgroup, repmat([{nTrain+nTest} {nTest}], jC, 2), 'UniformOutput', false)');
            
            spkTest = spkSample([(1+nTrain):(nTrain+2*nTest) (1+2*nTrain+2*nTest):end], :);
            spkTrain = spkSample([1:nTrain (1+nTrain+2*nTest):(2*nTrain+2*nTest)], :);
            
            outCell = std(spkTrain(groupTrain == 1,:))==0 | std(spkTrain(groupTrain == 2,:))==0;
            spkTrain(:, outCell) = [];
            
            spkTest = spkTest(:,~outCell);
            
            try
                if stat_test==1
                    obj = fitcnb(spkTrain, groupTrain);
                    [label, score] = predict(obj, spkTest);
                else
                    label = classify(spkTest, spkTrain, groupTrain, 'diaglinear');
                end
                
                decodingResult(:, jC) = label==groupTest;
            catch err
                decodingResult(:, jC) = NaN;
                disp(err.message);
            end
        end
        performanceCorrect(iI, :) = nanmean(decodingResult([1:nTest (1+2*nTest):(3*nTest)], :));
        performanceError(iI, :) = nanmean(decodingResult([(1+nTest):(2*nTest) (1+3*nTest):end], :));
    end
    
    dropResult_lda_23.(cellNm{iT}).nCell = nC;
    dropResult_lda_23.(cellNm{iT}).performance.correct = performanceCorrect;
    dropResult_lda_23.(cellNm{iT}).performance.error = performanceError;
end

save('cell_drop_1_19.mat', 'dropResult_lda_23', '-append');