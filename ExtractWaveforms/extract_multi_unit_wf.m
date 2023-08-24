%%
ext_ops.Fs              = 30000;    % sampling freq
ext_ops.n_waves_ext     = 100;     % number of waves to extract
ext_ops.num_chn         = 4;        % channels in bin
ext_ops.bin_path        = paths.bin_file;
ext_ops.pre_sp_samps    = 31; %16               % time samples before spike
ext_ops.post_sp_samps   = 32; %43 % time samples after spike
ext_ops.t_shift_flag    = true; % do we need to account for concatenated shifts
%% extract waveforms from spike train in workspace (st1, here)

units_to_extract = 1:numel( unique(st1(:,2))); % or user select e.g., [1 5 6]
units_to_extract = [1 5 6];

% waves_cell{1,j} = waveforms of unit j
% waves_cell{2,j} = # of waves extracted
% waves_cell{3,j} = unit #
% waves_cell{4,j} = max chn in descending order
% waves_cell{4,j} = peak amplitude in descending order (well, ascending
%                                                       since they are 
%                                                       negative
%                                                       potentials)

waves_cell1 = extract_waveforms(st1, units_to_extract, ext_ops);

% option to save waves_cell1


