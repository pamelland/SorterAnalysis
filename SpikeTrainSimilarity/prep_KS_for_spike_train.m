function [spike_train, comp_table, kept_temps] = prep_KS_for_spike_train(rez, ops)

%%% extract kilosort curated data we investigate
% input Spike_Data  --> BP manually curated spikes
% ops               --> time_start, time_end, bp_tets

time_cut  = ops.time_cut;
Q_comp    = ops.Q_comp;
R_comp    = ops.R_comp;
TETS      = ops.ks_tets;
base_tets = ops.base_tets;
restrict_multi_tet_temps = ops.restrict_multi_tet_temps;
Fs        = rez.ops.fs;



%%% estimate contamination rates using kilosort spike train code

% Possible hardcode Q = 0.2 and R = 0.1, just to match KS labels
comp_table = estContamination(rez, 0.2, 0.1);

% which copmarison are good?
st_good = comp_table.Q < Q_comp & comp_table.R < R_comp;

% Now, lets find the tetrode associated with each template
ks_electrodes = get_template_chn(rez.U, rez.W, rez.Wrot, ...
                                 rez.mu, rez.ops.scaleproc, 4, TETS);
                            
comp_tets = [ks_electrodes.tet_idx];
comp_tets = comp_tets(:);

% Which of of those tetrodes are in the base list?
if restrict_multi_tet_temps
    comp_overlap_tetrodes = ismember(comp_tets, base_tets);
else
    comp_overlap_tetrodes = ismember(comp_tets, base_tets) | isnan( comp_tets);
end

% Which of those templates meet our *good* criteria
kept_temps = sort( find( comp_overlap_tetrodes & st_good ) );

% Where do those temps lie in the spike train?
comp_idxs = ismember( rez.st3(:,2), kept_temps );

% Lets keep those
spike_train = rez.st3(comp_idxs, 1:2); % [spike time idx , template #]
spike_train(:,1) = spike_train(:,1) ./ Fs; % convert to seconds
spike_train = [spike_train  comp_tets( spike_train(:,2) )]; % add column for tetrode

% finally only keep the desire time
spike_train = spike_train( spike_train(:,1)<=time_cut, : ); 

end
