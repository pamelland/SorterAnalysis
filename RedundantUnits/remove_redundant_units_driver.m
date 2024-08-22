% Look at results from MS4
%
% Compute ccgs and check the units with overlapping spikes

% which directory?
twStr = '0000-0120-Thresh-10-v2';

% PM edits: twStr is final folder of paths.sorted_spikes
twStr = paths.sorted_spikes;

% This is in the right format 
temp=load([twStr '/firings.mat']);

% PM edits: or firings_adjusted
temp=load([twStr '/firings_adjusted.mat']);

% units_to_check = [29 28 11 15 20 22 23 25 27 51 24 26 57 41 47 13 33];
% PM edits: take unique unit id labels
units_to_check = double( unique( temp.unit_ids ) );
tbin = 0.001;
redunThresh=0.7;

[newSort,discSort]=remove_redundant_units(temp,redunThresh,tbin, units_to_check);


%% If I am saving: format this like Pake's file
%% 
if (1)

    fname = [twStr '/firings_RemoveRedun.mat'];

    unit_ids    = newSort.unit_ids;
    num_segment = newSort.num_segment;
    sampling_frequency  = newSort.sampling_frequency;
    spike_indexes_seg0  = newSort.spike_indexes_seg0;
    spike_labels_seg0   = newSort.spike_labels_seg0;

    save(fname,"unit_ids", "num_segment", "sampling_frequency",...
        "spike_labels_seg0","spike_indexes_seg0");

    % Save parameters used wghen removing redundancies
    discSort.binSize = tbin;
    discSort.redunThresh = redunThresh;
    save(fname, "discSort", "-append");
end