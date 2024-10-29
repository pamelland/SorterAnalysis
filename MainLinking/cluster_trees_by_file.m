%% Driver for FUSE

%% 0) Set lots of options (%% TO MOVE TO MORE CENTRAL LOCATION %%)

%% 1) For each block: read in waveforms
%% 2) OPTIONAL: center_spikes
%% 3) For each block: compute PCs from waveforms (compute_PCs_waveforms)
%% 4) For each block: compute median of each unit in its PC space (compute_PC_center)
%%     Use (3)+(4) to get a denoised waveform for each unit
%% 5) Create a common PC space using the denoised waveforms (group_PC_struct)
%%     Find each unit in common PC space (compute_PC_center)
%% 6) For each block: Get pairwise distances between denoised waveforms (pdist); 
%%    compute hierarchal trees (linkage); compile tree structure (get_tree_info)
%% 7) For each pair of adjacent blocks: Compute similarity between each pair of units
%%      (compute_cluster_sim_mat)
%% 8) Solve integer programming problem (solve_linkage)


%% (0) SET OPTIONS 
%  Ordered by Step ## in which they are used 
%
%% These should probably be read in from waveform file (which means should be saved to waveform files)
% As it is now, hardcoded
%% Need definitions
ext_ops.Fs              = 30000;
ext_ops.pre_sp_samps    = 33; 
ext_ops.post_sp_samps   = 33; 
%%
% ----------------------------------------------------------------------- %
% Main options for pre-linking

% (1) For each block: read in waveforms
% Starts (in hours) for blocks
start_list  = [0 1 2];

% Ends (in hours) for blocks
end_list    = [2 3 4];

% File path to extracted waveforms
%sorter_ops.path         = '/Volumes/PM-HD/FAST_data/SorterOutput/MS5';
sorter_ops.path         = '/Users/andreakbarreiro/Dropbox/MyProjects_Current/Pake/FUSE/Local_Sorter_Output';

% subfolder for extracted waveforms (likely named according to sorting
%   hyperparams)

%sorter_ops.subfolder    =  'STD-14_ClipSize-50';
sorter_ops.subfolder    =  '';

% (2) OPTIONAL: center_spikes

% option to center spikes at peak amplitude
center_spikes_bool = true;
center_ops.buff = 8; 
center_ops.centered_idx = ext_ops.pre_sp_samps   +1;

% (4) Obtain denoised waveforms
%
% Centrality function for averaging waveforms
centrality_func = @mean; %% \\ mean corresponds to centroid

% PC list for projections to get 'average' waveforms of clusters
pc_list = 1:10;

% ----------------------------------------------------------------------- %


% ----------------------------------------------------------------------- %
% - set clustering & linking options - %

% (5)  Create a common PC space, locate each unit in this space
%
ops.nPCs = 10;  % Number of PCs to use when forming links in COMMON
                % PC space

% (6) Compute linkage
ops.linkage_method = 'average';  % 'single', 'centroid', 'average'

% (7)  Compute similarity between each pair of units, in each
%        adjacent pair of blocks
% Used in "compute_cluster_sim_mat"
ops.knn_min = 18;    % scaling parameter is set to the median of the knn_min
                     % neighbor for each cluster 1 node
ops.sim_type = 'gauss';     % kernel for cluster similarity // only
                            % 'gauss' is functional for now


% 8) Used in  "solve_linkage"

% passed to compute_cluster_scores
ops.alpha = 0;  % how to assign linkage to leaves? // alpha = 0 assigns 
                % leaves a linkage of zero. alpha = 1 assigns leaves a
                % linkage equal to the linkage of the first group formed.

ops.link = 'parent_diff';          % 'zero' 'zero_flip'  'tier'  'one'  'parent_diff'


ops.quants = 0;   %  %??% Used if ops.link = 'tier'

% Used in main part of solve_linkage
ops.off_set = exp(-1);      % cluster similarities smaller than this value 
                            % are penalized in objective function

ops.lambda   = 1;           % multiplier to increase contribution of cluster similarity scores.

