function [spike_train, base_tets] = prep_BP_for_spike_train(Spike_Data, ops)

%%% extract BP curated data we investigate
% input Spike_Data  --> BP manually curated spikes
% ops               --> time_start, time_end, bp_tets
time_start  = ops.time_start;
time_end    = ops.time_end;
TETS        = ops.bp_tets;



keep_stime = (Spike_Data(:,1) <= time_end) &  (Spike_Data(:,1) >= time_start);
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

