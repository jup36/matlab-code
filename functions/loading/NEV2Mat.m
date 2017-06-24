function [eData, header] =  NEV2Mat(fNm)
%Opens NEV file and reads binary data
% Dohoung Kim
% 2017. 6. 23

fID = fopen(fNm);

% read header
header = cell(10, 1);
for iL = 1:10
    header{iL} = fgetl(fID);
end

% set the start point and end point
packetSize = 184; % (3*16+64+5*16+8*32+128*8)/8
fseek(fID, 0, 'eof');
endPt = ftell(fID);
fseek(fID, 1024*16, 'bof');
nPacket = (endPt-1024*16) / packetSize;

t = zeros(nPacket, 1, 'uint64');
ttl = zeros(nPacket, 1, 'uint16');
s = cell(nPacket, 1);

for iP = 1:nPacket
    fread(fID, [1 3], 'int16');
    t(iP) = fread(fID, 1, 'uint64');
    fread(fID, 1, 'int16');
    ttl(iP) = fread(fID, [1 1], 'int16');
    fread(fID, [1 19], 'int16');
    s{iP} = fread(fID, [1 128], '*char');
end

fclose(fID);

eData.t = double(t)/1000;
eData.s = s;
eData.ttl = double(ttl);