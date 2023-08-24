function [spike_vec, time_cell] = get_num_spikes(spike_list,unit_no)
% spike_list --> collection of all spikes formatted:
%                [spike_time  unit_no  tet_no];

spike_vec =  nan( size( unit_no ) );
time_cell = cell( size( unit_no ) );

for j = 1 : numel(unit_no)
    unit_idxs = spike_list(:,2) == unit_no(j);
    num_spikes = sum( unit_idxs );
    spike_times = spike_list(unit_idxs,1);
    
    spike_vec( j ) = num_spikes;
    time_cell{ j } = spike_times;
end

