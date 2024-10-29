function [sim_measure, dist_mat] = compute_cluster_sim_mat(tree1,tree2,ops)
%% compute_cluster_sim_mat: Compute similarity between clusters 
%%    in adjacent blocks, based on common PC space
% ----------------------------------------------------------------------- %
%
% INPUTS:   tree1:      (nNode1 x 5) cell array defining a tree
%           tree2:      (nNode2 x 5) cell array defining a tree
%           ops:        options
%           ops.knn_min:    # of nearest neighbors to use for scaling parameter
%           ops.sim_type  ['gauss']
%
% OUTPUTS:  sim_measure: (nNode1 x nNode2) array with similarity between
%               each pair of nodes (one from tree1, the other from tree2)
%           dist_mat:   (nNode1 x nNode2) like sim_measure; but distance
%               (1-1 functional relationship with sim_measure)
%
% ----------------------------------------------------------------------- %
% Called by: cluster_trees_by_file.m
% Calls: knnsearch
% 
% # of near neighbors to use for scaling paramater
knn_min = ops.knn_min;

% only use 'gauss'
sim_type = ops.sim_type;

% extract centroids of all nodes
% 
% size(c1_mds) = (nNodes1, nPC)
c1_mds = vertcat( tree1{:,4} );
c2_mds = vertcat( tree2{:,4} );

nc1 = size(c1_mds,1);
nc2 = size(c2_mds,1);

% find near neighbors
[col_idx, nn_dist] = knnsearch(c2_mds, c1_mds,'K',nc2);


row_idx = (1:nc1)' .* ones(1, nc2);

% distances in a matrix // sparsity probably not necessary given our number
% of data points
dist_mat = full( sparse(row_idx, col_idx, nn_dist) );
k = median( nn_dist(:, knn_min) );

if strcmp(sim_type, 'gauss')
    sim_measure = exp( -dist_mat.^2 ./ k.^2 );
elseif strcmp(sim_type, 'sigmoid')
    s = ops.s;
    a = exp( -(dist_mat - k) ./ s);
    sim_measure = a ./ (1 + a);
else
    error('Specify ops.sim_type as ''gauss'' or ''sigmoid''')
end



end