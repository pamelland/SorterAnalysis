close all; clear;


conf_mat01_path = '/Users/pakemelland/Desktop/TEMP/SS_PlotPlayground/non-cont/mFigs/conf_mat_10-12_20-22-SMUSHED.fig';
conf_mat02_path = '/Users/pakemelland/Desktop/TEMP/SS_PlotPlayground/non-cont/mFigs/conf_mat_10-12_20-22-LINKED-INEQ.fig';


amp01_path = '/Users/pakemelland/Desktop/TEMP/SS_PlotPlayground/non-cont/mFigs/stSMUSH_unit_6_amps.fig';
amp02_path = '/Users/pakemelland/Desktop/TEMP/SS_PlotPlayground/non-cont/mFigs/stSMUSH_unit_18_amps.fig';
amp03_path = '/Users/pakemelland/Desktop/TEMP/SS_PlotPlayground/non-cont/mFigs/stINEQ_unit_15_amps.fig';
amp04_path = '/Users/pakemelland/Desktop/TEMP/SS_PlotPlayground/non-cont/mFigs/stGT_unit_8_amps.fig';


FR01_path   = '/Users/pakemelland/Desktop/TEMP/SS_PlotPlayground/non-cont/mFigs/stSMUSH_unit_6_FRs.fig';
FR02_path   = '/Users/pakemelland/Desktop/TEMP/SS_PlotPlayground/non-cont/mFigs/stSMUSH_unit_18_FRs.fig';
FR03_path   = '/Users/pakemelland/Desktop/TEMP/SS_PlotPlayground/non-cont/mFigs/stINEQ_unit_15_FRs.fig';
FR04_path   = '/Users/pakemelland/Desktop/TEMP/SS_PlotPlayground/non-cont/mFigs/stGT_unit_8_FRs.fig';

figure01 = openfig(conf_mat01_path); tcl01 = figure01.Children; 
figure02 = openfig(conf_mat02_path); tcl02 = figure02.Children;


amps01_plot = openfig(amp01_path); ax_a01 = amps01_plot.Children;
amps02_plot = openfig(amp02_path); ax_a02 = amps02_plot.Children;
amps03_plot = openfig(amp03_path); ax_a03 = amps03_plot.Children;
amps04_plot = openfig(amp04_path); ax_a04 = amps04_plot.Children;

FR01_plot = openfig(FR01_path); ax_FR01 = FR01_plot.Children;
FR02_plot = openfig(FR02_path); ax_FR02 = FR02_plot.Children;
FR03_plot = openfig(FR03_path); ax_FR03 = FR03_plot.Children;
FR04_plot = openfig(FR04_path); ax_FR04 = FR04_plot.Children;


plot_ops.fig_width  = 19.05;
plot_ops.fig_height = 12.7;

plot_ops.space_between_cols = 1.25;
plot_ops.space_between_rows = 0.75;
plot_ops.conf_mat_width     = 11;


plot_ops.x_axis_font_size = 8;
plot_ops.unit_label_font_size = 8;
plot_ops.amp_ylim         = [-450 -50];
plot_ops.amp_y_label      = 'amplitude (\muV)';

plot_ops.FR_ylim          = [0 7.5];
plot_ops.axis_line_width  = 0.5;

plot_ops.panel_labels = {'A','B','C','D'};
plot_ops.panel_label_weight = 'bold';
plot_ops.panel_label_font_size = '10';
plot_ops.panel_label_font_name = 'Helvetica';
%%

% ----------------------------------------------------------------------- %

n_rows      = ceil(plot_ops.fig_height ./ plot_ops.space_between_rows);
n_rows_mat  = ceil(n_rows / 3);
n_rows_time = floor( ( n_rows-3) / 4);

n_cols = ceil( plot_ops.fig_width ./ plot_ops.space_between_cols );
n_cols_mat  = ceil( plot_ops.conf_mat_width / plot_ops.space_between_cols );
n_cols_time = floor( (n_cols - n_cols_mat - 2)/2 );



figure(69); tcl = tiledlayout(n_rows, n_cols);
% for j = 1 : n_rows*n_cols
%     nexttile(j);
%     plot(nan,nan)
%     xticks({})
%     yticks({})
%     box on
% end


% ----------------------------------------------------------------------- %
% First confusion matrix
span_width   = n_cols_mat;
span_height  = n_rows_mat;
tile_location = 1;