ops.constraint_type = 'ineq';  % 'eq'  'ineq'

ops.weight_by_leaf_count = true;

%%
%% 1) For each block: read in waveforms

% Number of sorting blocks
n_blocks = numel(start_list);

% initialize cells that will hold unit IDs and waveforms
units       = cell( n_blocks, 1);
waves_cell  = cell( n_blocks, 1);
n_units     = cell( n_blocks, 1);

for block_iter = 1 : numel(start_list)
    start_str   = sprintf('%04d',start_list(block_iter) *60);
    end_str     = sprintf('%04d',end_list(block_iter)   *60);
    
    % AKB: The file "waveforms.mat' contains a nUnit x 5 cell
    % This must have been processed from the original local sorter output
    % Where is the script that does that?
    %   into a standardized form:
    %   Column 1: matrix of waveforms: 4 x nt x 1000
    %   Column 2: number of waveforms for this unit (up to 1000)
    %   Column 3: unit numbers
    %   Column 4: channel order; in which waveforms are reported? Or order
    %       in which "max amplitudes" are reported?
    %   Column 5: Max amplitude on each channel (?)

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

%% 2) OPTIONAL: center_spikes
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

%% 3) For each block: compute PCs from waveforms (compute_PCs_waveforms)

tic
fprintf('\n\n* Computing PCs for each cluster. *\n')

PC_struct = cell(n_blocks,1);
for block_iter = 1 : n_blocks
    PC_struct{block_iter} = compute_PCs_waveforms(1,units{block_iter}, waves_cell{block_iter});
end

fprintf('\n* Cluster PCs computed. *\n')
toc

%% 4) For each block: compute median of each unit in its PC space (compute_PC_center)
%%     Use (3)+(4) to get a denoised waveform for each unit
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

%% 5) Create a common PC space using the denoised waveforms (group_PC_struct)
%%     Find each unit in common PC space (compute_PC_center)
clc

tic
fprintf('\n\n* Projecting denoised waveforms into common PC space. *\n')
% package everything up
[PC_struct_grouped,proj_waveforms_stacked,units_grouped] = group_PC_struct(units,proj_waveforms);

fprintf('\n\n* Denoised waveforms in common PC space. *\n')
toc


%% Locate each individual cluster (unit) in common PC space
[PC_meds_grouped, PC_meds_IDs_grouped] = compute_PC_center(PC_struct_grouped.score, PC_struct_grouped.labels, @mean);

% ----------------------------------------------------------------------- %
clear Y Z input_data
plot_individual_trees = true;
tree_cell = cell(1,n_blocks);
%% Extract the common-PC coordinates for units in each block.
for group_iter = 1 : numel(units)
    idxs  = 1 : numel( units{group_iter} );
    shift = numel( vertcat( units{1:group_iter} )) - numel( units{group_iter} );
    idxs  = idxs + shift;
    input_data{group_iter} = PC_meds_grouped(idxs,1:ops.nPCs);
end

%% 6) For each block: Get pairwise distances between denoised waveforms (pdist); 
%%    compute hierarchal trees (linkage); compile tree structure (get_tree_info)
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

%% 7) For each pair of adjacent blocks: Compute similarity between each pair of units
%%      (compute_cluster_sim_mat)
for group_iter = 1 : numel(units)-1
    % - compute cluster similarity - %
    % In between each pair of adjacent trees
    [clust_sim_temp, clust_dist_temp] = compute_cluster_sim_mat(tree_cell{group_iter}, ...
                                                                tree_cell{group_iter+1}, ...
                                                                ops);
    clust_sim{group_iter}       = clust_sim_temp;
    clust_dist{group_iter}      = clust_dist_temp;
end


% - plot cluster similarity - %

%% 8) Solve integer programming problem (solve_linkage)

%% Wrapped up optimization problem
[x, X] = solve_linkage(tree_cell, units, clust_sim, ops);

%% If I needed to save the output here, what would I save?
% x, X
% 
%% Used by Consolidate_Figures/waves_PC_link
% % proj_waveforms: unit waveforms in common PC space
% % PC_struct_grouped
% 
