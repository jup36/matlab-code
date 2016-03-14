function fon_modulation
close all; clearvars;
load('C:\users\lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat', ...
    'pc_pvmice', 'pc_sommice', 'fs_pvmice', 'fs_sommice');
modList = cell(4,1);
modList{1} = pc_pvmice(cellfun(@(x) ~isempty(strfind(x,'mod')), pc_pvmice));
modList{2} = pc_sommice(cellfun(@(x) ~isempty(strfind(x,'mod')), pc_sommice));
modList{3} = fs_pvmice(cellfun(@(x) ~isempty(strfind(x,'mod')), fs_pvmice));
modList{4} = fs_sommice(cellfun(@(x) ~isempty(strfind(x,'mod')),fs_sommice));

eList = cellfun(@(x) [fileparts(x),'\Events.mat'], pc_pvmice, 'UniformOutput', false);
eList{2} = cellfun(@(x) [fileparts(x),'\Events.mat'], pc_sommice, 'UniformOutput', false);
eList{3} = cellfun(@(x) [fileparts(x),'\Events.mat'], fs_pvmice, 'UniformOutput', false);
eList{4} = cellfun(@(x) [fileparts(x),'\Events.mat'], fs_sommice, 'UniformOutput', false);

% variables
timeWindow = [-1000 4000];
binWindow = 500;
binStep = 100;
binSize = length((timeWindow(1)+binWindow/2):binStep:(timeWindow(2)-binWindow/2));
pthres = 0.05;

nM = 4;
[fon_nomod_L fon_nomod_R fon_mod_L fon_mod_R] = deal(zeros(nM, binSize));
for iM = 1:nM
    eList = cellfun(@(x) [fileparts(x),'\Events.mat'], modList{iM}, 'UniformOutput', false);
    
    nC = length(modList{iM});
    [p_nomod_L p_nomod_R p_mod_L p_mod_R] = deal(zeros(nC, binSize));
    for iC = 1:nC
        load(eList{iC}, 'trialresult');
        cue = trialresult(:,1)-1;
        choice = trialresult(:,2)-1;
        reward = trialresult(:,3);
        modulation = trialresult(:,4);
        error = cue==choice;
        
        cue(error) = [];
        modulation(error) = [];
        
        load(modList{iM}{iC}, 'spikeTime');
        [time, spk] = spikeBin(spikeTime, timeWindow, binWindow, binStep);
        spk(error, :) = [];
                
        reg_nomod = slideReg(time, spk(modulation==0,:), cue(modulation==0));
        reg_mod = slideReg(time, spk(modulation>=1,:), cue(modulation>=1));
        
        p_nomod_L(iC, :) = (reg_nomod.p<pthres) & (reg_nomod.betas>0);
        p_nomod_R(iC, :) = (reg_nomod.p<pthres) & (reg_nomod.betas<0);
        p_mod_L(iC, :) = (reg_mod.p<pthres) & (reg_mod.betas>0);
        p_mod_R(iC, :) = (reg_mod.p<pthres) & (reg_mod.betas<0);
    end
    
    fon_nomod_L(iM, :) = mean(p_nomod_L);
    fon_nomod_R(iM, :) = mean(p_nomod_R);
    fon_mod_L(iM, :) = mean(p_mod_L);
    fon_mod_R(iM, :) = mean(p_mod_R);
    
    subplot(4,2,iM*2-1);
    hold on;
    plot(time, fon_nomod_L(iM, :), 'k');
    plot(time, fon_mod_L(iM, :), 'b');
    set(gca, 'Box', 'off', 'TickDir', 'out', ...
        'XLim', timeWindow, 'XTick', timeWindow(1):1000:timeWindow(2), 'XTickLabel', {[],0,[],[],3,[]}, ...
        'YLim', [0 1]);
    if iM == 1; title('PC PV RL');
    elseif iM == 2; title('PC SOM RL');
    elseif iM == 3; title('FS PV RL');
    else; title('FS SOM RL');
    end
    
    subplot(4,2,iM*2);
    hold on;
    plot(time, fon_nomod_R(iM, :), 'k');
    plot(time, fon_mod_R(iM, :), 'b');
    set(gca, 'Box', 'off', 'TickDir', 'out', ...
        'XLim', timeWindow, 'XTick', timeWindow(1):1000:timeWindow(2), 'XTickLabel', {[],0,[],[],3,[]}, ...
        'YLim', [0 1]);
    if iM == 1; title('PC PV LR');
    elseif iM == 2; title('PC SOM LR');
    elseif iM == 3; title('FS PV LR');
    else; title('FS SOM LR');
    end
end

function reg = slideReg(time, spk, predictor)
nBin = size(time,2);
nVar = size(predictor,2);

p = zeros(nVar,nBin);
betas = zeros(nVar,nBin);

for iBin = 1:nBin
    [beta,~,stats] = glmfit(predictor, spk(:,iBin));
    
    betas(:,iBin) = beta(2:end);
    p(:,iBin) = stats.p(2:end);
end

reg = struct('time',time, 'p',p, 'betas', betas);
end
end