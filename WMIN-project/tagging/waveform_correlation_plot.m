function waveform_correlation_plot

load('D:\GitHub\matlab-code\WMIN-project\tagging\waveform_correlation.mat');

nC = 22+14+9;
r = [stat_pv.r; stat_nssom.r; stat_wssom.r];
sponwv = [stat_pv.m_spont_wv; stat_nssom.m_spont_wv; stat_wssom.m_spont_wv];
evokedwv = [stat_pv.m_evoked_wv; stat_nssom.m_evoked_wv; stat_wssom.m_evoked_wv];

close all;
fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.9 6.88]);

for iC = 1:nC
    ha(iC) = axes('Position', axpt(9, 5, mod(iC-1,9)+1, floor((iC-1)/9)+1));
    hold on;
    plot(sponwv(iC,:), 'Color', 'k');
    plot(evokedwv(iC,:), 'Color', [0 0.66 1]);
    text(33/2, 2.5, ['r = ',num2str(r(iC),'%-.3f')],'FontSize', 4, 'HorizontalAlign', 'center');
end

set(ha, 'Visible', 'off', 'YLim', [-2 2]);

print(gcf, '-dtiff', '-r600', 'waveform_correlation.tif');