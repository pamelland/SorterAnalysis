%%
ext_ops.Fs              = 30000;    % sampling freq
ext_ops.n_waves_ext     = 1000;     % number of waves to extract
ext_ops.num_chn         = 4;        % channels in bin
ext_ops.bin_path        = paths.bin_file;
ext_ops.pre_sp_samps    = 33; %16               % time samples before spike
ext_ops.post_sp_samps   = 33; %43 % time samples after spike
ext_ops.t_shift_flag    = true; % do we need to account for concatenated shifts
%% extract waveforms from spike train in workspace (st1, here)

% set spike train
st = st2;

units_to_extract = unique(st(:,2)); % or user select e.g., [1 5 6]
% units_to_extract = [1 5 6];

% waves_cell{1,j} = waveforms of unit j
% waves_cell{2,j} = # of waves extracted
% waves_cell{3,j} = unit #
% waves_cell{4,j} = max chn in descending order
% waves_cell{4,j} = peak amplitude in descending order (well, ascending
%                                                       since they are 
%                                                       negative
%                                                       potentials)

waves_cell = extract_waveforms(st, units_to_extract, ext_ops);

% option to save waves_cell



save( fullfile(paths.sorted_spikes,'waveforms.mat'), 'waves_cell','-v7.3');