tcl01.Parent = tcl;
tcl01.Layout.Tile = tile_location;
tcl01.Layout.TileSpan = [span_height span_width];
cb01 = tcl01.Children(1).Colormap;
tcl.Children(1).Children(4).Colormap = cb01;
tcl01.Title.String = '12-hour sorting; No Linking';
tcl01.Title.FontSize = 10;
tcl01.Title.FontWeight = 'normal';

% re-assign unit numbers
num_current_units = size( tcl01.Children(4).XAxis.TickLabels, 1);
new_labels = arrayfun( @(x) num2str( x ), 1:num_current_units, 'UniformOutput', false);
tcl01.Children(4).XAxis.TickLabels = new_labels;
% ----------------------------------------------------------------------- %



% ----------------------------------------------------------------------- %
% Second confusion matrix
span_width   = n_cols_mat;
span_height  = n_rows_mat;
tile_location = (4 * (n_rows_time) + 3 )* n_cols - n_rows_mat * n_cols + 1;

tcl02.Parent = tcl;
tcl02.Layout.Tile = tile_location;
tcl02.Layout.TileSpan = [span_height span_width];
cb02 = tcl02.Children(1).Colormap;
tcl.Children(1).Children(4).Colormap = cb02;
tcl02.Title.String = '12-hour sorting; With Linking';
tcl02.Title.FontSize = 10;
tcl02.Title.FontWeight = 'normal';


% re-assign unit numbers
num_current_units = size( tcl02.Children(4).XAxis.TickLabels, 1);
new_labels = arrayfun( @(x) num2str( x ), 1:num_current_units, 'UniformOutput', false);
tcl02.Children(4).XAxis.TickLabels = new_labels;
% ----------------------------------------------------------------------- %



% ----------------------------------------------------------------------- %
% First amplitude
span_width  = n_cols_time;
span_height = n_rows_time;
tile_location = n_cols_mat + 2;

ax_a01.Parent = tcl;
ax_a01.Layout.Tile     = tile_location;
ax_a01.Layout.TileSpan = [span_height span_width];
ax_a01.YAxis.Limits = plot_ops.amp_ylim;
ax_a01.YAxis.Label.String  = plot_ops.amp_y_label;
ax_a01.LineWidth = plot_ops.axis_line_width;
text(max(xlim), ...
     min(ylim), ...
     'NL8', ...
     'FontSize',plot_ops.unit_label_font_size, ...
     'VerticalAlignment','bottom', ...
     'HorizontalAlignment','right')
ax_a01.XAxis.TickLabelRotation = 0;
% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% Second amplitude
span_width  = n_cols_time;
span_height = n_rows_time;
tile_location = (n_rows_time+1)*n_cols + n_cols_mat + 2;

ax_a02.Parent = tcl;
ax_a02.Layout.Tile     = tile_location;
ax_a02.Layout.TileSpan = [span_height span_width];
ax_a02.YAxis.Limits = plot_ops.amp_ylim;
ax_a02.YAxis.Label.String  = plot_ops.amp_y_label;
ax_a02.LineWidth = plot_ops.axis_line_width;
nexttile(tile_location)
text(max(xlim), ...
     min(ylim), ...
     'NL15', ...
     'FontSize',plot_ops.unit_label_font_size, ...
     'VerticalAlignment','bottom', ...
     'HorizontalAlignment','right')

ax_a02.XAxis.TickLabelRotation = 0;
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% Third amplitude
span_width  = n_cols_time;
span_height = n_rows_time;
tile_location = 2*(n_rows_time + 1)*n_cols + n_cols_mat + 2;

ax_a03.Parent = tcl;
ax_a03.Layout.Tile     = tile_location;
ax_a03.Layout.TileSpan = [span_height span_width];
ax_a03.YAxis.Limits = plot_ops.amp_ylim;
ax_a03.YAxis.Label.String  = plot_ops.amp_y_label;
ax_a03.LineWidth = plot_ops.axis_line_width;
nexttile(tile_location)
text(max(xlim), ...
     min(ylim), ...
     'WL8', ...
     'FontSize',plot_ops.unit_label_font_size, ...
     'VerticalAlignment','bottom', ...
     'HorizontalAlignment','right')

ax_a03.XAxis.TickLabelRotation = 0;
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% Fourth amplitude
span_width  = n_cols_time;
span_height = n_rows_time;
tile_location = 3*(n_rows_time + 1)*n_cols + n_cols_mat + 2;

