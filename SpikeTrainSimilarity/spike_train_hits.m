%% Note: this currently assumes "paths.sorted_spikes" points directly to
%% sorted results, rather than to a parent directory that contains multiple blocks. 
% %% Need to encapsulate this.
%% Need the function ccg.

% Calls: prep_SI_for_spike_train, prep_KS_for_spike_train,
%   prep_BP_for_spike_train, hit_miss_2trains
% 


%% First we establish two spike trains. st_base  & st_comp
% =========================================================================
% st_base --> the baseline (or "ground truth" spikes)
% st_comp --> the sequence of extracted spikes to compare to st_base

% and some hyperparameters
% Q_base -->  fcontamination (Q) cut off for base (unused with BP data)
% R_base -->  rmax (R) cut off for base (unused with BP data)
% Q_comp -->  fcontamination (Q) cut off for base (unused with BP data)
% R_comp -->  rmax (R) cut off for base (unused with BP data)
% Fs --> sampling rate

Q_base = inf;
R_base = inf;

Q_comp = inf;
R_comp = inf;

Fs = 30000; % Hz
% TETS = [7 12 13 17];
TETS = [1];
restrict_multi_tet_temps = false;
% t_cut --> time to cut (typically because BP data has all 24 hours sorted)
t_start = [10] .* 60 * 60;
t_end   = [22] .* 60 * 60; % in seconds
% =========================================================================





% =========================================================================
% st_base
% Use BP data as st_base
bp_ops.time_start = t_start;
bp_ops.time_end = t_end;
bp_ops.bp_tets  = TETS;
% BP ground truth
% load('/Volumes/PM-HD/KilosortRez/Spike_Data.mat');

% Zenodo ground truth
paths.ground_truth = '/Users/andreakbarreiro/Dropbox/MyProjects_Current/Pake/FUSE/GroundTruth/0000-0120/Spike_Data.mat';
%
load(paths.ground_truth);

% option to take a subset of only GT spikes for FAST spikes --- discards
% background spikes
st1_top8 = ismember( Spike_Data(:,2), 1:8);
Spike_Data = Spike_Data(st1_top8,:);
[st1, base_tets] = prep_BP_for_spike_train(Spike_Data, bp_ops);
% =========================================================================

%% OPTION to process kilosort (KS) sorter output
% =========================================================================
% st_comp.  
% Use KS run as st_comp.  Only keep good units according to a cutoff and 
% those assodicate with a tetrode in tetrode_list.
% ks_ops.time_cut  = t_end;
% ks_ops.Q_comp    = Q_comp;
% ks_ops.R_comp    = R_comp;
% ks_ops.ks_tets   = TETS;
% ks_ops.base_tets = base_tets;
% ks_ops.restrict_multi_tet_temps = restrict_multi_tet_temps;
% 
% [st2, comp_table2, kept_units2] = prep_KS_for_spike_train(rez, ks_ops);

%% OPTION TO PROCESS MOUNTAINSORT (MS) SORTER OUTPUT
% alernate spike train from spike interface
% have to manually associate units with a tetrode (could do it if we have
% .bin file)

% ----------------------------------------------------------------------- %
% - possible MS to load - %


paths.sorted_spikes = '/Users/andreakbarreiro/Dropbox/MyProjects_Current/Pake/FUSE/Local_Sorter_Output/0000-0120/';
%
%paths.sorted_spikes = [paths.sorted_spikes '0000-0120/'];
% % - ZENODO %
SI = load( fullfile(paths.sorted_spikes,'firings_adjusted.mat') );
load( fullfile(paths.sorted_spikes,'unit_map.mat') ); % loads unit_map


SI.unit_map = unit_map;
SI_ops.time_start  = t_start;
SI_ops.time_end    = t_end;
SI_ops.Q_comp      = Q_comp;
SI_ops.R_comp      = R_comp;
SI_ops.ks_tets     = TETS;
SI_ops.base_tets   = base_tets;
SI_ops.restrict_multi_tet_temps = restrict_multi_tet_temps;

[st2, comp_table2, kept_units2] = prep_SI_for_spike_train(SI, SI_ops);

