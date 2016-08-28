clc; clearvars; close all;

% variables
winSize = 100;
winStep = {-200:winSize:300; ...
    -200:winSize:1700; ...
    -200:winSize:1700; ...
    -200:winSize:1700; ...
    -200:winSize:1700; ...
    -200:winSize:2200; ...
    -200:winSize:2200; ...
    -200:winSize:2200; ...
    -200:winSize:2200; ...
    -600:winSize:1400; ...
    -600:winSize:2900; ...
    -600:winSize:7900;};
varName = {'Prep cue', 'Cue A', 'Cue B', 'Cue C', 'Cue D', ...
    'Reward', 'Non-reward', 'Punishment', 'Non-punishment', ...
    'Mid-bout lick', 'Lick onset', 'Lick offset'};

% load cell data
load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\regression\glmCC.mat');

cellNm = {'nspv', 'nssom', 'wssom', 'fs', 'pc'};
nCT = length(cellNm);
tag.p = T.pLR < 0.01 & T.pSalt < 0.01;
tag.pv = tag.p & T.mouseLine=='PV';
tag.nspv = tag.p & T.mouseLine=='PV' & T.class == 1;
tag.som = tag.p & T.mouseLine=='SOM';
tag.nssom = tag.p & T.mouseLine=='SOM' & T.class == 1;
tag.wssom = tag.p & T.mouseLine=='SOM' & T.class == 2;
tag.fs = ~tag.p & T.class == 1;
tag.pc = ~tag.p & T.class == 2;

% fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/1.75 6.375/2]);
hold on;

hA = zeros(1,nCT);
iC = 10;
for iCT = 1
    for iE = 1:12
        betas = table2array(T(tag.(cellNm{iCT}), 13+iE));
        sems = table2array(T(tag.(cellNm{iCT}), 25+iE));
        
        tB = winStep{iE}/1000;
        ttB = [tB flip(tB)];
        
        mB = betas(iC, :);
        if iscell(sems)
            sB = sems{iC};
        else
            sB = sems(iC, :);
        end
        
        if isempty(sB); continue; end;
        ssB = [mB-1.96*sB flip(mB+1.96*sB)];
        
        subplot(4, 3, iE);
        hold on;
        plot(tB([1 end]), [0 0], 'LineWidth', 0.35, 'LineStyle', '--', 'Color', [0.8 0.8 0.8]);
        fill(ttB, ssB, [0.8 0.8 0.8], 'LineStyle', 'none', 'FaceAlpha', 0.5);
        plot(tB, mB, 'LineWidth', 1, 'Color', 'k');
        set(gca, 'XLim', tB([1 end]));
        title(varName{iE});
       
    end
    
%     print(gcf, '-dtiff', '-r300', ['glm_', cellNm{iCT}, '.tif']);
%     clf;
end