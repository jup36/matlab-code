function regressCC(cellFolder, binWindow, binStep)
%regressCC calculates coefficients for each behavioral variables
warning off;

% find files
switch nargin
    case 0
        matFile = FindFiles('T*.mat','CheckSubdirs',0); 
    case 1 
        if ~iscell(cellFolder) 
            disp('Input argument is wrong. It should be cell array.');
            return;
        elseif isempty(cellFolder)
            matFile = FindFiles('T*.mat','CheckSubdirs',1);
        else
            nFolder = length(cellFolder);
            matFile = cell(0,1);
            for iFolder = 1:nFolder
                if exist(cellFolder{iFolder})==7
                    cd(cellFolder{iFolder});
                    matFile = [matFile;FindFiles('T*.mat','CheckSubdirs',1)];
                elseif strcmp(cellFolder{iFolder}(end-3:end),'.mat')
                    matFile = [matFile;cellFolder{iFolder}];
                end
            end
        end
end
if isempty(matFile)
    disp('Mat file does not exist!');
    return;
end
if nargin < 2
    binWindow = 500;
    binStep = 100;
elseif nargin==2
    binStep = binWindow;
end

rtdir = pwd;
nFile = length(matFile);

for iFile = 1:nFile
    disp(['### Analyzing ',matFile{iFile},'...']);
    [cellDir,cellName,~] = fileparts(matFile{iFile});

    cd(cellDir);
    load(matFile{iFile});
    load('Events.mat');

    [reg_time, reg_spk] = spikeBin(spikeTime, win, binWindow, binStep);
    [regRw_time, regRw_spk] = spikeBin(spikeTimeRw, winRw, binWindow, binStep);
    
    inRegress = (cue==1 | cue==4);
    reg_spk = reg_spk(inRegress,:);
    regRw_spk = regRw_spk(inRegress,:);
    
    value = cue(inRegress);
    value(value~=1) = 0;
    modulation = modulation(inRegress);
    nomod = (modulation==0);
    mod = (modulation==1);
    inRw = ~isnan(rewardLickTime);
    inRw = inRw(inRegress);
    reward = reward(inRegress);
    punishment = punishment(inRegress);
    
    % regression (cue, reward | modulation==0)
    if any(nomod)
        reg_cr_nomod = slideReg(reg_time, reg_spk(nomod,:), [value(nomod) reward(nomod) punishment(nomod)]);
        regRw_cr_nomod = slideReg(regRw_time, regRw_spk(nomod & inRw,:), [value(nomod & inRw) reward(nomod & inRw) punishment(nomod & inRw)]);
        save(matFile{iFile}, 'reg_cr_nomod', 'regRw_cr_nomod', '-append');
    end
    
    % regression (cue, reward | modulation==1)
    % regression (cue, reward, modulation)
    if any(mod)
        reg_cr_mod = slideReg(reg_time, reg_spk(mod,:), [value(mod) reward(mod) punishment(mod)]);
        reg_crm = slideReg(reg_time, reg_spk, [value reward punishment modulation value.*modulation reward.*modulation punishment.*modulation]);
        regRw_cr_mod = slideReg(regRw_time, regRw_spk(mod & inRw,:), [value(mod & inRw) reward(mod & inRw) punishment(mod & inRw)]);
        regRw_crm = slideReg(regRw_time, regRw_spk(inRw,:), [value(inRw) reward(inRw) punishment(inRw) modulation(inRw) value(inRw).*modulation(inRw) reward(inRw).*modulation(inRw) punishment(inRw).*modulation(inRw)]);
        save(matFile{iFile}, 'reg_cr_mod', 'reg_crm', 'regRw_cr_mod', 'regRw_crm', '-append');
    end
end
disp('### Regression analysis done!');
end
    
function reg = slideReg(time, spk, predictor)
nBin = size(time,2);
nVar = size(predictor,2);

p = zeros(nVar,nBin);
src = zeros(nVar,nBin);
sse = zeros(nVar,nBin);

predStd = zeros(nVar,nBin);
for iVar = 1:nVar
    predStd(iVar,:) = std(predictor(:,iVar)) ./ std(spk,0,1);
end

for iBin = 1:nBin
    [beta,~,stats] = glmfit(predictor, spk(:,iBin));
    
    src(:,iBin) = beta(2:end) .* predStd(:,iBin);
    sse(:,iBin) = stats.se(2:end) .* predStd(:,iBin);
    p(:,iBin) = stats.p(2:end);
end

outRange = (abs(src+1.96*sse) > 10);
src(outRange) = 0;
sse(outRange) = 0;
p(outRange) = 1;

timesse = [time flip(time)];
sse = [src-1.96*sse flip(src+1.96*sse,2)];

reg = struct('time',time, 'p',p, 'src',src, 'timesse',timesse, 'sse',sse);
end