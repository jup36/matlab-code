function [timeStamp, waveForm, header] =  NTT2Mat(fNm)
% Performance: 20 sec for 200 megabyte file (LoadTT_NeuralynxNT: 0.9 sec)

fID = fopen(fNm);

header = cell(10, 1);
for iL = 1:49
    header{iL} = fgetl(fID);
end

packetSize = 304; % (64+32+32+8*32+4*32*16)/8;
fseek(fID, 0, 'eof');
endPt = ftell(fID);
nPacket = floor((endPt - 16*1024)/packetSize);

fseek(fID, 16*1024, 'bof');

timeStamp = zeros(nPacket, 1, 'uint64');
waveForm = zeros(nPacket,4,32, 'int16');

for iP = 1:nPacket
    timeStamp(iP) = fread(fID, 1, 'uint64');
    fread(fID, [1 10], 'uint32');
    waveForm(iP, :, :) = reshape(fread(fID, [4 32], 'int16'), 1, 4, 32);
end

fclose(fID);

timeStamp = double(timeStamp)/10; % in ms
waveForm = double(waveForm);