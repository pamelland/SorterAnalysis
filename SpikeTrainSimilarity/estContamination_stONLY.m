function good_table = estContamination_stONLY(st, rmax, fcontamination, fs)
% =========================================================================
% On input: st = [ spike_times  unit_ids ] // spike train
%
% On exit:  good_table --> table containing Q and R values and good class
% =========================================================================


%% determine good vs. mua using Kilosort crit.
% check all temps -- numel( rez.good )
temps_to_check = unique(st(:,2));

% Pre-allocate lists for Q and R values
Q_list = nan( numel(temps_to_check), 1);
R_list = nan( numel(temps_to_check), 1);

% boolean will be turned to true if Q < fcontamination & R < rmax
igood_list = false( numel(temps_to_check), 1);
num_spike_list = nan( numel(temps_to_check), 1);
for j = 1:numel(temps_to_check)
    % The template we are checking
    template_idx = temps_to_check( j );
    
    % Where did this template fire
    temp_idxs = find( st(:,2) == template_idx );


    % Spike train to copmute correlograms/tails/shoulders
    spike_train = st(temp_idxs,1);
    
    % How many times did this template fire
    num_spikes = numel( spike_train );
    
    % If this template has been merged with another, the spike train could
    % be empty
    if isempty( spike_train)
        Q = 420;
        R = 420;
        igood_list(j) = false;
    else
        % Lets borrow KS code
        %%% next portion taken from check_cluster.m
        [~, Qi, Q00, Q01, rir] = ccg(spike_train, spike_train, 500, 1/1000); % % compute the auto-correlogram with 500 bins at 1ms bins
        Q = min(Qi/(max(Q00, Q01))); % this is a measure of refractoriness
        R = min(rir); % this is a second measure of refractoriness (kicks in for very low firing rates)
        if Q<fcontamination && R<rmax
           igood_list(j) = 1;  
        else
            igood_list(j) = 0;
        end
    end
    % Q and R could be nan, if no two spike occur within 500/1000 sec of
    % each other. I guess, this would be no refractory violations?
    if isnan(Q)
        Q = -1;
    end
    if isnan(R)
        R = -1;
    end
    Q_list(j) = Q;
    R_list(j) = R;
    num_spike_list(j) = num_spikes;
    % fprintf('\nTemplate %d of %d finished.\n', j, numel(temps_to_check));
end

table_headings = {'template','num spikes', 'Q', 'R', 'fcont_cut', 'R_cut', ...
                  'Q<fcont_cut', 'R<R_cut', 'PM_good'};
good_table = table(temps_to_check(:), ...
                  num_spike_list, ...
                  Q_list, ...
                  R_list, ...
                  fcontamination.*ones(numel(Q_list), 1), ...
                  rmax.*ones(numel(R_list),1), ...
                  Q_list<fcontamination, ...
                  R_list<rmax,...
                  igood_list, ...
                  'VariableNames', table_headings);

end

