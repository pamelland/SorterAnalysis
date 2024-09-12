function [PC_struct] = compute_PCs_waveforms(tetrode, ...
                                             units_for_PCA, ...
                                             waves_cell)
% compute_PCs_waveforms: Apply PCA to a set of waveforms
% ----------------------------------------------------------------------- %
% INPUTS:
%   tetrode         --> index of tetrode in data file. E.g., if you have 
%                       tetrodes [1 2 5 17] saved & want 17, then 
%                       tetrode = 4
%   units_for_PCA   --> unit IDs to compute PCA
%   waves_cell      --> cell array most likely provided by
%                       'extract_waveforms()'
%
% OUTPUTS:
%   PC_struct       --> PCA results concatenated into struct // see code
%                       for fields
% ----------------------------------------------------------------------- %
%
% Called by: cluster_trees_by_file
% Calls: pca
%

chns    = tetrode .*4 - [3 2 1 0]; % channels on this tetrode
idx_base = 0;

num_waves = sum( [waves_cell{:,2}] );
num_time_points = size(waves_cell{1,1}, 2);
tall_spikes = nan( num_waves, 4 * num_time_points );
tall_labels = nan( num_waves, 1 );

for unit_iter = 1 : numel( units_for_PCA )
    current_unit = units_for_PCA( unit_iter );
    current_chns = waves_cell{ unit_iter, 4 };
    current_num_waves = waves_cell{ unit_iter, 2 };
    
    % Some units from MS5 registered zero spikes. Why?
    if current_num_waves == 0
        continue
    end
    current_idxs = (1 : current_num_waves) + idx_base;
    
    if sum( ismember( current_chns(:), chns(:) ) ) ~= 4
        continue
    end
    
    current_chns  = sort( current_chns );
    current_waves = waves_cell{ unit_iter, 1}( current_chns, :, : );
    current_waves = reshape( permute(current_waves, [3 2 1]), ...
                             [current_num_waves, 4 * num_time_points]);

    tall_spikes( current_idxs,:) = current_waves;
    tall_labels( current_idxs ) = waves_cell{ unit_iter, 3 };
    
    idx_base = current_idxs(end);
end


% do PCA
[coeff, score, latent, tsquared, explained, mu] = pca(tall_spikes);

PC_struct.coeff     = coeff;
PC_struct.score     = score;
PC_struct.latent    = latent;
PC_struct.tsquared  = tsquared;
PC_struct.explained = explained;
PC_struct.mu        = mu;
PC_struct.labels    = tall_labels;
end