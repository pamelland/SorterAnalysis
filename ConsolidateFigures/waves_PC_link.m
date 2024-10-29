%% waves_PC_link
% 
%% Visualize two chains, through the units linked to them, within a single block,
%% in three ways:
%% (1) Centroid waveforms 
%% (2) Projection of centroid in PC space
%% (3) Location of units in hierarchal trees 
%
% By applying this to several consecutive blocks, where b1.units1 are
% "linked" to b2.units1, b2.units1 "linked" to b3.units1, and so forth, 
% % one can visualize how a chain
% is tracked through the entire recording. 
%
% Uses:
%   ext_ops             options from voltage recording
%   proj_waveforms      projected in PC space? ( nUnits x 268) 
%
%   PC_struct_grouped

% NEEDS TREE INFO FROM cluster_trees_by_file.m

%% Let's see if I have this right: run this 3 times, for 3 consecutive blocks
%% Each block, set unit1 and unit2 to be linked units in a chain.

%% Set blocks and units

block_number    = 2;
units1          = [2 6];
units2          = [14];

%% Set plot options

plot_ops.units1_color   = [0.9 0.4  0];
plot_ops.units2_color   = [0.1 0.6 1];
plot_ops.face_alpha_max = 1;
plot_ops.face_alpha_min = 1;
plot_ops.line_width_max = 2.5;
plot_ops.line_width_min = 1.25;


plot_ops.lgnd_prefix = 'u';


plot_ops.fig_width          = 3;
plot_ops.fig_height_waves   = 4;
plot_ops.fig_height_PCs     = 2;
plot_ops.fig_height_tree    = 5;

plot_ops.font_size = 8;


plot_ops.scatter_mkr_style = 's';
plot_ops.scatter_main_mkr_size = 175;
plot_ops.scatter_main_face_alpha = 0.75;

plot_ops.scatter_background_color  = [0.95 0.95 0.95];
plot_ops.scatter_background_mkr_size  = 125;
plot_ops.scatter_background_face_alpha  = 0.75;
plot_ops.scatter_line_color = 'k';
plot_ops.scatter_line_width = 1;

plot_ops.tree_main_line_width       = 1.75;
plot_ops.tree_background_line_width = 0.75;

%% Figure (1) plot the cluster wave forms

Fs = ext_ops.Fs;
t = ( (0:ext_ops.pre_sp_samps + ext_ops.post_sp_samps) - ext_ops.pre_sp_samps ) ./ Fs * 1000;
idx_list = 1 : size(proj_waveforms{1},2);
idx_list = reshape( idx_list, [], 4);

lgnd_ctr = 1;
lgnd_str = cell(numel(units1) + numel(units2), 1);

figure;
waveform_tiles1 = tiledlayout(4,1);


yMIN = 0;
yMAX = 0;

% Do first unit
for unit1_iter = 1 : numel(units1)
    face_alphas = linspace(plot_ops.face_alpha_min, ...
                         plot_ops.face_alpha_max, ...
                         numel(units1));
    line_widths = fliplr( ...
                    linspace(plot_ops.line_width_min, ...
                             plot_ops.line_width_max, ...
                             numel(units1) ) ...
                        );
    color_interp = linspace(0, 0.75, numel(units1)+1)';
    colors = plot_ops.units1_color + color_interp .* ([1 1 1] - plot_ops.units1_color);


    curr_unit = units1( unit1_iter );
    for chn_iter = 1:4
        idxs = idx_list(:,chn_iter);
        nexttile(chn_iter)
        hold on
        plot(t, proj_waveforms{block_number}(curr_unit,idxs), ...
                'LineWidth', line_widths(unit1_iter), ...
                'Color', [colors(unit1_iter,:) face_alphas(unit1_iter)])
        xlim([t(1) t(end)])
        xticks(-1:0.5:1)
        yMIN = min( yMIN, min(ylim) );
        yMAX = max( yMAX, max(ylim) );
        if chn_iter ~= 4
            xticklabels({});
        else
            xlabel('Time (ms)')
            lgnd_str{lgnd_ctr} = sprintf('%s%d', plot_ops.lgnd_prefix, units1(unit1_iter));
            % lgnd_str{lgnd_ctr} = sprintf('Projected event 5607',curr_unit);
            lgnd_ctr = lgnd_ctr+1;
        end
        grid on
        
    end
end


