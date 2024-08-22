function [centered_waves] = center_spikes(waves_cell,ops)

% ----------------------------------------------------------------------- %
% Center spikes on their peak (minimum) voltage within +/- buff of marked
% spike time

% On input: waves_cell  <--> a cell whose rows correspond to individual
%                            units. waves_cell{1,1} holds waveforms for
%                            unit 1. waves_cell{2,1} holds waveforms for
%                            unit 2.
%           ops         <--> centering options (see immediate code)
% ----------------------------------------------------------------------- %


% step1 unpack options & initialize
buff = ops.buff;                            % buffer around marked time
centered_idx = ops.centered_idx;            % index for spike time within snippet
loc_idxs = (-buff : buff) + centered_idx;   % Generate neighborhod around marked spike time
og_idxs = 1 : size( waves_cell{1,1}, 2);    % indexes for snippets

centered_waves = waves_cell;                % shallow copy

% loop through and center each waveform for each unit
for unit_iter = 1:size( waves_cell,1 )

    % extract waveforms
    curr_waves = waves_cell{unit_iter, 1};

    % Find local min in nbhd of marked time
    [loc_min_val, loc_min_idx] = min( curr_waves(:,loc_idxs,:), [],2);

    % squeeze down to matrix:  num_chan x num_samples
    loc_min_val = squeeze( loc_min_val );
    loc_min_idx = squeeze( loc_min_idx );

    % get the most negative channel for each sample
    [~, most_neg_chn] = min(loc_min_val);

    % Find how much we have to shift from the centered index
    loc_shift = arrayfun(@(x,y) loc_min_idx( x, y ), most_neg_chn, 1:size(curr_waves,3)) - (buff+1);

    % We will buffer with zeros in case we are near edge of snippet //
    % might be better to peak into voltage ...
    new_waves = zeros( size(curr_waves) + [0  2*buff 0]);
    new_waves(:, (1:size(curr_waves,2))+buff, :) = curr_waves;

    % Mark indexes that will be centered on peak voltage
    idxs_keep = og_idxs' + loc_shift + buff;
    
    % Loop through to finish it off
    for wave_iter = 1 : size( curr_waves, 3)
        centered_waves{unit_iter, 1}(:,:,wave_iter) = new_waves(:,idxs_keep(:,wave_iter), wave_iter);
    end

    fprintf('\nFinished centering unit %d', unit_iter)
end



end