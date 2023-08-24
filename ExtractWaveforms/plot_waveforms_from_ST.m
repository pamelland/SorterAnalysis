function [] = plot_waveforms_from_ST(st, ...
                                                          unit_no, ...
                                                          pars, ...
                                                          plot_ops)
% st = spike train [spike times \\ unit number ]
% unit_no = unit number to plot                                                
% ----------------------------------------------------------------------- %
% extract pars
Fs             = pars.Fs;               % sampling frequency
n_rows         = pars.n_rows;           % rows per waveform plot
n_waves_plot   = pars.n_waves_plot;     % number of waveforms for plot
n_waves_avg    = pars.n_waves_avg;      % number of waveforms for plot
num_chn        = pars.num_chn;          % number of channels in .bin file
bin_path       = pars.bin_path;         % path to binary file
pre_sp_samps   = pars.pre_sp_samps;     % time samples before spike
post_sp_samps  = pars.post_sp_samps;    % time samples after spike
top4_color     = pars.top4_color;       % color for top4 spikes [0-255]
axis_qs        = pars.axis_qs;          % quantiles for axis limits
t_shift_flag   = pars.t_shift_flag;     % do we need to account for concatenatd files?
yMIN           = pars.yMIN;             % set to nan for smart selection
yMAX           = pars.yMAX;             % set to nan for smart selection
% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% find where this unit occurs in spike train and get spike times
spike_locs  = st(:, 2) == unit_no;
spike_times = st( spike_locs, 1);
num_spikes  = numel( spike_times );
% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% Print some messages

% how many total spikes? And print it.
num_spikes = numel( spike_times );
fprintf('\n\n** Unit %d registered a total of %d spikes. **\n', ...
        unit_no, num_spikes);
    
% If we asked to plot too many, then cut back how many can be plotted
if num_spikes < n_waves_plot
    fprintf('\n\n** You requested to plot %d spikes. Only %d spikes can plot. **\n', ... 
            n_waves_plot, num_spikes)
    n_waves_plot = num_spikes;
end

% If we asked to avg too many, then cut it back
if num_spikes < n_waves_avg
    fprintf('\n\n** You requested to average %d spikes. Only %d spikes can average. **\n', ... 
            n_waves_avg, num_spikes)
    n_waves_avg = num_spikes;
end
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% Now lets get a random collection of these waveforms
%  \\ for taking the average, sample from all spike events
avg_waveform_idxs  = randsample( 1:num_spikes, n_waves_avg);

%  \\ for plots, we restrict our samples to those used for the average
plot_waveform_idxs = randsample( 1:n_waves_avg, n_waves_plot);
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% get data path and load t-shift table if necessary
if t_shift_flag
    [data_path, ~, ~] = fileparts( bin_path );
    
    % -- load variable 'BR_conc_table' -- %
    load( fullfile( data_path, 'time_look_up.mat' ) );
    t_shifts       = BR_conc_table.t_shift;
    file_intervals = [BR_conc_table.t_start + [0; t_shifts(2:end)], ...
                      BR_conc_table.t_end + t_shifts];
else
    file_intervals = [0 inf];
    t_shifts    = 0;
end
% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% main loop to build out waveforms [channel x time x event]

fileID = fopen( bin_path); % open waveform .bin file
num_time_points = pre_sp_samps + post_sp_samps + 1; % number of time points

% pre-allocate
spike_mat = nan(num_chn, num_time_points, n_waves_avg);

for spike_iter = 1 : n_waves_avg
    sp_idx   = avg_waveform_idxs( spike_iter );
    sp_time  = spike_times( sp_idx );
    shift_time = t_shifts(  sp_time >= file_intervals(:,1) & sp_time < file_intervals(:,2) );
    sp_time = sp_time - shift_time;
    sp_time_in_samp = round(sp_time * Fs);
    t_start_in_samp = sp_time_in_samp - pre_sp_samps;

    bytes_to_skip = 2 * t_start_in_samp * num_chn; % 2 for 2 bytes in per int16 data

    fseek( fileID, bytes_to_skip, 'bof');
    spike_mat( : , : , spike_iter ) = ...
                        fread(fileID, [num_chn num_time_points], 'int16');
end

% get waveform averages
spike_avg = mean( spike_mat, 3);
% ----------------------------------------------------------------------- %

