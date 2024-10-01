function [allV,allV_bool,t_vec] = get_cont_from_spike(time_ops, ...
                                                idx_ops, ...
                                                Spikes, ...
                                                num_chan)
%% Build a .bin file for short intervals.  Combine into single file on the fly
%clear;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Spikes are passed in.  Unpack some arguments
Fs = time_ops.Fs;             %% sampling rate
centered_idx = idx_ops.centered_idx;      %% spike location in window
window_length = size(Spikes.Waveforms,2);   %% time samples per window
base_idxs = 1 : window_length;          %% indexes for reading from Spikes

t_init = time_ops.t_init;           %% start of recording
t_fin  = time_ops.t_fin;            %% end of recording (in s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Find first time point according to Fs that lies >= t_init

% If Fs is an integer, then sampling at 1/Fs is guaranteed to hit every
% integer.  So, we round t_init down to get a reasonable starting to point
% to query SAMPLED points
first_sampled_time_point = floor( t_init );


%%% Build out a bridge from the floor value to t_init
temp_t_disc = first_sampled_time_point : (1/Fs) : t_init;

% check if exactly hit our starting point or if we need to add one more
% sample point
if temp_t_disc(end) == t_init
    first_sampled_time_point = t_init;
else
    first_sampled_time_point = temp_t_disc(end) + (1/Fs);
end


%%% make t_vec
t_vec = first_sampled_time_point : (1/Fs) : t_fin;

%%% keep last time point available <= t_fin
last_sampled_time_point = t_vec(end);


%%% Now last point according to Fs that lies <= t_fin
% fprintf('\n\n**The first time point larger than t_init=%0.8f is t=%0.8f **\n\n', ...
%         t_init, first_sampled_time_point)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Main loops


%%% Pre-allocate matrix of zeros
num_time_pts = numel( t_vec );
allV = zeros(num_chan,num_time_pts);
allV_bool = false(num_chan,num_time_pts);

%%% First quick check if the tail of earlier spikes occur right before
%%% also, be wary of spikes in first window_length // checked and works

check_time = first_sampled_time_point - ( (window_length-1) / Fs);
spTime = Spikes.Times( find( Spikes.Times >= check_time, ...
                              1, 'first'));             %% first spike time
spike_counter_tot = find( Spikes.Times == spTime, 1, 'first' ); %% total spike counter
num_spikes = numel( Spikes.Times );


while spTime <  (last_sampled_time_point + centered_idx/Fs)
    
    
    if isempty( spTime )
        fprintf('\n\n** Spike time is empty**\n\n')
        break
    end
    spike_idx = round((spTime - first_sampled_time_point) * Fs) + 1;
    wave_idxs = (1 : window_length) - centered_idx + spike_idx;

    %%% indexes for remainder
    bool_idxs = ( wave_idxs > 0  &  wave_idxs <= num_time_pts);
    temp_idxs = wave_idxs( bool_idxs );
    read_idxs = base_idxs( bool_idxs );
    
    %%% write current voltage
    allV( Spikes.Electrodes(spike_counter_tot,:), ...
          temp_idxs )  = ...
        transpose(squeeze(Spikes.Waveforms(spike_counter_tot,...
                                           read_idxs,...
                                           :)));

    %%% write voltage boolean
    allV_bool( Spikes.Electrodes(spike_counter_tot,:), ...
          temp_idxs )  = ones( size( Spikes.Waveforms,3), ...
                                    numel(temp_idxs) );
    
                                       
    %%% update         
    if spike_counter_tot < num_spikes
        spike_counter_tot = spike_counter_tot+1;
        spTime = Spikes.Times(spike_counter_tot);
    else
        break
    end
    

end


end
