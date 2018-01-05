function saveJrc(jrcFile)
%SAVEJRC Reads JRCLUST spike data and save to data mat file
%   SAVEJRC(JF) reads JF spike data and save. Units are saved in seconds.

%   Dohoung Kim
%   Howard Hughes Medical Institute
%   Janelia Research Campus
%   19700 Helix Drive
%   Ashburn, Virginia 20147
%   kimd11@janelia.hhmi.org

if nargin < 1 || exist(jrcFile, 'file')==0
%     DEFAULT_DATA_FOLDER = ['C:\OneDrive - Howard Hughes Medical Institute\data\imec\'];
    DEFAULT_DATA_FOLDER = 'E:';
    [jrcName, jrcPath] = uigetfile([DEFAULT_DATA_FOLDER, '\*_jrc.mat'], 'Choose file to load');
    if jrcName==0; Spike = [], jrcFile = [], return; end
    jrcFile = fullfile(jrcPath, jrcName);
end
dataFile = replace(jrcFile, '_jrc.mat', '_data.mat');

load(jrcFile, 'S_clu', 'viTime_spk');

unitNo = find(strcmp(S_clu.csNote_clu, 'single'));

Spike = struct();
Spike.nUnit = length(unitNo);
Spike.time = cell(Spike.nUnit, 1);
for iUnit = 1:Spike.nUnit
    Spike.time{iUnit} = double(viTime_spk(S_clu.cviSpk_clu{unitNo(iUnit)}))/30000; % in second
end

Spike.posX = S_clu.vrPosX_clu(unitNo);
Spike.posY = S_clu.vrPosY_clu(unitNo);
Spike.site = S_clu.viSite_clu(unitNo)'; % maximum amplitude channel number

Spike.Vmin = S_clu.vrVmin_uv_clu(unitNo);
Spike.Vpp = S_clu.vrVpp_uv_clu(unitNo);
Spike.waveform = S_clu.trWav_spk_clu(:,:,unitNo);

Spike.snr = S_clu.vrSnr_clu(unitNo);
Spike.isolationDistance = S_clu.vrIsoDist_clu(unitNo);
Spike.LRatio = S_clu.vrLRatio_clu(unitNo);
Spike.isiRatio = S_clu.vrIsiRatio_clu(unitNo);

if exist(dataFile, 'file')==2
    save(dataFile, 'Spike', '-append');
else
    save(dataFile, 'Spike');
end