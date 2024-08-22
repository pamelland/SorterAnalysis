%% Now we calculate hits & misses
n_buff = 5; %% +/- # samples buffer for allowing hits

st1_units = sort( unique( st1(: , 2) ) );
st2_units = sort( unique( st2(: , 2) ) );

num_st1_units = numel( st1_units );
num_st2_units = numel( st2_units );
spike_count_mat = zeros( num_st1_units, num_st2_units );
spike_count_near_mat = zeros( num_st1_units, num_st2_units );
spike_perc_mat = zeros( num_st1_units, num_st2_units );
spike_perc_near_mat = zeros( num_st1_units, num_st2_units );

% =========================================================================

% -- We will need to prune candidate hits after they have been matched to
% avoid double counting
st2_pruned = st2;

for unit_iter = 1 : num_st1_units
    unit_no = st1_units( unit_iter );
    
    st_base_unit = st1( st1(:,2) == unit_no, :);
    base_tet = st_base_unit(1,3);
    hit_struct_temp = hit_miss_2trains(st_base_unit, ...
                                  base_tet, ...
                                  st2_pruned, ...
                                  Fs , ...
                                  n_buff);
    hit_cell{unit_iter} = hit_struct_temp;
    hit_rate = sum( [hit_struct_temp(:).hit]) / numel( hit_struct_temp );
    
    cur_temps = unique( vertcat( hit_struct_temp.temps ) );
    cur_temps = cur_temps( ~isnan( cur_temps) );
    
    temps_cell = {hit_struct_temp.temps};
    nearest_cell = {hit_struct_temp.closest_temp};

    st2_idxs_matched = [hit_struct_temp(:).ks_idxs];
    st2_idxs_matched( isnan(st2_idxs_matched) ) = [];

    st2_pruned(st2_idxs_matched,:) = [];
    for temp_iter = 1 : numel( cur_temps )
        temp_no = cur_temps( temp_iter);
        
        temp_spikes = sum( cellfun( @(m) ismember(temp_no, m), temps_cell ) );
        temp_spikes_near = sum( cellfun( @(m) ismember(temp_no, m), nearest_cell ) );
        
        temp_spikes_perc = temp_spikes / numel(hit_struct_temp);
        temp_spikes_near_perc = temp_spikes_near / numel(hit_struct_temp);
        
        spike_count_mat( unit_iter, temp_no) = temp_spikes;
        spike_count_near_mat( unit_iter, temp_no) = temp_spikes_near;
        
        spike_perc_mat( unit_iter, temp_no) = temp_spikes_perc;
        spike_perc_near_mat( unit_iter, temp_no) = temp_spikes_near_perc;
    end
        
    
fprintf('**\nUnit %d had a hit rate of %0.2f%%\n\n', unit_no, hit_rate*100)

end
% =========================================================================
%% metrics

gt_hits     = sum( spike_count_mat, 2);
sorted_hits  = sum( spike_count_mat, 1);

gt_events       = arrayfun(@(j) sum(st1(:,2) == j), unique(st1(:,2)));
sorted_events   = arrayfun(@(j) sum(st2(:,2) == j), unique(st2(:,2)));

% PHANTOM EVENT: any detected event that does NOT correspond to a GT event
phantom_events = max( sorted_events(:)' - sorted_hits(:)', zeros(1, numel(sorted_hits)) );
phantom_events = sum( phantom_events );

% MATCHED EVENT: any detected event that DOES correspond to a GT event
matched_events = sum( sorted_hits );

% MISSED EVENT: any GT event that was not detected
missed_events = sum( gt_events - gt_hits);

%% Diagnostic metric: All events

proxy_FPR = phantom_events / ( phantom_events + sum(gt_events) );
proxy_TPR = matched_events  / ( sum(gt_events) );

%% Diagnostiv metric: single unit vs multi-unit (noise)

% CONDITION POSITIVE (P):   The number of real positives in the data
%                           Treat single unit events as real positives
P = sum( gt_events(1:8) );

% CONDITION NEGATIVE (N):   The number of real negatives in the data
%                           Treat multi unit events as real negatives
N = sum( gt_events(9:end) );

% False Positive Rate (FPR): FP / N;
false_positives_single = sum( sorted_events) - sum( gt_hits(1:8) );
FPR_single = false_positives_single / N;

% True Positive Rate (TPR): TP / P;
true_positives_single = sum( gt_hits(1:8) );
TPR_single = true_positives_single  / P;


out_table = table(sum( gt_hits ), ...
                  sum( sorted_hits), ...
                  sum( gt_events ), ...
                  sum( sorted_events ), ...
                  phantom_events, ...
                  matched_events, ...
                  missed_events, ...
                  proxy_FPR, ...
                  proxy_TPR, ...
                  P, ...
                  N, ...
                  false_positives_single, ...
                  FPR_single, ...
                  true_positives_single, ...
                  TPR_single, ...
        'VariableNames', ...
        {'total_gt_hits', ...
        'total_sorted_hits', ...
        'total_gt_events', ...
        'total_sorted_events', ...
        'phantom_events', ...
        'matched_events', ...
        'missed_events', ...
        'proxy_FPR', ...
        'proxy_TPR', ...
        'P', ...
        'N', ...
        'false_positives_single', ...
        'FPR_single', ...
        'true_positives_single', ...
        'TPR_single'})