%% Now we calculate hits & misses
n_buff = 4; %% +/- # samples buffer for allowing hits

st1_units = sort( unique( st1(: , 2) ) );
st2_units = sort( unique( st2(: , 2) ) );

num_st1_units = numel( st1_units );
num_st2_units = numel( st2_units );
spike_count_mat = zeros( num_st1_units, num_st2_units );
spike_count_near_mat = zeros( num_st1_units, num_st2_units );
spike_perc_mat = zeros( num_st1_units, num_st2_units );
spike_perc_near_mat = zeros( num_st1_units, num_st2_units );

% =========================================================================

for unit_iter = 1 : num_st1_units
    unit_no = st1_units( unit_iter );

    st_base_unit = st1( st1(:,2) == unit_no, :);
    base_tet = st_base_unit(1,3);
    hit_struct_temp = hit_miss_2trains(st_base_unit, ...
                                  base_tet, ...
                                  st2, ...
                                  Fs , ...
                                  n_buff);
    hit_cell{unit_iter} = hit_struct_temp;
    hit_rate = sum( [hit_struct_temp(:).hit]) / numel( hit_struct_temp );

    cur_temps = unique( vertcat( hit_struct_temp.temps ) );
    cur_temps = cur_temps( ~isnan( cur_temps) );

    temps_cell = {hit_struct_temp.temps};
    nearest_cell = {hit_struct_temp.closest_temp};
    for temp_iter = 1 : numel( cur_temps )
        temp_no = cur_temps( temp_iter);

        temp_spikes = sum( cellfun( @(m) ismember(temp_no, m), temps_cell ) );
        temp_spikes_near = sum( cellfun( @(m) ismember(temp_no, m), nearest_cell ) );

        temp_spikes_perc = temp_spikes / numel(hit_struct_temp);
        temp_spikes_near_perc = temp_spikes_near / numel(hit_struct_temp);

        spike_count_mat( unit_iter, temp_no) = temp_spikes;
        spike_count_near_mat( unit_iter, temp_no) = temp_spikes_near;

        spike_perc_mat( unit_iter, temp_no) = temp_spikes_perc;
        spike_perc_near_mat( unit_iter, temp_no) = temp_spikes_near_perc;
    end


fprintf('**\nUnit %d had a hit rate of %0.2f%%\n\n', unit_no, hit_rate*100)

end
% =========================================================================
%%
% delete columns for temps that were not good

spike_count_mat( : , setdiff( 1:size(spike_count_mat,2), st2_units) ) = [];
spike_count_near_mat( : , setdiff( 1:size(spike_count_near_mat,2), st2_units) ) = [];
spike_perc_mat( : , setdiff( 1:size(spike_perc_mat,2), st2_units) ) = [];
spike_perc_near_mat( : , setdiff( 1:size(spike_perc_near_mat,2), st2_units) ) = [];


%% metrics

% use spike_count_near_mat --> that only allows one sorted unit to be
%                              matched to a specific GT event

% get total number of spikes for each GT unit
num_spikes_GT = get_num_spikes( st1, st1_units );
num_spikes_GT = num_spikes_GT(:); % make it a column vector

% get total number of spikes for each SS unit
num_spikes_SS = get_num_spikes( st2, st2_units );
num_spikes_SS = num_spikes_SS(:)'; % make it a row vectorx

% -------------------------------------------------------------------------
% number of matches

% 'Note that even if more than one sorted event falls within ±D of a true...
%  event, at most one is counted in this matching' ---> This *could* (and
%  likely does) refer to multiple instances of a single sorted unit
%    --> In this case use spike_count_mat

n_match = spike_count_near_mat;

% n_match = spike_count_mat;
% -------------------------------------------------------------------------


% number of GT units missed
n_miss  = num_spikes_GT - n_match;

% number of SS unit false positives
n_fp    = num_spikes_SS - n_match;

% accuracy
Accuracy_mat    = n_match ./ ( n_match + n_miss + n_fp);
% precision
precision_mat   = n_match ./ (n_match + n_fp);
[accuracy, matched_SS] = max(Accuracy_mat, [], 2);

