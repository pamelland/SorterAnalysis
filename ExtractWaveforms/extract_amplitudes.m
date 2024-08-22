function [amps_cell, st_amps] = extract_amplitudes(st, ...
                                                     units, ...
                                                     pars)
% ----------------------------------------------------------------------- %
% extract pars
Fs             = pars.Fs;               % sampling frequency
n_amps_ext     = pars.n_amps_ext;       % number of amplitudes to extract
num_chn        = pars.num_chn;          % number of channels in .bin file
bin_path       = pars.bin_path;         % path to binary file
pre_sp_samps   = pars.pre_sp_samps;     % time samples before spike
post_sp_samps  = pars.post_sp_samps;    % time samples after spike
sp_time_buff   = pars.sp_time_buff;     % check for peak within +/- buffer
t_shift_flag   = pars.t_shift_flag;     % do we need to account for concatenatd files?
% ----------------------------------------------------------------------- %

% -- get total number of units -- %
num_units = numel(units);

% -- pre-allocate cell that will hold waveforms -- %
% waves_cell{j,1} = amplitudes for jth unit
% waves_cell{j,2} = number of events
% waves_cell{j,3} = unit id
amps_cell = cell(numel(units), 3);
% ------------------------------------------------ %



% ------------------------------------------------ %
% Establish buffered indexes to check for peak amplitude
check_idxs = pre_sp_samps + 1 + [-1 1].* sp_time_buff;
check_idxs = check_idxs(1) : check_idxs(2);
% ------------------------------------------------ %



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
    file_intervals  = [0 inf];
    t_shifts        = 0;
end
% ----------------------------------------------------------------------- %


% make a copy of st. Add column 4 - 7 for amplitude
st_amps = [st  nan(size(st,1), 1)];


for unit_iter = 1 : num_units
    unit_no = units( unit_iter );
    %% step 1. Find where this unit occurs in spike train
    spike_locs  = st(:, 2) == unit_no;
    spike_times = st( spike_locs, 1);
    num_spikes  = numel( spike_times );
    
    % -------------------------------------------------------------------- %
    % Print some messages
    fprintf('\n\n** Unit %d registered a total of %d spikes. **\n', ...
            unit_no, num_spikes);

    % If we asked to avg too many, then cut it back
    if num_spikes < n_amps_ext
        fprintf('\n\n** You requested to find %d spikes. Only %d spikes found. **\n', ... 
                n_amps_ext, num_spikes)
    end
    % -- get number of waves to extract for this unit -- %
    n_amps_ext_iter = min(num_spikes, n_amps_ext); 
   % -------------------------------------------------------------------- %


   %% step 2. Get random samples of this unit's waveforms
   ext_amp_idxs  = randsample( 1:num_spikes, n_amps_ext_iter);
   fileID = fopen( bin_path); % open waveform .bin file
   num_time_points = pre_sp_samps + post_sp_samps + 1; % number of time points
   % pre-allocate

   peak_amps = nan(num_chn, n_amps_ext_iter);

    for spike_iter = 1 : n_amps_ext_iter
        sp_idx   = ext_amp_idxs( spike_iter );
        sp_time  = spike_times( sp_idx );
        shift_time = t_shifts(  sp_time >= file_intervals(:,1) & sp_time < file_intervals(:,2) );
        sp_time = sp_time - shift_time;
        sp_time_in_samp = round(sp_time * Fs);
        t_start_in_samp = sp_time_in_samp - pre_sp_samps;

        bytes_to_skip = 2 * t_start_in_samp * num_chn; % 2 for 2 bytes in per int16 data
        try
            fseek( fileID, bytes_to_skip, 'bof');
        catch ME
            fprintf('\n Error.\n* Original spike time: %0.10f *\n', sp_time+shift_time)
            fprintf('\n* Spike index: %d *\n', sp_idx)
            fprintf('\n* Shifted spike time: %0.10f *\n', sp_time)
            fprintf('\n* Window start in samples: %d *\n', t_start_in_samp)
            fprintf('\n* Bytes to skip: %d *\n', bytes_to_skip)
            beep
            pause
        end

        % Extract waveform
        wave_form_holder = fread(fileID, [num_chn num_time_points], 'int16');
        % Find the peak voltage buffered around the spike time
        peak_amps(:,spike_iter) = min( wave_form_holder(:,check_idxs), [], 2);
       

    end
    
    %% step 3. Pack it all up

    % in a cell format
    amps_cell{unit_iter,1} = peak_amps;
    amps_cell{unit_iter,2} = n_amps_ext_iter;
    amps_cell{unit_iter,3} = unit_no;

    % in a st format
    spike_locs_idxs = find( spike_locs );
    st_amps( spike_locs_idxs(ext_amp_idxs), 4:7 ) = peak_amps';

end

fclose( fileID );
end