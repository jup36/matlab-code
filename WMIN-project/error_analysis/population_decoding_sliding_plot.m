% error decoding
clc; clearvars; close all;
load('decoding_pre_post.mat');

fillColor = {[0.5 0.5 0.5], [1 0.5 0.5]};
lineColor = {[0 0 0], [1 0 0]};
typeName = {'PV', 'SOM', 'Type I', 'Type II'};
cellName = {'nspv', 'som', 'fs', 'pc'};

fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5 6.375]);
for iT = 1:4
    performance = {result_lda.(cellName{iT}).performance.correct, result_lda.(cellName{iT}).performance.error};
    nC = size(performance{1}, 2);
    
    axes('Position', axpt(2, 2, mod(iT-1, 2)+1, ceil(iT/2),  [0.15 0.1 0.80 0.85], [0.125 0.125]));
    hold on;
    for iP = 1:2
        mP = nanmean(performance{iP});
        sP = nanstd(performance{iP}) / sqrt(size(performance{iP}, 1));
        
        ssP = [mP-sP flip(mP+sP)];
        stime = [time flip(time)];
        
        
        plot([0 0], [0 100], 'LineStyle', '-', 'LineWidth', 0.3, 'Color', [0.8 0.8 0.8]);
        plot([3 3], [0 100], 'LineStyle', '-', 'LineWidth', 0.3, 'Color', [0.8 0.8 0.8]);
        plot([-1 4], [50 50], 'LineStyle', '-', 'LineWidth', 0.3, 'Color', [0.8 0.8 0.8]);
        fill(stime/1000, 100*ssP, fillColor{iP}, 'LineStyle', 'none', 'FaceAlpha', 0.5);
        plot(time/1000, 100*mP, 'LineWidth', 0.5, 'Color', lineColor{iP});
    end
    set(gca, 'TickDir', 'out', 'LineWidth', 0.2', 'FontSize', 4, ...
        'XLim', [-1 4], 'XTick', -1:4, 'XTickLabel', {'', 0, '', '', 3, ''}, ...
        'YLim', [0 100], 'YTick', 0:20:100);
    title([typeName{iT}, ', n = ', num2str(result_bayes.(cellName{iT}).nCell)], 'FontSize', 6);
    if iT >= 3
        xlabel('Time from delay onset (s)', 'FontSize', 5);
    else
        set(gca, 'XTickLabel', []);
    end
    if mod(iT, 2)==1
        ylabel('Decoding performance (%)', 'FontSize', 5);
    else
        set(gca, 'YTickLabel', []);
    end;
end

print(fHandle, '-dtiff', '-r300', 'decoding_sliding_1_19_lda.tif');