% Do second unit
for unit2_iter = 1 : numel(units2)
    face_alphas = linspace(plot_ops.face_alpha_min, ...
                         plot_ops.face_alpha_max, ...
                         numel(units2));
    line_widths = fliplr( ...
                    linspace(plot_ops.line_width_min, ...
                             plot_ops.line_width_max, ...
                             numel(units2) ) ...
                        );
    color_interp = linspace(0, 0.75, numel(units2)+1)';
    colors = plot_ops.units2_color + color_interp .* ([1 1 1] - plot_ops.units2_color);


    curr_unit = units2( unit2_iter );
    for chn_iter = 1:4
        idxs = idx_list(:,chn_iter);
        nexttile(chn_iter)
        hold on
        plot(t, proj_waveforms{block_number}(curr_unit,idxs), ...
                'LineWidth', line_widths(unit2_iter), ...
                'Color', [colors(unit2_iter,:) face_alphas(unit2_iter)])
        xlim([t(1) t(end)])
        xticks(-1:0.5:1)
        yMIN = min( yMIN, min(ylim) );
        yMAX = max( yMAX, max(ylim) );
        if chn_iter ~= 4
            xticklabels({});
        else
            xlabel('Time (ms)')
            lgnd_str{lgnd_ctr} = sprintf('%s%d', plot_ops.lgnd_prefix, units2(unit2_iter));
            % lgnd_str{lgnd_ctr} = sprintf('Projected event 5607',curr_unit);
            lgnd_ctr = lgnd_ctr+1;
        end
        grid on
        
    end
end


yMIN = floor( yMIN / 100 ) * 100;
yMAX = ceil(  yMAX / 100 ) * 100;


for tile_iter = 1 : 4
    nexttile(tile_iter)
    ylim([ yMIN yMAX] )
    yticks(yMIN : 100 : yMAX)
    % YTICKS = yticks;
    % yticks(YTICKS)
    XTICKS = xticks;
    xticks(XTICKS)
        box on
    if tile_iter ~=1
        yticklabels({})
    else
        ylabel('\mu V')
        legend(lgnd_str, ...
            'Location','Southwest', ...
            'FontSize', plot_ops.font_size)
        set(gca, 'FontSize', plot_ops.font_size)
    end
end

waveform_tiles1.TileSpacing = 'none';
% waveform_tiles1.Padding = 'compact';

waveform_tiles1.OuterPosition = [0.1 0.1 0.8 0.8];

set(gcf, 'Units', 'inches')
set(gcf, 'Position', [0 0 (1/0.8)*[plot_ops.fig_width plot_ops.fig_height_waves]])
set(gca, 'FontSize', plot_ops.font_size)

%% Figure (2) Plot PC space
[PC_meds_grouped, PC_meds_IDs_grouped] = compute_PC_center(PC_struct_grouped.score, PC_struct_grouped.labels, @mean);




ax_pairs = [2 1; ...
            3 1];


units_grouped = [units1 units2];
figure
PC_tiles = tiledlayout(1,2);
PC_tiles.TileSpacing = 'compact';
PC_tiles.Padding = 'none';

for tile_iter = 1:size(ax_pairs,1)
    nexttile(tile_iter)
    hold on
    coord_1 = ax_pairs(tile_iter, 1);
    coord_2 = ax_pairs(tile_iter, 2);
    
    idxs = 1 : numel( units{block_number} );
    shift = numel( vertcat( units{1:block_number} )) - numel( units{block_number} );
    idxs = idxs + shift;

    background_idxs = idxs( setdiff(1:numel(idxs), units_grouped));

    %   plot medians for units not of interest
    scatter(PC_meds_grouped(background_idxs,coord_1), PC_meds_grouped(background_idxs,coord_2), ...
        plot_ops.scatter_background_mkr_size, ...
        plot_ops.scatter_background_color, ...
        'filled', ...
        plot_ops.scatter_mkr_style, ...
        'MarkerEdgeColor', plot_ops.scatter_line_color, ...
        'MarkerFaceAlpha', plot_ops.scatter_background_face_alpha, ...
        'LineWidth', plot_ops.scatter_line_width)

    %  plot medians for first unit group
    scatter(PC_meds_grouped(idxs(units1),coord_1), PC_meds_grouped(idxs(units1),coord_2), ...
        plot_ops.scatter_main_mkr_size, ...
        plot_ops.units1_color, ...
        'filled', ...
        plot_ops.scatter_mkr_style, ...
        'MarkerEdgeColor', plot_ops.scatter_line_color, ...
        'MarkerFaceAlpha', plot_ops.scatter_main_face_alpha, ...
        'LineWidth', plot_ops.scatter_line_width)

    %  plot medians for second unit group
    scatter(PC_meds_grouped(idxs(units2),coord_1), PC_meds_grouped(idxs(units2),coord_2), ...
        plot_ops.scatter_main_mkr_size, ...
        plot_ops.units2_color, ...
        'filled', ...
        plot_ops.scatter_mkr_style, ...
        'MarkerEdgeColor', plot_ops.scatter_line_color, ...
        'MarkerFaceAlpha', plot_ops.scatter_main_face_alpha, ...
        'LineWidth', plot_ops.scatter_line_width)


    text(PC_meds_grouped(idxs(units_grouped),coord_1), ...
         PC_meds_grouped(idxs(units_grouped),coord_2), ...
         num2cell( units_grouped ), ...
         'HorizontalAlignment','center', ...
         'VerticalAlignment','middle', ...
         'FontSize', plot_ops.font_size, ...
         'Color','k', ...
         'HandleVisibility','off', ...
         'FontWeight', 'bold')
    % if tile_iter == 1
    %     legend('s1', 's2','s3', 's4')
    % end

    if tile_iter == 1
        xlabel(sprintf('PC %d', coord_1), 'FontSize',plot_ops.font_size)
        ylabel(sprintf('PC %d', coord_2), 'FontSize',plot_ops.font_size)
        YTICKS = yticks();
        yticks(YTICKS);
    else
        xlabel(sprintf('PC %d', coord_1), 'FontSize',plot_ops.font_size)
        yticklabels({})
        ylabel('')
        yticks(YTICKS)
    end
    grid on