% score
score_mat = n_match ./ (num_spikes_GT + num_spikes_SS - n_match);

% generate (GT, SS) pairs with index matching GT unit number
GT_SS_match = [st1_units(:), kept_units2(matched_SS(:))];

% compute precision & recall with matches only
precision = nan( numel( st1_units ), 1);
recall = nan( numel( st1_units ), 1);
for GT_iter = 1 : numel( st1_units )
    SS_temp = matched_SS(GT_iter);
    precision(GT_iter) = n_match(GT_iter, SS_temp ) ./ ...
                   (n_match(GT_iter,SS_temp) + n_fp(GT_iter,SS_temp));
    recall(GT_iter) = n_match(GT_iter, SS_temp) ./ ...
                   ( n_match(GT_iter,SS_temp) + n_miss(GT_iter,SS_temp) );
end

avg_accuracy = mean( accuracy );
avg_precision = mean( precision );
avg_recall = mean( recall );

wtd_avg_accuracy = sum(accuracy .* num_spikes_GT) ./ sum( num_spikes_GT );
wtd_avg_precision = sum(precision .* num_spikes_GT) ./ sum( num_spikes_GT );
wtd_avg_recall = sum(recall .* num_spikes_GT) ./ sum( num_spikes_GT );

fprintf('\n** Accuracy ** average = %0.2f; weighted average = %0.2f\n',...
		avg_accuracy, wtd_avg_accuracy)
fprintf('\n** Precision ** average = %0.2f; weighted average = %0.2f\n',...
		avg_precision, wtd_avg_precision)
fprintf('\n** Recall ** average = %0.2f; weighted average = %0.2f\n',...
		avg_recall, wtd_avg_recall)
%% Imagesc by tetrode
clc
% --- save figure ?? --- %
save_fig = false;
% ---------------------- %

tet_list = 1;
mat_plot = n_match;
log10_bool = true; % take log10 of main heat map?
% Get units on these tetrodes
unit_list = sort( unique( st1( ismember(st1(:,3), tet_list),2 ) ) ) ;
rows_to_keep = idx_lookup( st1_units, unit_list );

% get templates for these tetrodes
temp_list = sort( unique( st2( ismember(st2(:,3), tet_list),2 ) ) ) ;
cols_to_keep = idx_lookup( st2_units, temp_list );

mat_plot = mat_plot(rows_to_keep, cols_to_keep);

figure
n_tile_rows = numel( rows_to_keep ) + 3;
n_tile_cols = numel( cols_to_keep ) + 5;
heat_tiles = tiledlayout(n_tile_rows,n_tile_cols);

% =========================================================================
% main heat map
if log10_bool
    mat_plot_temp = log10(mat_plot);
else
    mat_plot_temp = mat_plot;
end
nexttile(3*n_tile_cols+1, [n_tile_rows-3 n_tile_cols-5])
imagesc(1:numel(cols_to_keep), ...
        1:numel(rows_to_keep), ...
        mat_plot_temp)
clear mat_plot_temp
colormap(teal_map())

ax = gca;
% ax.FontSize = 16;
ax.FontSize = 12;
% box_fsize = 12;
box_fsize = 9; %8
% small_fsize = 10;
small_fsize = 9; %8
[xx, yy] = meshgrid( 1:numel(cols_to_keep), 1:numel(rows_to_keep) );
xx = xx(:);
yy = yy(:);

labels = mat_plot(:);
label_idxs = labels >= 0.00;

labels = labels( label_idxs );
xx = xx( label_idxs );
yy = yy( label_idxs );

if max( max( mat_plot ) ) > 1
    formatSpec = '%d';
else
    formatSpec = '%0.2f';
end

