clear; clc; close all;
%%
count_tbl = readtable('/Volumes/PM-HD/FAST_data/MS5_SanityChecks/vary_threshold_ROCs.xlsx');
%%
clc;
figure
tt = tiledlayout(1,2);

nexttile
scatter(count_tbl.proxy_FPR, ...
        count_tbl.proxy_TPR, ...
        100,[1 0.7 0.7], 'filled', 's')

for thresh_iter = 1:7
    thresh = 10 + thresh_iter;
    text(count_tbl.proxy_FPR(thresh_iter), count_tbl.proxy_TPR(thresh_iter), ...
        sprintf('%d',thresh), ...
        'FontSize',16,...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment','bottom')
end
line([0 1], [0 1], 'Color', 'k')
xlim([0 max(count_tbl.proxy_FPR)])
xlabel('$\approx FPR = \frac{\rm{Phantom Events}}{\rm{Phantom Events + Real Events}}$', ...
    'Interpreter','latex')
ylabel('$\approx TPR = \frac{\rm{Matched Events}}{\rm{Real Events}}$', ...
    'Interpreter','latex')
ax = gca;
ax.FontSize = 16;
ax.LineWidth = 1.5;
grid on


nexttile
scatter(count_tbl.FPR_single, ...
        count_tbl.TPR_single, ...
        100,[1 0.7 0.7], 'filled', 's')

for thresh_iter = 1:7
    thresh = 10 + thresh_iter;
    text(count_tbl.FPR_single(thresh_iter), count_tbl.TPR_single(thresh_iter), ...
        sprintf('%d',thresh), ...
        'FontSize',16,...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment','bottom')
end
line([0 1], [0 1], 'Color', 'k')
xlabel('$\approx FPR = \frac{\rm{Unmatched \ to \ Single}}{\rm{MultiUnit \ Events}}$', ...
    'Interpreter','latex')
ylabel('$\approx TPR = \frac{\rm{Matched \ Single \ Units}}{\rm{Single \ Units}}$', ...
    'Interpreter','latex')
xlim([0 max(count_tbl.FPR_single)])
ax = gca;
ax.FontSize = 16;
ax.LineWidth = 1.5;
grid on