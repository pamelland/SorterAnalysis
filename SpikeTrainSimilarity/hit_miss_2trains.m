function hit_struct = hit_miss_2trains(st_base, ...
                                    base_tet, ...
                                    st_comp, ...
                                    Fs, ...
                                    n_buff)

% Calculate hit and miss rate for a unit given KS output
% Find if a detected spike lies within +/- buff of BP identified spike
%       -> Loop over spike times for fixed unit
%       -> Find KS spikes close to it
%       -> Make sure that spiking tetrode matches KS spiking tetrode
% determine if that template is labeled 'good' by KS
% Possibly return Q and R values for 'good' template classification


%%% just in case neither train is ordered--order them
[~,st_base_ord] = sort( st_base(:,1) );
st_base = st_base(st_base_ord, :);

[~,st_comp_ord] = sort( st_comp(:,1) );
st_comp = st_comp( st_comp_ord, : );
num_st_comp = size( st_comp, 1);



%%% Convert sample buffer into seconds
buff = n_buff / Fs;



low_comp_time = 0;
low_comp_idx = 0;

high_comp_time = 0;
high_comp_idx = 0;

for spike_j = 1 : size(st_base,1)
    %%% get current spike time
    spike_time = st_base( spike_j, 1 );
    hit_struct( spike_j ).spike_time = spike_time;
    
    %%% increase low_ks_time until we are within +/- buff
    while low_comp_time < spike_time - buff
        low_comp_idx = low_comp_idx + 1;
        
        % Ensure we havent exceeded comparison spike train
        if low_comp_idx > num_st_comp
            % fprintf('\nlow_comp_time = %0.8f', low_comp_time)
            % fprintf('\nspike_idx = %d', spike_j)
            % fprintf('\nspike_time = %0.8f', spike_time)
            % fprintf('\nlow_comp_idx = %d', low_comp_idx)
            
            low_comp_time = inf; % flag that will be caught by next check
        else
        
            low_comp_time = st_comp( low_comp_idx, 1 );
            
        end
    end
    
    %%% check if we overshot spike_time by buff.  If so, we missed this
    %%% spike and continue to next
    if low_comp_time > spike_time+buff
        %%% save that we missed this one
        hit_struct(spike_j).hit = false;
        hit_struct(spike_j).temps = nan;
        hit_struct(spike_j).ks_idxs = nan;
        hit_struct(spike_j).ks_idxs_pruned = nan;
        hit_struct(spike_j).closest_st = nan;
        hit_struct(spike_j).closest_temp = nan;
        hit_struct(spike_j).TIE = nan;
        continue
    %%% otherwise, lets find spike_time + buff
    else
        high_comp_time = low_comp_time;
        high_comp_idx = low_comp_idx;
        
        while high_comp_time <= spike_time + buff
            high_comp_idx = high_comp_idx + 1;
            if high_comp_idx > size( st_comp, 1)
                break
            else
                high_comp_time = st_comp( high_comp_idx,1 );
            end
        end
        
        %%% the previous loop overshoots by 1
        high_comp_idx = high_comp_idx - 1;
        high_comp_time = st_comp( high_comp_idx, 1 );
        
        %%% get ks idxs within spike_time +/- buff
        curr_comp_idxs = low_comp_idx : high_comp_idx;
        
        
        %%% Find which indexes spike on this channel.  We require the
        %%% tetrodes to agree
        delete_ks_idxs = []; 
        for comp_spike_j = 1 : numel( curr_comp_idxs )
            comp_spike = curr_comp_idxs( comp_spike_j );
            
            comp_tet = st_comp(comp_spike, 3);
            
            
            if base_tet ~= comp_tet
                %%% Spike on different tetrode; lets delete it
                delete_ks_idxs = [delete_ks_idxs comp_spike];
            end
        end
        hit_struct(spike_j).ks_idxs = curr_comp_idxs;
        
        curr_comp_idxs = setdiff( curr_comp_idxs, delete_ks_idxs );
        hit_struct(spike_j).ks_idxs_pruned = curr_comp_idxs;
        
        % lets identify the closest spike time.  If there is a tie,
        % randomly assign one template as the closest
        if numel( curr_comp_idxs ) > 1
            [time_diffs, time_diff_idxs] = sort( abs(spike_time - st_comp( curr_comp_idxs, 1) ) );
        
            % check for ties
            lowest_time = time_diffs(1);
            tie_counter = 0;
            for checker = 2 : numel( time_diffs )
                if abs( lowest_time - time_diffs(checker) ) <= 0.5 * (1/Fs)
                    tie_counter = tie_counter + 1;
                end
            end
            
            % If we found a tie, randomly assign closest template
            if tie_counter > 0
%                 fprintf('\n\n**TIE for spike %d**\n\n', spike_j)
                rand_idx    = randi(tie_counter+1);
                curr_idxs   = time_diff_idxs(1:tie_counter+1);
                closest_idx = curr_idxs( rand_idx );
                % closest_idx = randsample( time_diff_idxs(1: (tie_counter+1)), 1);
                closest_st = st_comp( curr_comp_idxs(closest_idx) , 1); 
                closest_temp = st_comp( curr_comp_idxs(closest_idx) , 2);
                hit_struct(spike_j).TIE = true;
            else
                closest_st   = st_comp( curr_comp_idxs(time_diff_idxs(1)), 1);
                closest_temp = st_comp( curr_comp_idxs(time_diff_idxs(1)), 2);
                hit_struct(spike_j).TIE = false;
            end
        
        else
            closest_st   = st_comp( curr_comp_idxs, 1);
            closest_temp = st_comp( curr_comp_idxs, 2);
            hit_struct(spike_j).TIE = false;
        
        end
    end
    
    %%% Now we have ks_idxs that lie within the buffered interval and whose
    %%% templates spike on this tetrode
    if ~isempty( curr_comp_idxs )
        hit_struct(spike_j).hit = true;
        hit_struct(spike_j).temps = st_comp( curr_comp_idxs, 2);
        hit_struct(spike_j).closest_st = closest_st;
        hit_struct(spike_j).closest_temp = closest_temp;
    else
        hit_struct(spike_j).hit = false;
        hit_struct(spike_j).temps = [];
    end
        
    
    
end
    

        
                
        
        
        
            
    


end

