function runJrc(binFile)
%RUNJRC Executes JRCLUST program
%   RUNJRC(BINFILE) runs JRCLUST program. Makes parameter file
%   (*.prm) using 'jrc makeprm'. Then, it executes spike sorting using 'jrc
%   spikesort'. Finally, it starts manual clustering using  'jrc manual'.

%   Dohoung Kim
%   Howard Hughes Medical Institute
%   Janelia Research Campus
%   19700 Helix Drive
%   Ashburn, Virginia 20147
%   kimd11@janelia.hhmi.org

% default data directory
DATA_PATH = 'E:\';


% make file list
if nargin < 1
    binList = dir(fullfile(DATA_PATH,'*.ap.bin'));
    nBin = length(binList);
    
    binFile = {};
    for iBin = 1:nBin
        if binList(iBin).bytes > 10^10
            binFile = [binFile; {fullfile(DATA_PATH, binList(iBin).name)}];
        end
    end
end


nBin = length(binFile);
[prmFile, spkwavFile] = deal(cell(nBin, 1));
for iBin = 1:nBin
    option = readOption(binFile{iBin});
    prmFile{iBin} = replace(binFile{iBin}, '.bin', ['_imec3_opt', num2str(option,1),'.prm']);
    spkwavFile{iBin} = replace(prmFile{iBin}, '.prm', '_spkwav.jrc');

    % make prm
    if exist(prmFile{iBin}, 'file') ~= 2
        jrc('makeprm', binFile{iBin});
    end
    
    if exist(spkwavFile{iBin}, 'file') ~= 2
        jrc('spikesort', prmFile{iBin});
    end
end

iFile = listdlg('PromptString', 'Select a file for manual clustering', ...
    'SelectionMode', 'single', ...
    'ListSize', [400, 200], ...
    'ListString', prmFile);

if ~isempty(iFile)
    jrc('manual', prmFile{iFile});
end




function option = readOption(binFile)
% Parse ini file into cell entries C{1}{i} = C{2}{i}
metaFile = replace(binFile, '.bin', '.meta');
fid = fopen(metaFile, 'r');
C = textscan(fid, '%[^=] = %[^\r\n]');
fclose(fid);

% New empty struct
meta = struct();

% Convert each cell entry into a struct entry
for i = 1:length(C{1})
    tag = C{1}{i};
    if tag(1) == '~'
        % remake tag excluding first character
        tag = sprintf('%s', tag(2:end));
    end
    meta.(tag) = C{2}{i};
end
option = meta.imProbeOpt(1);