clear; clc; close all
%%


% ----------------------------------------------------------------------- %
% Set main options.
% which spikes###.mat do we want?
file_list = {'001'};
Tetrodes              = [1];       % tetrodes we want
idx_ops.centered_idx  = 32;        % index for  centered spikes
time_ops.Fs           = 30000;     % sampling rate in Hs
time_samps_between    = 0;         % padding between BR nev files
loop_interval         = 1;         % (sec) For looping over 'Voltage'
numchan               = 4;         % number of channels on whole array

% Where to read/write data

%spikes_directory    =  '/Volumes/PM-HD/FAST_data/Snippets/';
%write_dir           =  '/Volumes/PM-HD/FAST_data/VoltageTemp/';
spikes_directory    =  './';
write_directory    =  './';

% subfolder will be named: SPIKES-file_list(1)-...-file_list(n)
folder_name = 'VOLTAGE';
for file_iter = 1 : numel(file_list)
    folder_name = sprintf('%s-%s', folder_name, file_list{file_iter});
end

% which channels are on these tetrodes?
channels = Tetrodes(:) .* 4 - [3 2 1 0];
channels = sort( channels(:) );

% filename will be named: TETS-Tetrodes(1)-...-Tetrodes(n)
file_name = 'TETS';
for tet_iter = 1 : numel(Tetrodes)
    file_name = sprintf('%s-%02d', file_name, Tetrodes(tet_iter) );
end

%% Load First File

fprintf(['\n* -----------------------------------------------------*\n' ...
         '   Loading file Spikes%s (this may take a while) ...\n' ...
         '* -----------------------------------------------------*\n'], ...
         file_list{1})
Spikes = load( fullfile(spikes_directory, sprintf('Spikes%s.mat',file_list{1}) ) );   %%% this may take a while
fprintf('\n* DONE LOADING SPIKES\n *')

%%% Struct is Spikes.Spikes.  For simplicity overload Spikes <--
%%% Spikes.Spikes
StrName=fieldnames(Spikes); StrName=StrName{1}; 
Spikes = Spikes.(StrName);

%clear Spikes
fprintf('\n*** DATA LOADING COMPLETE***\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
current_time = 0;
samps_per_spike = size( Spikes.Waveforms, 2);

% option for ending loop:
%   To use the final time in Spikes final + snippet end
% loop_t_end   = SpikesNEXT.Times(end) + (samps_per_spike - idx_ops.centered_idx) ./ time_ops.Fs;

%   Or to hard code an ending time:
loop_t_end   = 4 * 60 * 60; % in seconds
% ^^ Have to tack on time to capture all of final spike waveform

% open file for writing. Option 'w' for overwriting
full_bin_dir = fullfile(write_directory, folder_name);

if ~exist( full_bin_dir, 'dir' )
    mkdir( full_bin_dir )
end

fid = fopen( sprintf('%s/%s/%s.bin', write_directory, folder_name, file_name), ...
             'w');

% This will be used to keep track of time shifts between blackrocks

time_message_tracker = current_time + 60;



while current_time < loop_t_end
    % Makes sure we don't loop past the nev file ending time
    loop_step = min( [loop_interval   (loop_t_end-current_time)] );
    
    % Current loop start/stop
    time_ops.t_init = current_time + (1/time_ops.Fs);
    time_ops.t_fin  = current_time + loop_step;
    
    % Pad zeros inserting spike waveforms
    [V, ~, ~] = get_cont_from_spike(time_ops, idx_ops, Spikes, numchan);
    
    % Only keep the channels on the tetrodes we want
    V = V(channels, :);
    
    % Write voltage as int16 for 
    fwrite(fid, V, 'int16');
    
    % update current time
    current_time = time_ops.t_fin;
    
    if current_time >= time_message_tracker
        fprintf('\n*Finished %d minutes of %d* \n', ...
            round(current_time / 60), round( loop_t_end / 60 ) )
        time_message_tracker = time_message_tracker + 60;
    end
end


    


fclose( fid );

lookup_file = sprintf('%s/time_look_up.mat', full_bin_dir);
% save(lookup_file, 'BR_conc_table', '-v7.3')

fprintf('\n** DONE WRITING BIN **\n')
