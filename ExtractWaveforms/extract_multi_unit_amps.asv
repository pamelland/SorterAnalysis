%%
ext_ops.Fs              = 30000;    % sampling freq
ext_ops.n_amps_ext     = 10000;     % number of waves to extract
ext_ops.num_chn         = 4;        % channels in bin
ext_ops.bin_path        = paths.bin_file;
ext_ops.pre_sp_samps    = 33; %16               % time samples before spike
ext_ops.post_sp_samps   = 33; %43 % time samples after spike
ext_ops.t_shift_flag    = true; % do we need to account for concatenated shifts
ext_ops.sp_time_buff    = 8;    % look for spike in +/ spike time
%% extract waveforms from spike train in workspace (st1, here)

% set spike train
st = st2;

units_to_extract = unique(st(:,2)); % or user select e.g., [1 5 6]
units_to_extract = [6 18];

[amps_cell, st_amps] = extract_amplitudes(st, units_to_extract, ext_ops);

% option to save waves_cell


%%
save( fullfile('./','amplitude_cell_SMUSH.mat'), 'amps_cell','-v7.3');
save( fullfile('./','amplitude_st_SMUSH.mat'), 'st_amps','-v7.3');
