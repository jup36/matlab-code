% error decoding
clc; clearvars; close all;
load('error_decoding.mat');

fillColor = {[1 0.75 0.75], [0.75 0.75 1];[1 0.5 0.5], [0.5 0.5 1]};
lineColor = {[0.25 0 0], [0 0 0.25];[1 0.5 0.5], [0.5 0.5 1]};
typeName = {'PV', 'SOM', 'Type I', 'Type II'};
cellName = {'nspv', 'som', 'fs', 'pc'};

T = T_lda_01_fr05_pref;

fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5 6.375]);
for iT = 1:4
    axes('Position', axpt(2, 2, mod(iT-1, 2)+1, ceil(iT/2),  [0.15 0.1 0.80 0.85], [0.125 0.125]));
    hold on;
    
    nC = zeros(1,2);
    for iL = 1:2
        performance = {T(iT, iL).performance.correct, T(iT, iL).performance.error};
        nC(iL) = size(performance{1}, 2);
        for iP = 1:2
            mP = nanmean(performance{iP});
            sP = nanstd(performance{iP}) / sqrt(size(performance{iP}, 1));
            
            ssP = [mP-sP flip(mP+sP)];
            sC = [1:nC(iL) nC(iL):-1:1];
            
            plot([1 nC(iL)], [50 50], 'LineStyle', '-', 'LineWidth', 0.3, 'Color', [0.8 0.8 0.8]);
            fill(sC, 100*ssP, fillColor{iP, iL}, 'LineStyle', 'none', 'FaceAlpha', 0.5);
            plot(1:nC(iL), 100*mP, 'LineWidth', 0.5, 'Color', lineColor{iP, iL});
        end
    end
    set(gca, 'TickDir', 'out', 'LineWidth', 0.2', 'FontSize', 4, ...
        'XLim', [0 max(nC)], 'XTick', [0 max(nC)], ...
        'YLim', [0 100], 'YTick', 0:20:100);
    title(typeName{iT}, 'FontSize', 6);
    if iT >= 3
        xlabel('Cell number', 'FontSize', 5);
    end
    if mod(iT, 2)==1
        ylabel('Decoding performance (%)', 'FontSize', 5);
    else
        set(gca, 'YTickLabel', []);
    end;
end

print(fHandle, '-dtiff', '-r300', 'population_decoding_dropping_lda_01s_fr05_pref.tif');