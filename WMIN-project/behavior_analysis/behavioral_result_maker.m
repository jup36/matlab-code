% function behavioral_result_maker()
clc; clearvars; close all;

startingFolder = 'C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\data\Behavior\SOMChR';
cd(startingFolder);
[nm, dir] = uigetfile({'*.txt'});
oFile = [dir, nm];
formatSpec = '%10s %1f %1f';
fileID = fopen(oFile,'r');
C = textscan(fileID, formatSpec, 'HeaderLines', 1);
fclose(fileID);

[~, ~, ~, h, mn, s] = datevec(C{1},'HHMMSS.FFF');
timeS = (3600*h + 60*mn + s)*1000;
sensor = C{2};
run = C{3};

inLine = (sensor==4 | sensor==5);

place = 6 - sensor(inLine);
run = run(inLine);

% error check
nR = length(run);
iTrial = 0;
state = 0;
cue = [];
choice = [];
for iR = 1:nR
    if run(iR)==0 && state==0
        iTrial = iTrial + 1;
        state = 1;
        cue = [cue; place(iR)];
    elseif run(iR)==1 && state==1
        state = 0;
        choice = [choice; place(iR)];
    else
        state = 0;
        error('There was an error of sensor detection.');
    end 
end

nTrial = min([length(choice) length(cue)]);
result = zeros(7, nTrial);
result(1,:) = 3 - cue(1:nTrial)'; % target: 1-left, 2-right
result(2,:) = choice(1:nTrial)'; % choice: 1-left, 2-right

result(3,result(1,:)==2 & result(2,:)==2) = 2;
result(3,result(1,:)==2 & result(2,:)==1) = 1;
result(4,result(1,:)==1 & result(2,:)==1) = -2;
result(4,result(1,:)==1 & result(2,:)==2) = -1;
result(5,:) = 3;
result(6,:) = result(1,:)==result(2,:);

nmTemp = strsplit(nm, '_');

newNm = '';
for iN = 1:length(nmTemp)
    if iN==3
        newNm = [newNm, nmTemp{iN}, '_result_'];
    elseif iN==length(nmTemp)
        newNm = [newNm, nmTemp{iN}];
    else
        newNm = [newNm, nmTemp{iN}, '_'];
    end
end

if exist(newNm)==0
    dlmwrite(newNm, result, 'delimiter', '\t', 'precision', '%.3f');
else
    error('file exist!');
end