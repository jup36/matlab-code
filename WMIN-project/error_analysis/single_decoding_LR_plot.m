% error decoding
clc; clearvars; close all;
load('error_decoding.mat');


varName = {'single_bayes_03s_LR.tif', 'single_bayes_01s_LR.tif', 'single_bayes_12s_LR.tif', 'single_bayes_23s_LR.tif', 'single_lda_03s_LR.tif', 'single_lda_01s_LR.tif', 'single_lda_12s_LR.tif', 'single_lda_23s_LR.tif'};
lineColor = {[0.2 0 0], [1 0 0], [0 0 0.2], [0 0 1]};
typeName = {'PV', 'SOM', 'Type I', 'Type II'};
cellName = {'nspv', 'som', 'fs', 'pc'};
nN = length(varName);
nT = length(typeName);

for iN = 1:nN
    close all;
    fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5 6.375]);
    for iT = 1:nT
        result = cellfun(@nanmean, single_decoding(iN, iT).performance)*100;
        [~, p1] = ttest(result(:, 1), result(:, 3));
        nP1 = sum(~any(isnan(result(:, [1 3])), 2));
        maxP1 = 100*(nanmean(result(:, [1 3])) + nanstd(result(:, [1 3]))/sqrt(nP1)) + 5;
        maxmaxP1 = max(maxP1) + 15;
        
        [~, p2] = ttest(result(:, 2), result(:, 4));
        nP2 = sum(~any(isnan(result(:, [2 4])), 2));
        maxP2 = 100*(nanmean(result(:, [2 4])) + nanstd(result(:, [2 4]))/sqrt(nP2)) + 5;
        maxmaxP2 = max(maxP2) + 15;
        
        group = repmat([1 3 2 4], size(result, 1), 1);
        result = result(:);
        group = group(:);
        
        axes('Position', axpt(2, 2, mod(iT-1, 2)+1, ceil(iT/2),  [0.15 0.1 0.80 0.85], [0.125 0.125]));
        hold on;
        MyErrorBarPlot(result, group, 0.5, lineColor);

        if p1 < 0.05
            plot([1 1], [maxP1(1) maxmaxP1], 'LineWidth', 0.5, 'Color', 'k');
            plot([2 2], [maxP1(2) maxmaxP1], 'LineWidth', 0.5, 'Color', 'k');
            plot([1 2], [maxmaxP1 maxmaxP1], 'LineWidth', 0.5, 'Color', 'k');
            text(1.5, maxmaxP1+5, '*', 'FontSize', 5, 'Color', 'k', 'HorizontalAlign', 'center');
        end
        if p2 < 0.05
            plot([1 1]+2, [maxP2(1) maxmaxP2], 'LineWidth', 0.5, 'Color', 'k');
            plot([2 2]+2, [maxP2(2) maxmaxP2], 'LineWidth', 0.5, 'Color', 'k');
            plot([1 2]+2, [maxmaxP2 maxmaxP2], 'LineWidth', 0.5, 'Color', 'k');
            text(3.5, maxmaxP2+5, '*', 'FontSize', 5, 'Color', 'k', 'HorizontalAlign', 'center');
        end
        
        title(typeName{iT}, 'FontSize', 5);
        if mod(iT, 2)==1
            ylabel('Decoding performance (%)');
        end
        set(gca, 'TickDir', 'out', 'FontSize', 4, 'LineWidth', 0.2, ...
            'XLim', [0.5 4.5], 'XTick', 1:4, 'XTickLabel', {'L>R', 'L>L', 'R>L', 'R>R'}, ...
            'YLim', [0 100], 'YTick', 0:20:100);
    end
    print(fHandle, '-dtiff', '-r300', varName{iN});
end
