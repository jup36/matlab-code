%Single cell decoding
% Error trial 개수만큼 random하게 correct trial을 뽑고 나머지는 training set으로 사용
clc; clearvars; close all;
load('C:\users\lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat', 'nspv', 'nssom', 'wssom', 'fs', 'pc');
load('C:\users\lapis\OneDrive\git\matlab-code\WMIN-project\error_analysis\error_sessions.mat');

stat_test = 1; % 1: Bayesian decoding, 2: LDA

varName = {'single_bayes_03', 'single_bayes_01', 'single_bayes_12', 'single_bayes_23', 'single_lda_03', 'single_lda_01', 'single_lda_12', 'single_lda_23'};
stat_test = [1 1 1 1 2 2 2 2];
timeWindow = {[0 3000]; [0 1000]; [1000 2000]; [2000 3000]; [0 3000]; [0 1000]; [1000 2000]; [2000 3000]} ;
binWindow = [3000, 1000, 1000, 1000, 3000, 1000, 1000, 1000];
binStep = [3000, 1000, 1000, 1000, 3000, 1000, 1000, 1000];
nN = length(varName);

cells = {nspv, [nssom; wssom], fs, pc};
result.som.total = [result.nssom.total; result.wssom.total];
cellNm = {'nspv', 'som', 'fs', 'pc'};
nT = length(cellNm);
minTrial = 1;

stats.p = [];

for iN = 1:nN
    disp(['Start ', varName{iN}, ' analysis']);
    for iT = 1:nT
        trialSummary = result.(cellNm{iT}).total(:, [1 4 5 8]);
        Cs = find((trialSummary(:, 2) + trialSummary(:, 4)) >= minTrial)';
        nC = length(Cs);

        T(iN, iT).cellName = cells{iT}(Cs);
        T(iN, iT).trialSummary = trialSummary(Cs, :);
        
        spkData = cell(nC, 1);
        trialData = cell(nC, 1);
        for iC = 1:nC
            load([fileparts(T(iN, iT).cellName{iC}), '\Events.mat'], 'trialresult');
            load(T(iN, iT).cellName{iC}, 'spikeTime');
            [bin, spk] = spikeBin(spikeTime, timeWindow{iN}, binWindow(iN), binStep(iN));
            
            [spkTemp trialTemp] = deal(zeros(0, 1));
            for iP = [1:4; 1 2 1 2; 2 1 1 2]
                inTrial = trialresult(:, 1)==iP(2) & trialresult(:, 2)==iP(3) & trialresult(:, 4)==0;
                spkTemp = [spkTemp; spk(inTrial, :)];
                trialTemp = [trialTemp; iP(1)*ones(sum(inTrial), 1)];
            end
            spkData{iC} = spkTemp;
            trialData{iC} = trialTemp;
        end
        nB = length(bin);
        T(iN, iT).spk = spkData;
        T(iN, iT).trial = trialData;
        T(iN, iT).nTrial = cellfun(@length, trialData);
        T(iN, iT).nCell = nC;
    end
end
disp('Data set making done');
% T(stat_type, cell_type). nCell / spk

parfor iN = 1:nN
    disp(['Analyzing ', varName{iN}]);
    for iT = 1:nT
        decodeCell = cell(T(iN, iT).nCell, 4);
        for iC = 1:T(iN, iT).nCell 
            decodes = zeros(T(iN, iT).nTrial(iC), 1);
            
            % decoding error trial
            inTrial = T(iN, iT).trial{iC} <= 2;
            targetData = T(iN, iT).trial{iC}(inTrial);
            spkData = T(iN, iT).spk{iC}(inTrial);
            errData = T(iN, iT).spk{iC}(~inTrial);
            nTrial = sum(inTrial);
            
            outCell = std(spkData(targetData==1, :))==0 | std(spkData(targetData==2, :))==0;
            spkData(:, outCell) = [];
            if isempty(spkData); decodes = []; continue; end;
            
            try
                if stat_test(iN)==1
                    obj = fitcnb(spkData, T(iN, iT).trial{iC}(inTrial));
                else
                    obj = fitcdiscr(spkData, T(iN, iT).trial{iC}(inTrial), 'DiscrimType', 'diagLinear');
                end
                label = predict(obj, errData);
                decodes(~inTrial) = (label==(T(iN, iT).trial{iC}(~inTrial)-2));
            catch err
                decodes = [];
                disp(err.message);
            end
            
            for iTrial = 1:nTrial
                spkTrain = spkData([1:(iTrial-1) (iTrial+1):nTrial]');
                spkTest = spkData(iTrial);
                
                targetTrain = targetData([1:(iTrial-1) (iTrial+1):nTrial]');
                targetTest = targetData(iTrial);
                
                outCell = std(spkTrain(targetTrain==1, :))==0 | std(spkTrain(targetTrain==2, :))==0;
                spkTrain(:, outCell) = [];
                if isempty(spkTrain); decodes(iTrial) = NaN; continue; end;
                
                try
                    if stat_test(iN)==1
                        obj = fitcnb(spkTrain, targetTrain);
                    else
                        obj = fitcdiscr(spkTrain, targetTrain, 'DiscrimType', 'diagLinear');
                    end
                    label = predict(obj, spkTest);
                    decodes(iTrial) = (label==targetTest);
                catch err
                    decodes(iTrial) = NaN;
                    disp(err.message);
                end
            end
            
            for iP = 1:4
                decodeCell{iC, iP} = decodes(T(iN, iT).trial{iC} == iP);
            end
        end
        decodeResult{iN, iT} = decodeCell;
    end
end

for iN = 1:nN
    for iT = 1:nT
        T(iN, iT).performance = decodeResult{iN, iT};
    end
end

single_decoding = T;

save('error_decoding.mat', 'single_decoding', '-append');
        
