function [spike_train, comp_table, kept_temps] = prep_SI_for_spike_train(SI, ops)

%%% extract spike interface extracted data we investigate
% input Spike_Data  --> BP manually curated spikes
% ops               --> time_start, time_end, bp_tets
time_end    = ops.time_end;
time_start  = ops.time_start;
Q_comp    = ops.Q_comp;
R_comp    = ops.R_comp;
base_tets = ops.base_tets;
restrict_multi_tet_temps = ops.restrict_multi_tet_temps;
Fs        = SI.sampling_frequency;
unit_map  = SI.unit_map; % tells which units lie on which tetrode
                         % unit_map(j) = T --> jth unit lies on tetrode T



%%% estimate contamination rates using kilosort spike train code


SI.SpikeTimes = double(SI.spike_indexes_seg0) ./ Fs;
SI.units      = double(SI.spike_labels_seg0);
SI.Tetrodes   = 1 * ones(size( SI.spike_labels_seg0) );


% read off from templates on spike interface


temp_unique = unique( double(SI.spike_labels_seg0));
temp_unique = temp_unique(:);

for temp_iter = 1 : numel(temp_unique)
    temp_idxs = double(SI.spike_labels_seg0) == temp_unique(temp_iter);
    SI.Tetrodes(temp_idxs) = unit_map( temp_iter );
end


% Possible hardcode Q = 0.2 and R = 0.1, just to match KS labels
comp_table = estContamination_stONLY([SI.SpikeTimes(:) SI.units(:)], 0.2, 0.1);

% which copmarison are good?
st_good = comp_table.Q < Q_comp & comp_table.R < R_comp;



% Which of of those tetrodes are in the base list?
if restrict_multi_tet_temps
    comp_overlap_tetrodes = ismember(unit_map(:), base_tets(:));
else
    comp_overlap_tetrodes = ismember(unit_map(:), base_tets(:)) | isnan( unit_map(:) );
end

% Which of those templates meet our *good* criteria
kept_temps = sort( temp_unique(  comp_overlap_tetrodes & st_good ) ) ;

% Where do those temps lie in the spike train?
comp_idxs = ismember( SI.units(:), kept_temps );

% Lets keep those
% [spike time idx , template #, Tetrode #]
spike_train = [SI.SpikeTimes(:) double(SI.spike_labels_seg0(:)), SI.Tetrodes(:)];
spike_train = spike_train(comp_idxs,:);

% finally only keep the desire time
spike_train = spike_train( (spike_train(:,1)<=time_end) & (spike_train(:,1)>=time_start), : ); 

end
