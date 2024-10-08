function [waves_cell] = extract_waveforms(st, ...
                                                     units, ...
                                                     pars)
% ----------------------------------------------------------------------- %
% extract pars
Fs             = pars.Fs;               % sampling frequency
n_waves_ext    = pars.n_waves_ext;      % number of waveforms for plot
num_chn        = pars.num_chn;          % number of channels in .bin file
bin_path       = pars.bin_path;         % path to binary file
pre_sp_samps   = pars.pre_sp_samps;     % time samples before spike
post_sp_samps  = pars.post_sp_samps;    % time samples after spike
t_shift_flag   = pars.t_shift_flag;     % do we need to account for concatenatd files?
% ----------------------------------------------------------------------- %

% -- get total number of units -- %
num_units = numel(units);

% -- pre-allocate cell that will hold waveforms -- %
% waves_cell{j,1} = waveforms for jth unit
% waves_cell{j,2} = number of waves
% waves_cell{j,3} = unit id
% waves_cell{j,4} = max channels
waves_cell = cell(numel(units), 2);
% ------------------------------------------------ %
% 

% What this is for: in BP's data, there were >2s gaps between 
%   4-hour blocks. This created a problem with Kilosort which cannot 
%   handle 2s gaps. To solve this we stitched the files together, 
%   retaining the "subtracted" time in a table, so it could be
%   appropriately added back in later. 
%  (1) This book-keeping should happen at a higher level, not down in
%  "extract_waveforms"
%  (2) Unclear whether we need to keep at all since MS does not care about
%  a gap
% 
%
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
    if num_spikes < n_waves_ext
        fprintf('\n\n** You requested to find %d spikes. Only %d spikes found. **\n', ... 
                n_waves_ext, num_spikes)
    end
    % -- get number of waves to extract for this unit -- %
    n_waves_ext_iter = min(num_spikes, n_waves_ext); 
   % -------------------------------------------------------------------- %
   %% step 2. Get random samples of this unit's waveforms
   ext_waveform_idxs  = randsample( 1:num_spikes, n_waves_ext_iter);
   
   fileID = fopen( bin_path); % open waveform .bin file
   num_time_points = pre_sp_samps + post_sp_samps + 1; % number of time points
   % pre-allocate

   spike_mat = nan(num_chn, num_time_points, n_waves_ext_iter);

    for spike_iter = 1 : n_waves_ext_iter
        sp_idx   = ext_waveform_idxs( spike_iter );
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
        spike_mat( : , : , spike_iter ) = ...
                            fread(fileID, [num_chn num_time_points], 'int16');

    end
    %% step 3. Determine top 4 channels
    % -- sum across all spikes ---> [ num_chn  x  num time points ]  
    spike_mat_sum = sum( spike_mat, 3);
    
    % -- take the *minimum* across all time points
    spike_mat_mins = min( spike_mat_sum, [], 2 );
    
    % -- sort in increasing order then take top 4 for peak channels -- %
    [peaks, chn_order] = sort( spike_mat_mins, 'ascend' );
    top4 = chn_order(1:4);
    
    %% step 4. Pack it all up
    waves_cell{unit_iter,1} = spike_mat;
    waves_cell{unit_iter,2} = n_waves_ext_iter;
    waves_cell{unit_iter,3} = unit_no;
    waves_cell{unit_iter,4} = top4;
    waves_cell{unit_iter,5} = peaks ./ n_waves_ext_iter;

end

fclose( fileID );
end

