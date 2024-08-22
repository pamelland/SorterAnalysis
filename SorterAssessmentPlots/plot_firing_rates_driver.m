hist_ops.st     = st2;
hist_ops.unit   = 15; 
gt_unit = 8;

hist_ops.bin_width = 1/6;  % in hours
hist_ops.bin_width_label = 'hours';
hist_ops.t_start   = 0;

plot_firing_rates(hist_ops, 'Color', [0 0 0], ...
    'LineWidth',1)


xticks(10:2:22)
xlim([10 22])
fig_width   = 1.75;
fig_height  = 1;

set(gca, 'FontSize', 8)
resize_figure(gcf, gca, fig_width, fig_height, 'inches');

% line(xlim, uFRs{1}(gt_unit) .*[ 1 1], 'Color', 'b', 'LineWidth', 1)