%% These should probably be read in from waveform file (which means should be saved to waveform files)
% As it is now, hardcoded
ext_ops.Fs              = 30000;
ext_ops.pre_sp_samps    = 33; 
ext_ops.post_sp_samps   = 33; 
%%
% ----------------------------------------------------------------------- %
% Main options for pre-linking

% Starts (in hours) for blocks
start_list  = [0 1 2 3];
% Ends (in hours for blocks
end_list    = [2 3 4 5];

% File path to extracted waveforms
sorter_ops.path         = '/Volumes/PM-HD/FAST_data/SorterOutput/MS5';
% subfolder for extracted waveforms (likely named according to sorting
%   hyperparams)
sorter_ops.subfolder    =  'STD-14_ClipSize-50';


% option to center spikes at peak amplitude
center_spikes_bool = true;
center_ops.buff = 8; 
center_ops.centered_idx = ext_ops.pre_sp_samps   +1;

% PC list for projections to get 'average' waveforms of clusters
pc_list = 1:10;

% Centrality function for averaging waveforms
centrality_func = @mean; %% \\ mean corresponds to centroid
% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% - set clustering & linking options - %
ops.nPCs = 10;  % Number of PCs to use when forming links in COMMON PC space
ops.alpha = 0;  % how to assign linkage to leaves? // alpha = 0 assigns 
                % leaves a linkage of zero. alpha = 1 assigns leaves a
                % linkage equal to the linkage of the first group formed.

ops.linkage_method = 'average';  % 'single', 'centroid', 'average'

ops.link = 'parent_diff';          % 'zero' 'zero_flip'  'tier'  'one'  'parent_diff'


ops.knn_min = 18;    % scaling parameter is set to the median of the knn_min
                     % neighbor for each cluster 1 node



ops.off_set = exp(-1);      % cluster similarities smaller than this value 
                            % are penalized in objective function

ops.lambda   = 1;           % multiplier to increase contribution of cluster similarity scores.
ops.sim_type = 'gauss';     % kernel for cluster similarity // only 'gauss'
                            % functional for now



ops.constraint_type = 'ineq';  % 'eq'  'ineq'

ops.weight_by_leaf_count = true;

%%

% Number of sorting blocks
n_blocks = numel(start_list);

% initialize cells that will hold unit IDs and waveforms
units       = cell( n_blocks, 1);
waves_cell  = cell( n_blocks, 1);
n_units     = cell( n_blocks, 1);

for block_iter = 1 : numel(start_list)
    start_str   = sprintf('%04d',start_list(block_iter) *60);
    end_str     = sprintf('%04d',end_list(block_iter)   *60);
    
    % load waveforms
    waves = load( fullfile(sorter_ops.path, ...
                           sprintf('%s-%s',start_str, end_str), ...
                           sorter_ops.subfolder, ...
                           'waveforms.mat') );

    % extrace waveforms to have variable name 'waves_cell'
    waves_name = fieldnames( waves );
    waves_temp = waves.( waves_name{1} ); % this way we don't care how the cell in 'waves' is named
    

    n_units{block_iter}     = size(waves_temp,1);
    units{block_iter}       = unique(vertcat( waves_temp{:,3} ));
    waves_cell{block_iter}  = waves_temp;
end

clear waves waves_name waves_temp start_str end_str
%% option to center spikes

if center_spikes_bool
    for block_iter = 1 : n_blocks
        centered_temp           = center_spikes( waves_cell{block_iter}, center_ops);
        waves_cell{block_iter}  = centered_temp;
    end
    fprintf('\n* Spikes are centered with buffer = %d and centered_idx = %d*\n\n', ...
        center_ops.buff, center_ops.centered_idx)
else
    fprintf('\n* Spikes are left uncentered *\n\n')
end


clear centered_temp
%% get PCs for each

tic
fprintf('\n\n* Computing PCs for each cluster. *\n')

PC_struct = cell(n_blocks,1);
for block_iter = 1 : n_blocks
    PC_struct{block_iter} = compute_PCs_waveforms(1,units{block_iter}, waves_cell{block_iter});
end

fprintf('\n* Cluster PCs computed. *\n')
toc

%% Compute medians for each

tic
fprintf('\n\n* Computing PCs medians each cluster. *\n')

PC_meds     = cell( n_blocks, 1);
PC_meds_IDs = cell( n_blocks, 1);
for block_iter = 1 : n_blocks
    [PC_temp, ID_temp]  = compute_PC_center(PC_struct{block_iter}.score, PC_struct{block_iter}.labels, centrality_func);
    PC_meds{block_iter} = PC_temp;
    PC_meds_IDs         = ID_temp;
end
fprintf('\n* PC medians computed. *\n')
toc

clear PC_temp ID_temp
%% Use centroid to construct denoised waveforms using first PCs

tic
fprintf('\n\n* Computing Denoised waveforms each cluster. *\n')
proj_waveforms = cell(n_blocks,1);
for block_iter = 1 : n_blocks
    proj_waveforms{block_iter} = PC_meds{block_iter}(:, pc_list) * ...
                                 PC_struct{block_iter}.coeff(:,pc_list)' + ...
                                 PC_struct{block_iter}.mu;
end
fprintf('\n\n* Denoised waveforms computed. *\n')
toc

%% Put average waveforms in common PC space
clc

tic
fprintf('\n\n* Projecting denoised waveforms into common PC space. *\n')
% package everything up
[PC_struct_grouped,proj_waveforms_stacked,units_grouped] = group_PC_struct(units,proj_waveforms);

fprintf('\n\n* Denoised waveforms in common PC space. *\n')
toc


%% Cluster each individually in common PC space
[PC_meds_grouped, PC_meds_IDs_grouped] = compute_PC_center(PC_struct_grouped.score, PC_struct_grouped.labels, @mean);

% ----------------------------------------------------------------------- %
clear Y Z input_data
plot_individual_trees = true;
tree_cell = cell(1,n_blocks);
for group_iter = 1 : numel(units)
    idxs  = 1 : numel( units{group_iter} );
    shift = numel( vertcat( units{1:group_iter} )) - numel( units{group_iter} );
    idxs  = idxs + shift;
    input_data{group_iter} = PC_meds_grouped(idxs,1:ops.nPCs);
end




for group_iter = 1:numel(units)
    % - pairwise distances - %
    Y{group_iter} = pdist( input_data{group_iter} );

    % - compute linkage
    Z{group_iter} = linkage(Y{group_iter},ops.linkage_method);

    
    % - compute trees -
    % {idx}  {parents}  {children}  {centroid}  {linkage}
    tree_cell{group_iter} = get_tree_info(Z{group_iter},...
                                          1:numel(units{group_iter}), ...
                                          input_data{group_iter}, @mean);
    n_nodes{group_iter} = size(tree_cell{group_iter},1);

end

for group_iter = 1 : numel(units)-1
    % - compute cluster similarity - %
    [clust_sim_temp, clust_dist_temp] = compute_cluster_sim_mat(tree_cell{group_iter}, ...
                                                                tree_cell{group_iter+1}, ...
                                                                ops);
    clust_sim{group_iter}       = clust_sim_temp;
    clust_dist{group_iter}      = clust_dist_temp;
end


% - plot cluster similarity - %


%% Wrapped up optimization problem
[x, X] = solve_linkage(tree_cell, units, clust_sim,ops);

