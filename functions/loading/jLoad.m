function jLoad()

clearvars; jrc clear; close all; clc;

probeType = 'imec3_opt4';
dataPath = 'C:\SGL_DATA';
% jrcPath = 'C:\Users\kimd11\OneDrive - Howard Hughes Medical Institute\src\jrclust';

cd(dataPath);
[dataFile, dataPath] = uigetfile('*.bin', 'Choose binary file');
[~,dataFileName] = fileparts(dataFile);
prmName = fullfile(dataPath,[dataFileName,'_',probeType,'.prm']);

if exist(prmName, 'file')==2
    jrc('manual',prmName);
else
    jrc('makeprm',fullfile(dataPath,dataFile));
    jrc('spikesort');
    jrc('manual');
end

