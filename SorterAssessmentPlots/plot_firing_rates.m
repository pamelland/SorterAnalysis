function [bin_heights, bin_edges] = plot_firing_rates(hist_ops, varargin)
% ASSUMES spike time units are seconds
%% KS histogram of spike train

st          = hist_ops.st;
unit        = hist_ops.unit; 

bin_width       = hist_ops.bin_width;
bin_width_label = hist_ops.bin_width_label;
t_start         = hist_ops.t_start;



hist_ops.bin_width = 1/6; % in hours


if strcmp( bin_width_label, 'hours')
    scalar = 1 / 60 / 60;
elseif strcmp( bin_width_label, 'minutes')
    scalar = 1 / 60;
elseif stcrmp( bin_width_label, 'seconds' )
    scalar = 1;
elseif strcmp( bin_width_label, 'days')
    scalar = 1/ 60 / 60 / 24;
else
    error('''bin_width_label'' must be ''hours'', ''minutes'', ''seconds'', or ''days''')
end


sp_times_unit = st( ismember(st(:,2),unit), 1 );

figure
hold on
[bin_heights, bin_edges] = histcounts(sp_times_unit .*scalar, 'BinWidth', bin_width);

% bar(t_start+ (0.5*(bin_edges(1:end-1) + bin_edges(2:end))), ...
%     bin_heights ./ hist_ops.bin_width .* scalar, ...
%     varargin{:})
stairs(t_start+ bin_edges, ...
    [bin_heights bin_heights(end)] ./ hist_ops.bin_width .* scalar, ...
    varargin{:})


xlim(t_start + [-hist_ops.bin_width ( max(sp_times_unit) .* scalar + hist_ops.bin_width)])
ylim([0 max(ylim)])
% line(xlim, mean(bin_heights)./ hist_ops.bin_width .* scalar .* [1 1], 'LineWidth', 1.5, 'Color','r')
ax = gca;
ax.FontSize = 16;
% title(sprintf('Unit: %d firing rates. Bin width: %0.2f %s', unit, bin_width, bin_width_label), ...
%       'FontSize', 20, ...
%       'FontWeight', 'normal')
xlabel(sprintf('Time (%s)', bin_width_label), 'FontSize', 16)
ylabel('FR (Hz)', 'FontSize', 16)

ax.TickDir = 'out';
box off
ax.LineWidth = 1;
grid on

