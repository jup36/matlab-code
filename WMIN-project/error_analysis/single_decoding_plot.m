% error decoding
clc; clearvars; close all;
load('error_decoding.mat');


varName = {'single_bayes_03s.tif', 'single_bayes_01s.tif', 'single_bayes_12s.tif', 'single_bayes_23s.tif', 'single_lda_03s.tif', 'single_lda_01s.tif', 'single_lda_12s.tif', 'single_lda_23s.tif'};
lineColor = {[0 0 0], [1 0 0]};
typeName = {'PV', 'SOM', 'Type I', 'Type II'};
cellName = {'nspv', 'som', 'fs', 'pc'};
nN = length(varName);
nT = length(typeName);

for iN = 1:nN
    close all;
    fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5*1.25 6.375*1.25]);
    for iT = 1:4
        correctResult = cellfun(@(x, y) nanmean([x; y]), single_decoding(iN, iT).performance(:, 1), single_decoding(iN, iT).performance(:, 2));
        errorResult = cellfun(@(x, y) nanmean([x; y]), single_decoding(iN, iT).performance(:, 3), single_decoding(iN, iT).performance(:, 4));
        
        result = [correctResult; errorResult]*100;
        group = [1*ones(length(correctResult), 1); 2*ones(length(errorResult), 1)];
      
        axes('Position', axpt(2, 2, mod(iT-1, 2)+1, ceil(iT/2),  [0.15 0.1 0.80 0.85], [0.125 0.125]));
        hold on;
        MyErrorBarPlot(result, group, 0.5, lineColor);
        
        [~, p] = ttest(correctResult, errorResult);
        if p < 0.05
            nP = sum(~any(isnan([correctResult errorResult]), 2));
            maxP = 100*(nanmean([correctResult errorResult]) + nanstd([correctResult errorResult])/sqrt(nP)) + 5;
            maxmaxP = max(maxP) + 15;
            
            plot([1 1], [maxP(1) maxmaxP], 'LineWidth', 0.5, 'Color', 'k');
            plot([2 2], [maxP(2) maxmaxP], 'LineWidth', 0.5, 'Color', 'k');
            plot([1 2], [maxmaxP maxmaxP], 'LineWidth', 0.5, 'Color', 'k');
            text(1.5, maxmaxP+7.5, ['\itp value = ', num2str(p, 3)], 'FontSize', 6, 'Color', 'k', 'HorizontalAlign', 'center');
        end
        
        title(typeName{iT}, 'FontSize', 5);
        if mod(iT, 2)==1
            ylabel('Decoding performance (%)');
        end
        set(gca, 'TickDir', 'out', 'FontSize', 4, 'LineWidth', 0.2, ...
            'XLim', [0.5 2.5], 'XTick', 1:2, 'XTickLabel', {'Corrrect', 'Error'}, ...
            'YLim', [0 100], 'YTick', 0:20:100);
    end
    print(fHandle, '-dtiff', '-r300', varName{iN});
end