end

nexttile(1)

PC_tiles.OuterPosition = [0.1 0.1 0.8 0.8];
set(gcf, 'Units', 'inches')
set(gcf, 'Position', [0 0 (1/0.8)*[plot_ops.fig_width plot_ops.fig_height_PCs]])


%% Figure (3): Plot hierarchal trees

clear Y Z input_data

idxs  = 1 : numel( units{block_number} );
shift = numel( vertcat( units{1:block_number} )) - numel( units{block_number} );
idxs  = idxs + shift;
input_data = PC_meds_grouped(idxs,1:ops.nPCs);





% - pairwise distances - %
Y = pdist( input_data );

% - compute linkage
Z = linkage(Y,ops.linkage_method);


% - plot trees
% - plot dendrogram (tree 1) - %
figure
d1 = dendrogram(Z, 0, 'orientation', 'left');
set(d1, 'LineWidth',plot_ops.tree_background_line_width);
set(d1, 'Color', 'k')
set(gca, 'FontSize', 12);
yticklabel_str = str2num( yticklabels );
yticklabels( units{block_number}(yticklabel_str));

% -- adjust line colors and ylabels -- %

% first find where the first units 
containing_nodes = cellfun(@(x) sum( ismember(units1, x) ) & numel(x)<=numel(units1) , tree_cell{block_number}(:,3));
first_node = find( containing_nodes ) - n_units{block_number};
first_node = first_node( first_node > 0);
set(d1(first_node), 'Color', plot_ops.units1_color)
set(d1(first_node), 'LineWidth', plot_ops.tree_main_line_width)
y_ticks1 = find( ismember(yticklabel_str, units1) );
text( 0.*y_ticks1, y_ticks1, ...
    num2cell(units1), ...
    'FontWeight','normal', ...
    'BackgroundColor', plot_ops.units1_color, ...
    'Margin',0.1, ...
    'FontSize',7.5)

% Do the same for second units
containing_nodes = cellfun(@(x) sum( ismember(units2, x) ) & numel(x)<=numel(units2) , tree_cell{block_number}(:,3));
first_node = find( containing_nodes ) - n_units{block_number};
first_node = first_node( first_node > 0);
set(d1(first_node), 'Color', plot_ops.units2_color)
set(d1(first_node), 'LineWidth', plot_ops.tree_main_line_width)
y_ticks2 = find( ismember(yticklabel_str, units2) );
text( 0.*y_ticks2, y_ticks2, ...
    num2cell(units2), ...
    'FontWeight','normal', ...
    'BackgroundColor', plot_ops.units2_color, ...
    'Margin',0.01, ...
    'FontSize',7.5)
yticklabels({})
yticks([])

xlim([0 Z(end,3)])
ylim(ylim + [0.5 -0.5])


xticks(linspace(0,Z(end,3),5))
xticklabels({'1', '0.75', '0.5', '0.25', '0'})
xlabel('Linkage score', 'FontSize', 8)
set(gca, 'FontSize', plot_ops.font_size)
set(gca, 'TickDir', 'out')

set(gcf, 'Units', 'Inches')
set(gcf, 'Position', [0 0 (1/0.8)*[plot_ops.fig_width  plot_ops.fig_height_tree]])
set(gca, 'OuterPosition', [0.1 0.1 0.8 0.8])