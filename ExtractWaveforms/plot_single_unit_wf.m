pars.Fs            = 30000;             % sampling frequency
pars.n_rows        = 4;                 % rows per waveform plot
pars.n_waves_plot  = 1000;               % number of waveforms for plot
pars.n_waves_avg   = 1000;               % number of waveforms for average
pars.num_chn       = 4;                % number of channels in .bin file
pars.bin_path      = paths.bin_file;
pars.pre_sp_samps  = 31; %16                % time samples before spike
pars.post_sp_samps = 31; %43                % time samples after spike
pars.top4_color    = [0   52  250];     % color for top4 spikes [0-255]
pars.axis_qs       = [0.1 99.9];      % quantiles for axis limits
pars.t_shift_flag  = true;
pars.yMAX          = nan;               % set to nan for smart selection
pars.yMIN          = nan;              % set to nan for smart selection

%% set a spike train and a unit number
st      = st1; %% spike train already loaded into workspace
unit_no = 5;

%% Or instead, set a ground truth unit (unit_no) and a sorted candidate (sorted_label)
%  Then only keep events of unit_no that overlap with sorted_label
sorted_label = 28;
unit_no      = 10; 
bp_label     = 82; % E.g. BP unit 82 is 10th unit in a batch only containing tetrode 17

% if looking at BP data from Tetrode 17 only (BP units 73 -- 82)
%   and sorted units 5 and 6 are possible matches with BP unit 82. Then
%   set:
%       sorted_label = 5; % then do sorted_label = 6
%       unit_no      = 10;
%       bp_label     = 82;

% For ZENODO (FAST data) data, we only use one tetrode, so unit_no =
%   bp_label

keep_idxs = [hit_cell{bp_label}.hit] == 1 & arrayfun(@(j) ismember(sorted_label,hit_cell{bp_label}(j).temps), 1:numel(hit_cell{bp_label}));
sp_times  = vertcat(hit_cell{bp_label}.spike_time);
st = [sp_times( keep_idxs ) unit_no.*ones(sum(keep_idxs),1)  1.*ones(sum(keep_idxs),1)];
%% plot waveforms
plot_ops.lw = 1;
plot_ops.avg_lw = 2;
plot_ops.wave_alpha = 3 ^ (-ceil(log10(pars.n_waves_plot)));
plot_ops.tet_list = [1];
% plot_ops.wave_alpha = 1;

plot_waveforms_from_ST(st, unit_no, pars, plot_ops);