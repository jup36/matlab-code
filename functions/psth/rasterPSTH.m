function [xpt,ypt,spikeBin,spikeHist,spikeConv,spikeConvZ, spikeSEM] = rasterPSTH(spikeTime, trialIndex, win, binSize, resolution, dot)
%rasterPSTH converts spike time into raster plot
%   spikeTime: cell array. each cell contains vector array of spike times per each trial. unit is msec
%   trialIndex: number of rows should be same as number of trials (length of spikeTime)
%   win: window range of xpt. should be 2 numbers. unit is msec.
%   binsize: unit is msec.
%   resolution: sigma for convolution = binsize * resolution.
%   dot: 1-dot, 0-line
%   unit of xpt will be msec.
narginchk(5, 6);
if isempty(spikeTime) || isempty(trialIndex) || length(spikeTime) ~= size(trialIndex,1) || length(win) ~= 2
    xpt = cell(1); ypt = cell(1); spikeBin = []; spikeHist = []; spikeConv = []; spikeConvZ = []; spikeSEM = [];
    return;
end;

spikeBin = win(1):binSize:win(2); % unit: msec
nSpikeBin = length(spikeBin);

nTrial = length(spikeTime);
nCue = size(trialIndex,2);
trialResult = sum(trialIndex);
resultSum = [0 cumsum(trialResult)];

yTemp = [0:nTrial-1; 1:nTrial; NaN(1,nTrial)]; % template for ypt
[xpt, ypt] = deal(cell(1,nCue));
[spikeHist, spikeConv] = deal(zeros(nCue,nSpikeBin));
spikeSEM = zeros(nCue, 2*nSpikeBin);

for iCue = 1:nCue
    if trialResult(iCue) == 0
        spikeHist(iCue,:) = NaN;
        spikeConv(iCue,:) = NaN;
        continue;
    end
    
    % raster
    nSpikePerTrial = cellfun(@length,spikeTime(trialIndex(:,iCue)));
    nSpikeTotal = sum(nSpikePerTrial);
    if nSpikeTotal == 0; continue; end;
    
    spikeTemp = cell2mat(spikeTime(trialIndex(:,iCue)))';
    
    xptTemp = [spikeTemp;spikeTemp;NaN(1,nSpikeTotal)];
    if (nargin == 6) && (dot==1)
        xpt{iCue} = xptTemp(2,:);
    else
        xpt{iCue} = xptTemp(:);
    end
    
    yptTemp = [];
    for iy = 1:trialResult(iCue)
        yptTemp = [yptTemp repmat(yTemp(:,resultSum(iCue)+iy),1,nSpikePerTrial(iy))];
    end
    if (nargin == 6) && (dot==1)
        ypt{iCue} = yptTemp(2,:);
    else
        ypt{iCue} = yptTemp(:);
    end
    
    % psth
    spkTemp = cell2mat(cellfun(@(x) histc(x, spikeBin, 2)/(binSize/10^3), spikeTime(trialIndex(:,iCue)), 'UniformOutput', false));
    
    spkhist_mean = sum(spkTemp, 1) / trialResult(iCue);
    spkhist_sem = std(spkTemp, [], 1) / sqrt(trialResult(iCue));
    
    spkconv_mean = conv(spkhist_mean,fspecial('Gaussian',[1 5*resolution],resolution),'same');
    spkconv_u_sem = conv(spkhist_mean+spkhist_sem, fspecial('Gaussian',[1 5*resolution],resolution),'same');
    spkconv_l_sem = conv(spkhist_mean-spkhist_sem, fspecial('Gaussian',[1 5*resolution],resolution),'same');
    
    %     spkconv_temp = ssvkernel(spikeTemp,spikeBin)*nSpikeTotal*1000/trialResult(iCue);
    spikeHist(iCue,:) = spkhist_mean;
    spikeConv(iCue,:) = spkconv_mean;
    spikeSEM(iCue,:) = [spkconv_l_sem flip(spkconv_u_sem)];
end

totalHist = histc(cell2mat(spikeTime),spikeBin)/(binSize/10^3*nTrial);
fireMean = mean(totalHist);
fireStd = std(totalHist);
spikeConvZ = (spikeConv-fireMean)/fireStd;