ax_a04.Parent = tcl;
ax_a04.Layout.Tile     = tile_location;
ax_a04.Layout.TileSpan = [span_height span_width];
ax_a04.YAxis.Limits = plot_ops.amp_ylim;
ax_a04.YAxis.Label.String  = plot_ops.amp_y_label;
ax_a04.LineWidth = plot_ops.axis_line_width;
nexttile(tile_location)
text(max(xlim), ...
     min(ylim), ...
     'GT8', ...
     'FontSize',plot_ops.unit_label_font_size, ...
     'VerticalAlignment','bottom', ...
     'HorizontalAlignment','right')
ax_a04.XAxis.Label.String = 'Time (hours)';

ax_a04.XAxis.TickLabelRotation = 0;
% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% First Firing rate
span_width  = n_cols_time;
span_height = n_rows_time;
tile_location = n_cols_mat + 1 + n_cols_time + 2;

ax_FR01.Parent = tcl;
ax_FR01.Layout.Tile     = tile_location;
ax_FR01.Layout.TileSpan = [span_height span_width];
ax_FR01.XAxis.FontSize = plot_ops.x_axis_font_size;
ax_FR01.YAxis.FontSize = plot_ops.x_axis_font_size;
ax_FR01.LineWidth = plot_ops.axis_line_width;
ax_FR01.YAxis.Limits = plot_ops.FR_ylim;
ax_FR01.XAxis.Label.String = '';

ax_FR01.XAxis.TickLabelRotation = 0;
% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% Second Firing rate
span_width  = n_cols_time;
span_height = n_rows_time;
tile_location = (n_rows_time + 1)*n_cols + n_cols_mat + 1 + n_cols_time + 2;

ax_FR02.Parent = tcl;
ax_FR02.Layout.Tile     = tile_location;
ax_FR02.Layout.TileSpan = [span_height span_width];
ax_FR02.XAxis.FontSize = plot_ops.x_axis_font_size;
ax_FR02.YAxis.FontSize = plot_ops.x_axis_font_size;
ax_FR02.LineWidth = plot_ops.axis_line_width;
ax_FR02.YAxis.Limits = plot_ops.FR_ylim;
ax_FR02.XAxis.Label.String = '';

ax_FR02.XAxis.TickLabelRotation = 0;
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% Third Firing rate
span_width  = n_cols_time;
span_height = n_rows_time;
tile_location = 2*(n_rows_time + 1)*n_cols + n_cols_mat + 1 + n_cols_time + 2;

ax_FR03.Parent = tcl;
ax_FR03.Layout.Tile     = tile_location;
ax_FR03.Layout.TileSpan = [span_height span_width];
ax_FR03.XAxis.FontSize = plot_ops.x_axis_font_size;
ax_FR03.YAxis.FontSize = plot_ops.x_axis_font_size;
ax_FR03.LineWidth = plot_ops.axis_line_width;
ax_FR03.YAxis.Limits = plot_ops.FR_ylim;
ax_FR03.XAxis.Label.String = '';

ax_FR03.XAxis.TickLabelRotation = 0;
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% Fourth Firing rate
span_width  = n_cols_time;
span_height = n_rows_time;
tile_location = 3*(n_rows_time + 1)*n_cols + n_cols_mat + 1 + n_cols_time + 2;

ax_FR04.Parent = tcl;
ax_FR04.Layout.Tile     = tile_location;
ax_FR04.Layout.TileSpan = [span_height span_width];
ax_FR04.XAxis.FontSize = plot_ops.x_axis_font_size;
ax_FR04.YAxis.FontSize = plot_ops.x_axis_font_size;
ax_FR04.LineWidth = plot_ops.axis_line_width;
ax_FR04.YAxis.Limits = plot_ops.FR_ylim;
ax_FR04.XAxis.Label.String = 'Time (hours)';

ax_FR04.XAxis.TickLabelRotation = 0;
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %








% Final Resize

set(gcf, 'Units', 'Centimeters')
set(gcf, 'Position', [0 0 1.1*[plot_ops.fig_width  plot_ops.fig_height]])


tcl.TileSpacing = 'none';
tcl.Padding = 'none';


tcl.OuterPosition = [(1-1/1.1)/2*[1 1]  1/1.1 .*[1 1]];