% loop or else numbers are not centered
for j = 1 : numel(labels)
    text(xx(j), ...
         yy(j), ...
         num2str(labels(j),formatSpec), ...
         'VerticalAlignment', 'middle', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', box_fsize)
end
clear xx yy
box off

ax.XTick = (1:numel(cols_to_keep));
ax.YTick = (1:numel(rows_to_keep));
ax.XTickLabel = (temp_list);
ax.YTickLabel = (unit_list);

ax.XTickLabelRotation = 90;
ax.TickDir = 'out';
ax_LW = ax.XAxis.LineWidth;
line([max(xlim) .* [1 1]; xlim]', [ylim; min(ylim).*[1 1]]', ...
    'Color', [0.15 0.15 0.15], ...
    'LineWidth', ax_LW)

% draw boxes for highest accuracy assignmen
unit_idxs = idx_lookup( st1_units, unit_list );
for acc_iter = 1 : numel( unit_list )
    xx = GT_SS_match(unit_idxs(acc_iter),2);
    xx = idx_lookup(temp_list, xx);
    yy = acc_iter;
    if ~isempty(xx)
        patch([xx-0.5  xx+0.5  xx+0.5  xx-0.5], ...
              [yy-0.5  yy-0.5  yy+0.5  yy+0.5], ...
              'w', ...
              'FaceColor', 'none', ...
              'EdgeColor', 0.95*[1 1 0], ...
              'LineWidth', 3.5)
    end
end

% Hungarian matching
Mpairs = matchpairs( -mat_plot, 0);
MMpairs = [unit_list( Mpairs(:,1) )  temp_list(Mpairs(:,2)) ];
% box Matched algorithm
for mp = 1:size(Mpairs,1)
    xx = Mpairs(mp,2);
    yy = Mpairs(mp,1);

    patch([xx-0.5  xx+0.5  xx+0.5  xx-0.5], ...
          [yy-0.5  yy-0.5  yy+0.5  yy+0.5], ...
          'w', ...
          'FaceColor', 'none', ...
          'EdgeColor', 0.35*[0 1 1], ...
          'LineWidth', 2)
end



% =========================================================================

% =========================================================================
% add column for row sums
unit_row_sum = sum( mat_plot, 2);

teal_unit_map = teal_map(numel( unit_row_sum ) );

nexttile(4*n_tile_cols-4, [n_tile_rows-3  1]);
imagesc(1,1:numel(rows_to_keep), log10(unit_row_sum))
ax = gca;
colormap( ax, teal_unit_map)
xticks([])
yticks([])
xlabel(sprintf('unit\nhits'),'FontSize', 16, ...
    'HorizontalALignment', 'center')

if max( unit_row_sum ) > 10
    formatSpec = '%d';
else
    formatSpec = '%0.2f';
end
for j = 1: numel(rows_to_keep)
    text(1, ...
         j, ...
         num2str(unit_row_sum(j), formatSpec), ...
         'VerticalAlignment', 'middle', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', box_fsize)
end
% =========================================================================


% =========================================================================
% add column for number of unit spikes
num_unit_spikes = get_num_spikes( st1, unit_list);

maroon_unit_map = maroon_map(numel( num_unit_spikes ) );

nexttile(4*n_tile_cols-3, [n_tile_rows-3  1]);
imagesc(1,1:numel(rows_to_keep), log10(num_unit_spikes))
ax = gca;
colormap( ax, maroon_unit_map)
xticks([])
yticks([])
xlabel(sprintf('unit\ncount'),'FontSize', 16, ...
    'HorizontalALignment', 'center')

formatSpec = '%d';

for j = 1 : numel(rows_to_keep)
    text(1, ...
         j, ...
         num2str(num_unit_spikes(j), formatSpec), ...
         'VerticalAlignment', 'middle', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', box_fsize)
end
% =========================================================================

% =========================================================================
% add column for accuracy
acc_temp = accuracy( idx_lookup(st1_units, unit_list) );
yellow_map_map = yellow_map(numel( acc_temp ) );

nexttile(4*n_tile_cols-2, [n_tile_rows-3  1]);
imagesc(1,1:numel(rows_to_keep), acc_temp)
ax = gca;
colormap( ax, yellow_map_map)
caxis([0 1])
xticks([])
yticks([])
xlabel(sprintf('acc'),'FontSize', 16, ...
    'HorizontalALignment', 'center')

formatSpec = '%0.2f';

for j = 1 : numel(rows_to_keep)
    text(1, ...
         j, ...
         num2str(acc_temp(j), formatSpec), ...
         'VerticalAlignment', 'middle', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', box_fsize)
end

% add header for mean
unit_idxs = idx_lookup(st1_units, unit_list);
num_spikes_GT_tet = num_spikes_GT( unit_idxs );
true_mean   = mean(acc_temp);
weight_mean = sum( acc_temp .* num_spikes_GT_tet ) ./ sum( num_spikes_GT_tet);
text(1, 0, ...
    num2str(true_mean, formatSpec), ...
         'VerticalAlignment', 'bottom', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', small_fsize)
text(1, 0, ...
    num2str(weight_mean, formatSpec), ...
         'VerticalAlignment', 'top', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', small_fsize)


% =========================================================================

% =========================================================================
% add column for precision
prec_temp = precision( idx_lookup(st1_units, unit_list) );
yellow_map_map = yellow_map(numel( prec_temp ) );

nexttile(4*n_tile_cols-1, [n_tile_rows-3  1]);
imagesc(1,1:numel(rows_to_keep), prec_temp)
ax = gca;
colormap( ax, yellow_map_map)
caxis([0 1])
xticks([])
yticks([])
xlabel(sprintf('prec'),'FontSize', 16, ...
    'HorizontalALignment', 'center')

formatSpec = '%0.2f';

for j = 1 : numel(rows_to_keep)
    text(1, ...
         j, ...
         num2str(prec_temp(j), formatSpec), ...
         'VerticalAlignment', 'middle', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', box_fsize)
end

% add header for mean
unit_idxs = idx_lookup(st1_units, unit_list);
num_spikes_GT_tet = num_spikes_GT( unit_idxs );
true_mean   = mean(prec_temp);
weight_mean = sum( prec_temp .* num_spikes_GT_tet ) ./ sum( num_spikes_GT_tet);
text(1, 0, ...
    num2str(true_mean, formatSpec), ...
         'VerticalAlignment', 'bottom', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', small_fsize)
text(1, 0, ...
    num2str(weight_mean, formatSpec), ...
         'VerticalAlignment', 'top', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', small_fsize)
% =========================================================================


% =========================================================================
% add column for recall

recall_temp = recall( idx_lookup(st1_units, unit_list) );
yellow_map_map = yellow_map(numel( recall_temp ) );

nexttile(4*n_tile_cols, [n_tile_rows-3  1]);
imagesc(1,1:numel(rows_to_keep), recall_temp)
ax = gca;
colormap( ax, yellow_map_map)
caxis([0 1])
xticks([])
yticks([])
xlabel(sprintf('recall'),'FontSize', 16, ...
    'HorizontalALignment', 'center')

formatSpec = '%0.2f';

for j = 1 : numel(rows_to_keep)
    text(1, ...
         j, ...
         num2str(recall_temp(j), formatSpec), ...
         'VerticalAlignment', 'middle', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', box_fsize)
end
% add header for mean
unit_idxs = idx_lookup(st1_units, unit_list);
num_spikes_GT_tet = num_spikes_GT( unit_idxs );
true_mean   = mean(recall_temp);
weight_mean = sum( recall_temp .* num_spikes_GT_tet ) ./ sum( num_spikes_GT_tet);
text(1, 0, ...
    num2str(true_mean, formatSpec), ...
         'VerticalAlignment', 'bottom', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', small_fsize)
text(1, 0, ...
    num2str(weight_mean, formatSpec), ...
         'VerticalAlignment', 'top', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', small_fsize)
% =========================================================================

% =========================================================================
% add row for matched temps
temp_col_sum = sum( mat_plot, 1);

teal_temp_map = teal_map(numel( temp_col_sum ) );

nexttile(2*n_tile_cols+1, [1  n_tile_cols-5]);
imagesc(1:numel(cols_to_keep),1, log10(temp_col_sum))
ax = gca;
colormap( ax, teal_temp_map)
xticks([])
yticks([])

ylabel(sprintf('temp hits'),'FontSize', 16, ...
    'HorizontalALignment', 'right', ...
    'VerticalAlignment', 'middle', ...
    'Rotation', 0)

if max( temp_col_sum ) > 10
    formatSpec = '%d';
else
    formatSpec = '%0.2f';
end

for j = 1 : numel(cols_to_keep)
    text(j, ...
         1, ...
         num2str(temp_col_sum(j), formatSpec), ...
         'VerticalAlignment', 'middle', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', box_fsize)
end
% =========================================================================

% =========================================================================
% add row for temp_totals
num_temp_spikes = get_num_spikes( st2, temp_list);

orange_temp_map = orange_map(numel( num_temp_spikes ) );

nexttile(n_tile_cols+1, [1  n_tile_cols-5]);
imagesc(1:numel(cols_to_keep),1, log10(num_temp_spikes'))
ax = gca;
colormap( ax, orange_temp_map)
xticks([])
yticks([])
ylabel(sprintf('temp count'),'FontSize', 16, ...
    'HorizontalALignment', 'right', ...
    'VerticalAlignment', 'middle', ...
    'Rotation', 0)

formatSpec = '%d';

for j = 1 : numel(cols_to_keep)
    text(j, ...
         1, ...
         num2str(num_temp_spikes(j), formatSpec), ...
         'VerticalAlignment', 'middle', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', box_fsize)
end
% =========================================================================



% =========================================================================
% add row for Q / R
Q_scores = comp_table2.Q( ismember( temp_list, temp_list(1):temp_list(end)) );
R_scores = comp_table2.R( ismember( temp_list, temp_list(1):temp_list(end)) );


nexttile(1, [1  n_tile_cols-5]);
imagesc(1:numel(cols_to_keep),1, Q_scores'+R_scores')

ax = gca;
colormap( ax, white);

% patch those whose Q > 0.1 or R > 0.2 (kilosort default)
for j = 1:numel( Q_scores )
    if Q_scores(j) < 0.1 && R_scores(j) < 0.2
        continue
    else

    patch([j-0.5  j+0.5  j+0.5  j-0.5], ...
          [1-0.5  1-0.5  1+0.5  1+0.5], ...
          [0.75 0.75 0.75], ...
          'EdgeColor', 'none', ...
          'LineWidth', 2)
    end
end
caxis([0 1])
xticks([])
yticks([])
ylabel(sprintf('Q\nR'),'FontSize', 12, ...
    'HorizontalALignment', 'right', ...
    'VerticalAlignment', 'middle', ...
    'Rotation', 0)

formatSpec = '%d';

for j = 1 : numel(Q_scores)
    text(j, ...
         1, ...
         sprintf('%0.2f\n%0.2f', Q_scores(j), R_scores(j)), ...
         'VerticalAlignment', 'middle', ...
         'HorizontalAlignment', 'center', ...
         'FontWeight', 'bold', ...
         'Color', [0 0 0], 'FontSize', small_fsize)
end
% =========================================================================


% =========================================================================
% tile options
% heat_tiles.Title.String = sprintf('Tetrode %d; Q cut = %0.2f R cut = %0.2f', ...
%                                     tet_list, Q_comp, R_comp);
heat_tiles.Title.FontWeight = 'normal';
heat_tiles.Title.FontSize = 20;

heat_tiles.TileSpacing = 'compact';
heat_tiles.Padding = 'compact';

f_height = 640 * n_tile_rows / 16;
f_width  = 950 * n_tile_cols / 16;

screen_dim = get(0, 'screensize');
set(gcf, 'Position', [screen_dim(3)/2 - f_width/2, ...
                      screen_dim(4), ...
                      f_width, ...
                      f_height])
heat_tiles.Title.String = sprintf('Window (in hours): %02d-%02d',round( [t_start t_end] ./ 60 ./ 60));
heat_tiles.Title.FontWeight = 'normal';
if save_fig
    fig_path = '/Users/pakemelland/Desktop/ConfusionMats'
    % fprintf('\n\n*** Adjust figure width, then press enter ***\n\n')
    % pause(1)
    writeFig(gcf, gcf,fig_path,sprintf('window_%04d-%04d_MS_NON-CONTIGUOUS', round( [t_start t_end] ./ 60)), 'pdf', 300)
end


