clc; clearvars; close all;

% variables
varName = {'Prep cue', 'Cue A', 'Cue B', 'Cue C', 'Cue D', ...
    'Reward', 'Non-reward', 'Punishment', 'Non-punishment', ...
    'Mid-bout lick', 'Lick onset', 'Lick offset'};

% load cell data
load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\regression\glmCC_src.mat');

cellNm = {'nspv', 'nssom', 'wssom'};
nCT = length(cellNm);


% fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/1.75 6.375/2]);
hold on;

hA = zeros(1,nCT);
for iCT = 1
    for iE = 1:12
        src = cell2mat(result.(cellNm{iCT}).src(:, iE))/100000;
%         srsem = cell2mat(result.(cellNm{iCT}).srsem(:, iE))/1000;
        
        outB = abs(src) > 5;
        
        src(outB) = NaN;
        
        nC = sum(~isnan(src));
        mB = nanmean(src);
        sB = nanstd(src) ./ sqrt(nC);
        
        ssB = [mB-sB flip(mB+sB)];
        
        tB = result.timeBin{iE};
        ttB = result.timeSem{iE};
        
        subplot(4, 3, iE);
        hold on;
        plot(tB([1 end]), [0 0], 'LineWidth', 0.35, 'LineStyle', '--', 'Color', [0.8 0.8 0.8]);
        fill(ttB, ssB, [0.8 0.8 0.8], 'LineStyle', 'none', 'FaceAlpha', 0.5);
        plot(tB, mB, 'LineWidth', 1, 'Color', 'k');
        set(gca, 'XLim', tB([1 end]), ...
            'YLim', [-0.6 0.6]);
        title(varName{iE});
    end
    
%     print(gcf, '-dtiff', '-r300', ['glm_', cellNm{iCT}, '.tif']);
%     clf;
end