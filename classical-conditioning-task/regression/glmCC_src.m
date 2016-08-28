%% glm for head-fixed mice
clc; clearvars; close all; warning off;

%% Variables
winSize = 100;
winStep = {-200:winSize:200; ...
    -200:winSize:1700; ...
    -200:winSize:1700; ...
    -200:winSize:1700; ...
    -200:winSize:1700; ...
    -200:winSize:2200; ...
    -200:winSize:2200; ...
    -200:winSize:2200; ...
    -200:winSize:2200; ...
    -600:winSize:1400; ...
    -600:winSize:2900; ...
    -600:winSize:7900;};
nWinBin = cellfun(@length, winStep);
nVar = 1+4+2+2+3;
varName = {'Prep cue', 'Cue A', 'Cue B', 'Cue C', 'Cue D', ...
    'Reward', 'Non-reward', 'Punishment', 'Non-punishment', ...
    'Mid-bout lick', 'Lick onset', 'Lick offset'};

%% Load cell list
load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');
cellNm = {'nspv', 'nssom', 'wssom', 'fs', 'pc'};
tag.p = T.pLR < 0.01 & T.pSalt < 0.01;

tag.pv = tag.p & T.mouseLine=='PV';
tag.nspv = tag.p & T.mouseLine=='PV' & T.class == 1;
tag.som = tag.p & T.mouseLine=='SOM';
tag.nssom = tag.p & T.mouseLine=='SOM' & T.class == 1;
tag.wssom = tag.p & T.mouseLine=='SOM' & T.class == 2;
tag.fs = ~tag.p & T.class == 1;
tag.pc = ~tag.p & T.class == 2;

load('glmCC_src.mat', 'result');

for iCT = 4:5
    cellList = T.cellList(tag.(cellNm{iCT}));
    nC = length(cellList);

    %% Load cell data
    predir = 'C:\\Users\\Lapis\\OneDrive\\project\\classical_conditioning\\data\\';
    curdir = 'D:\\Cheetah_data\\classical_conditioning\\';
    mFile = cellfun(@(x) regexprep(x,predir,curdir), cellList, 'UniformOutput', false);
    
    preext = '.mat';
    curext = '.t';
    
    tFile = cellfun(@(x) regexprep(x,preext,curext), mFile, 'UniformOutput', false);
    [tData, tList] = tLoad(tFile);

    [betas, sems, srcs, srsem] = deal(cell(nC, nVar));
    for iC = 1:nC
        %% Load event data
        disp(['Cell ', num2str(iC), ' / ', num2str(nC)]);
        load([fileparts(tList{iC}), '\Events.mat'], ...
            'taskTime', 'eventTime', 'rewardLickTime', 'lickOnsetTime', 'cue', 'reward', 'punishment');
        
        [varTime, varData] = deal(cell(1, nVar));
        
        varTime{1} = eventTime(:, 1);
        for iCue = 1:4
            varTime{1+iCue} = eventTime(cue==iCue, 2);
        end
        varTime{6} = rewardLickTime(logical(reward));
        varTime{7} = rewardLickTime(cue<4 & reward==0);
        
        varTime{8} = rewardLickTime(logical(punishment));
        varTime{9} = rewardLickTime(cue==4 & punishment==0);
        
        lickRest = find(diff(lickOnsetTime) >= 2000);
        varTime{10} = lickOnsetTime;
        varTime{10}([lickRest; lickRest+1]) = [];
        varTime{11} = lickOnsetTime(lickRest+1);
        varTime{12} = lickOnsetTime(lickRest);
        
        varSTD = cellfun(@nanstd, varTime, 'UniformOutput', false);
        
        timeBin = taskTime(1):winSize:taskTime(2);
        nTimeBin = length(timeBin);
        
        for iV = 1:nVar
            if isempty(varTime{iV}); varData{iV} = []; continue; end;
            varData{iV} = zeros(nTimeBin, nWinBin(iV));
            for iB = 1:nWinBin(iV)
                varData{iV}(:, iB) = logical(histc(varTime{iV}, timeBin - winStep{iV}(iB)));
            end
        end
        nVarBin = cellfun(@(x) size(x,2), varData);
        X = cell2mat(varData);
        
        %% Rearrange data
        spike = histc(tData{iC}, timeBin) / (winSize/1000);
        nSpike = length(spike);
        inBin = 1:(nSpike-1);
        
        spkSTD = nanstd(spike(inBin));
        
        [b, dev, stats] = glmfit(X(inBin, :), spike(inBin), 'poisson');
        m = mat2cell(stats.beta(2:end)', 1, nVarBin);
        s = mat2cell(stats.se(2:end)', 1, nVarBin);
        
        for iVar = 1:nVar
            if isempty(m{iVar})
                betas{iC, iVar} = NaN(1, nWinBin(iVar));
                srcs{iC, iVar} = NaN(1, nWinBin(iVar));
                sems{iC, iVar} = NaN(1, nWinBin(iVar));
                continue;
            end
            betas{iC, iVar} = m{iVar};
            sems{iC, iVar} = [m{iVar}-s{iVar}, flip(m{iVar}+s{iVar})];
            srcs{iC, iVar} = m{iVar} .* varSTD{iVar} ./ spkSTD;
            srsemTemp = s{iVar} .* varSTD{iVar} ./ spkSTD;
            srsem{iC, iVar} = [srcs{iC, iVar}-srsemTemp, flip(srcs{iC, iVar}+srsemTemp)];
        end
    end
    result.(cellNm{iCT}).src = srcs;
    result.(cellNm{iCT}).beta = betas;
    result.(cellNm{iCT}).sem = sems;
    result.(cellNm{iCT}).srsem = srsem;
end
result.timeBin = cellfun(@(x) x/1000, winStep, 'UniformOutput', false);
result.timeSem = cellfun(@(x) [x/1000 flip(x)/1000], winStep, 'UniformOutput', false);

save('glmCC_src.mat', 'result');