% ----------------------------------------------------------------------- %
% now we get information for max channels and axis limits
spike_avg_max = min( spike_avg, [], 2); % min for negative potentials
[spike_maxs, spike_ordr] = sort( spike_avg_max, 'ascend'); % channels ordered by amp
top4 = spike_ordr(1:4);
fprintf('\n*** The top 4 channels are: %d %d %d %d ***\n', ...
          top4(1), top4(2), top4(3), top4(4))
fprintf('\n*** The max_values are: %0.1f %0.1f %0.1f %0.1f ***\n', ...
          spike_maxs(1), spike_maxs(2), spike_maxs(3), spike_maxs(4))

% get quantiles to set ylimits for plots
spike_mat_vec = spike_mat(:); % vectorize for quantiles
quants_at_spike = quantile( spike_mat_vec, axis_qs ./ 100);

% round to nearest 100 um
if isnan(yMIN)
    % 'smart' selection
    y_min = floor( quants_at_spike(1) / 100 ) * 100;
else
    y_min = yMIN;   % user input
end

if isnan(yMAX)
    % 'smart' selection
    y_max = ceil(  quants_at_spike(2) / 100 ) * 100;
else
    y_max = yMAX;   % user input
end

y_ticks = y_min : 100 : y_max;



% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% now we do the plots
n_cols = ceil( num_chn / n_rows ); % number of columns in tiled layout
t_vec  = ((1 : num_time_points) - (pre_sp_samps+1) ) ./ Fs .* 1000;
other_color = ([255 255 255] - top4_color) ./ 255;
top4_color  = top4_color ./ 255;
chn_list = plot_ops.tet_list(:);
chn_list = chn_list' .* 4 - [3 2 1 0]';
chn_list = chn_list(:);

% create a master look up table to place voltages in tiled layout
tile_idx_look_up = reshape( 1 : n_rows*n_cols, [n_cols n_rows])';


clear fig_temp


figure
chn_tiles = tiledlayout(n_rows, n_cols);

for chn_iter = 1 : num_chn
    if ismember( chn_iter, top4 )
        plot_color = top4_color;
    else
        plot_color = other_color;
    end
    nexttile( tile_idx_look_up(chn_iter) )
    hold on
    plot(t_vec, squeeze( spike_mat(chn_iter, :, plot_waveform_idxs) ), ...
        'Color', [plot_color plot_ops.wave_alpha], ...
        'LineWidth', plot_ops.lw)
    plot(t_vec, spike_avg( chn_iter, : ), ...
        'Color', plot_color, ...
        'LineWidth', plot_ops.avg_lw)
    xlim([t_vec(1) t_vec(end)])
    ylim([y_min y_max])
    XTICKS = xticks;
    xticks(XTICKS);
    if ~ismember(tile_idx_look_up(chn_iter), tile_idx_look_up(end,:))
        xticklabels({})
    end
    
    xticks(XTICKS)
    yticks(y_ticks)
    yticklabels({})
    
    grid on
    box  on
    if chn_iter == num_chn
        line([t_vec(end) t_vec(end)], [y_min y_max], ...
            'Color', 'k', 'LineWidth', 2, ...
            'HandleVisibility', 'off')
        text(t_vec(end), y_min, ...
             sprintf('%d', y_min), ...
             'VerticalAlignment', 'middle', ...
             'HorizontalAlignment', 'left', ...
             'FontSize', 10)
        text(t_vec(end), y_max, ...
             sprintf('%d', y_max), ...
             'VerticalAlignment', 'middle', ...
             'HorizontalAlignment', 'left', ...
             'FontSize', 10)
    end
    ylabel(sprintf('%d', chn_list( chn_iter )))
end

chn_tiles.TileSpacing   = 'tight';
chn_tiles.Padding       = 'compact';
chn_tiles.Title.String  = sprintf('Sorted unit: %d; number of spikes: %d', ...
                                   unit_no, num_spikes);
chn_tiles.XLabel.String = 'Time (ms)';

screen_size = get(0, 'ScreenSize');

fig_width  = screen_size(3)/4 .* n_cols;
fig_height = screen_size(4);
set(gcf, 'Position', [screen_size(3)/2 - fig_width/2, ...
                      1, ...
                      fig_width, ...
                      fig_height])
                  
fclose(fileID);
end


