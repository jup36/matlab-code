function waveform_correlation
%waveform_correlation

% Variable nspv, nssom, and wssom will be used.
load('C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\celllist_neuron.mat');

stat_nspv = wvform_load(nspv);
stat_wspv = wvform_load(wspv);
stat_nssom = wvform_load(nssom);
stat_wssom = wvform_load(wssom);

save('waveform_correlation.mat', 'stat_nspv', 'stat_wspv', 'stat_nssom', 'stat_wssom');

function stats = wvform_load(mFile)
lightwin = [0 20]; % ms
sponwin = [-400 0]; % ms

preext1 = '.mat';
preext2 = '_\d.mat';
curext1 = '.clusters';
curext2 = '.ntt';
curext3 = '.t';

predir = 'C:\\Users\\Lapis\\OneDrive\\project\\workingmemory_interneuron\\data\\';
curdir = 'D:\\Cheetah_data\\workingmemory_interneuron\\';
mFile = cellfun(@(x) regexprep(x,predir,curdir),mFile,'UniformOutput',false);

tFile = cellfun(@(x) regexprep(x,preext1,curext3), mFile, 'UniformOutput',false);
cFile = cellfun(@(x) regexprep(x,preext2,curext1), mFile, 'UniformOutput',false);
ntFile = cellfun(@(x) regexprep(x,preext2,curext2), mFile, 'UniformOutput',false);
eFile = cellfun(@(x) [fileparts(x),'\Events.mat'], mFile, 'UniformOutput',false);

spdata = LoadSpikes(tFile,'tsflag','ts');

nC = length(mFile);
r = zeros(nC,1);
m_spont_wv = zeros(nC, 32);
m_evoked_wv = zeros(nC, 32);
for iC = 1:nC
    % Load waveform of single cluster
    [cellpath,cellname,~] = fileparts(mFile{iC});
    ttname = regexp(cellname,'_','split');
    
    load(cFile{iC}, '-mat', 'MClust_Clusters');
    spk_idx = FindInCluster(MClust_Clusters{str2num(ttname{2})});
    [~,wv] = LoadTT_NeuralynxNT(ntFile{iC});
    
    cellwv = wv(spk_idx,:,:);
    
    % Find highest peak channel
    load([cellpath,'\',ttname{1},'_Peak.fd'],'-mat', 'FeatureData');
    [~,maintt] = max(mean(FeatureData(spk_idx,:)));
    
    % Load spike time
    cellspk = Data(spdata{iC})/10;
    nspk = length(cellspk);
    
    % Load light time
    load(eFile{iC}, 'lighttime');
    lighttime = lighttime / 1000;
    nT = length(lighttime);
    
    % Find spike within the range of light stimulation
    spont_idx = zeros(nspk,1);
    evoked_idx = zeros(nspk,1);
    for iT = 1:nT
        [~,spont_temp] = histc(cellspk, lighttime(iT)+sponwin);
        [~,evoked_temp] = histc(cellspk,lighttime(iT)+lightwin);
        spont_idx(spont_temp==1) = 1;
        evoked_idx(find(evoked_temp==1, 1, 'first')) = 1;
    end
    
    % Get mean waveform
    spont_wv = cellwv(logical(spont_idx),:,:);
    evoked_wv = cellwv(logical(evoked_idx),:,:);
    m_spont_wv(iC,:) = squeeze(mean(spont_wv(:,maintt,:)));
    m_evoked_wv(iC,:) = squeeze(mean(evoked_wv(:,maintt,:)));
    
    m_spont_wv(iC,:) = m_spont_wv(iC,:) / max(m_spont_wv(iC,:));
    m_evoked_wv(iC,:) = m_evoked_wv(iC,:) / max(m_evoked_wv(iC,:));
    
    rtemp = corrcoef(m_spont_wv(iC,:)',m_evoked_wv(iC,:)');  
    r(iC) = rtemp(1,2);
end

stats = table(r, m_spont_wv, m_evoked_wv);