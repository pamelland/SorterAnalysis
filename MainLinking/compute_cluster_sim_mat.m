function [sim_measure, dist_mat] = compute_cluster_sim_mat(tree1,tree2,ops)
% Compute similarity between clusters based on common space

% near neighbors to use for scaling paramater
knn_min = ops.knn_min;

% only use 'gauss'
sim_type = ops.sim_type;

% extract centroids
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