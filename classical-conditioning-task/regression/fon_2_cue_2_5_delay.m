clc; clear all; close all;
sessionFolder = {'D:\Cheetah_data\classical_conditioning\PVMD2\2015-09-15_s4_1.35DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-09-16_s2_1.40DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-09-18_s4_1.50DV', ...
    'D:\Cheetah_data\classical_conditioning\PVMD2\2015-09-21_s4_1.55DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD1\2015-09-09_s4_1.20DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD1\2015-09-15_s4_1.25DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD1\2015-09-16_s2_1.30DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-09-09_s4_1.15DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-09-15_s4_1.20DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-09-16_s4_1.25DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-09-17_s4_1.30DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-09-18_s4_1.35DV', ...
    'D:\Cheetah_data\classical_conditioning\SOMMD2\2015-09-21_s4_1.40DV'};
nSession = length(sessionFolder);

cellList = {};
for iSession = 1:nSession
    cellList = [cellList; FindFiles('T*.mat','StartingDirectory',sessionFolder{iSession})];
end
nCell = length(cellList);

C_nomod = zeros(nCell,96);
R_nomod = zeros(nCell,96);
X_nomod = zeros(nCell,96);

C_mod = zeros(nCell,96);
R_mod = zeros(nCell,96);
X_mod = zeros(nCell,96);

for iCell = 1:nCell
    load(cellList{iCell});
    
    if iCell == 1;
        time = reg_cr_nomod.time;
    end
    C_nomod(iCell,:) = reg_cr_nomod.p(1,:);
    R_nomod(iCell,:) = reg_cr_nomod.p(2,:);
    X_nomod(iCell,:) = reg_cr_nomod.p(3,:);
    
    C_mod(iCell,:) = reg_cr_mod.p(1,:);
    R_mod(iCell,:) = reg_cr_mod.p(2,:);
    X_mod(iCell,:) = reg_cr_mod.p(3,:);
end

threshold = 0.05;
fon_C_nomod = mean(C_nomod <= threshold);
fon_R_nomod = mean(R_nomod <= threshold);
fon_X_nomod = mean(X_nomod <= threshold);

fon_C_mod = mean(C_mod <= threshold);
fon_R_mod = mean(R_mod <= threshold);
fon_X_mod = mean(X_mod <= threshold);

axes('Position',axpt(1,3,1,1));
hold on;
plot(time,fon_C_nomod,'Color','k');
plot(time,fon_C_mod,'Color','r');

axes('Position',axpt(1,3,1,2));
hold on;
plot(time,fon_R_nomod,'Color','k');
plot(time,fon_R_mod,'Color','r');

axes('Position',axpt(1,3,1,3));
hold on;
plot(time,fon_X_nomod,'Color','k');
plot(time,fon_X_mod,'Color','r');