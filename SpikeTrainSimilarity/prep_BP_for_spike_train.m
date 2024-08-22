function [spike_train, base_tets] = prep_BP_for_spike_train(Spike_Data, ops)

%%% extract BP curated data we investigate
% input Spike_Data  --> BP manually curated spikes
% ops               --> time_start, time_end, bp_tets
time_start_list  = ops.time_start;
time_end_list    = ops.time_end;
TETS        = ops.bp_tets;

% Keep based on spikes
keep_stime = false( size(Spike_Data,1) , 1 );
for start_iter = 1 : numel( time_start_list )
    time_start  = time_start_list( start_iter );
    time_end    = time_end_list( start_iter );
    keep_stime_iter = (Spike_Data(:,1) <= time_end) &  (Spike_Data(:,1) >= time_start);
    keep_stime = keep_stime_iter | keep_stime;
end

base_tet_bool = false( size(Spike_Data(:,1) ) );

% keep only those on tetrodes we care about
for TET_iter = 1 : numel(TETS)
    base_tet_bool = base_tet_bool | ( Spike_Data(:,3) == TETS( TET_iter ) );
end


keep_sdata = keep_stime & (base_tet_bool);

% =========================================================================
% st_base
% Use BP data as st_base
spike_train = Spike_Data(keep_sdata, 1:3); %[ spike times , unit # , tet # ]
% which tetrodes were classified in st_base.
base_tets = unique( spike_train(:,3) );

end

