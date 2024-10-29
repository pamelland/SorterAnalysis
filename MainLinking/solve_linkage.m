function [x, X] = solve_linkage(tree_cell, ...
                            units, ...
                            clust_sim, ...
                            ops)
% solve_linkage.m: Function to solve an integer programming problem 
%   that links neural units across n_block sorting blocks.
% ----------------------------------------------------------------------- %
% INPUTS:   tree_cell:  (1 x n_block) cell array of "tree" structures, as produced by get_tree_info.m
%           units:      (1 x n_block) cell array of unit lists 
%           clust_sim:  (1 x (n_block-1)) cell array of matrices, each
%               containing unit-to-unit distances between two adjacent blocks
%           ops:        options
%           ops.nPCs:   Number of PCS [10]
%           ops.linkage_method: ['average']
%%%%%%  Used in "compute_cluster_sim_mat"
%           ops.knn_min:        [18]
%           ops.sim_type: ['gauss']
%%%%%%  Used in this function ("solve_linkage")
%           ops.off_set:    Offset used for node-to-node similarities   [0.3679]
%           ops.lambda:     Overall weight used for node-to-node similarities [1]
%           ops.constraint_type:    Allow chains to begin or end at intermediate blocks ('ineq'), 
%                                   or force them to go end-to-end ('eq')
%           ops.weight_by_leaf_count:   Whether to weight cluster quality by leaf number [0/1]
%%%%%%  Used in "compute_cluster_scores" (from "solve_linkage")
%           ops.alpha:  Linkage value of leaves  [0]
%           ops.link:   Formula for node quality ['parent_diff']
%           ops.quants: Used only if ops.link = 'tier'
%
% OUTPUTS:  x:          (1 x n_block) cell array of {0,1}-arrays indicating which
%                       nodes should be active
%           X:          (1 x (n_block-1) cell array of {0,1}-matrices
%                       indicating inter-block links should be active
%
% ----------------------------------------------------------------------- %
% Called by: cluster_trees_by_file
% Calls:  compute_cluster_scores,  gen_constraint_mats_cell
% Calls:  intlinprog 

% Number of sorter blocks
n_blocks = numel( tree_cell );

%% First get number of nodes in each tree
n_nodes = cell(n_blocks,1);
for block_iter = 1 : n_blocks
    n_nodes{block_iter} = size(tree_cell{block_iter},1);
end

%% Compute Cluster scores
C_scores = nan(sum( [n_nodes{:}] ),1);
for block_iter = 1 : n_blocks
    idxs = 1 : n_nodes{ block_iter };
    shift = sum( [n_nodes{1:block_iter}] ) - n_nodes{block_iter};
    idxs = idxs + shift;
    C_scores(idxs) = compute_cluster_scores(tree_cell{block_iter}, ops);
end

%% Generate constraint matrices and vectors
[A, B, C] = gen_constraint_mats_cell( tree_cell );

% stack them all up into M * x <= b
% M = [A1 A2;
%      B1 B2;
%      C1 ;
%      C2 ];

% <= b
b1 = zeros( size(A,1) + size(B,1), 1);
b2 = ones(  size(C,1), 1);
b = [b1;b2];

%% Objective function to minimize
stacked_clust_sim = [];
for group_iter = 1 : numel( units ) - 1
    stacked_clust_sim = [stacked_clust_sim; clust_sim{group_iter}(:)];
end

f = -[C_scores(:); 
     ops.lambda * (stacked_clust_sim(:) - ops.off_set)];

%% option to weight by leaf count

if ops.weight_by_leaf_count
    leaf_count = cell(n_blocks,1);
    scale = cell(n_blocks + (n_blocks-1),1);
    % For each node: scale its contribution by #of leaves among its
    % children
    for block_iter = 1 : n_blocks
        leaf_count{block_iter} = arrayfun(@(j) numel( tree_cell{block_iter}{j,3} ), 1 : n_nodes{block_iter} );
        scale{block_iter} = leaf_count{block_iter}(:);
    end
    
    % For each possible node-to-node link: scale its contribution by 1
    for block_iter = 1 : n_blocks-1
        scale{block_iter + n_blocks} = ones( numel(leaf_count{block_iter})*numel(leaf_count{block_iter+1}),1 );
        %block_iter
        %scale{block_iter+n_blocks}
    end
    f = vertcat( scale{:} ).*f;
  
end

%% Solve linear program
% - assign all ouput variable to be integer valued - %
intcon = 1 : numel(f);

% - xi in {0,1} \\ lb <= xi <= ub
ub = ones(  numel(f),1);
lb = zeros( numel(f),1);

options = optimoptions('intlinprog','Display','iter',...
                        'OutputFcn', 'savemilpsolutions');


% - solve // Thanks MATLAB - %

if strcmp( ops.constraint_type, 'ineq')
    % - ineq - %
    [xsol, fval, exitflag, output] = intlinprog(  f, ...
                                                intcon, ...
                                                [A;B;C],b, ...
                                                [], ...
                                                [], ...
                                                lb, ...
                                                ub, ...
                                                options);
elseif strcmp( ops.constraint_type, 'eq')

    % - ineq & eq - %
    % - A, B are equality constraints: forces chains to 
    %   go end-to-end
    [xsol,fval,exitflag,output] = intlinprog(  f, ...
                        intcon, ...
                        C, b2, ...
                        [A; B],b1, ...
                        lb, ...
                        ub, ...
                        options);
else
    error('Do you want linear equality or inequality contraints?')
end

% - eq - %
% [xsol,fval,exitflag,output] = intlinprog(  f, ...
%                     intcon, ...
%                     [], [], ...
%                     [A; B; C],b, ...
%                     lb, ...
%                     ub, ...
%                     options);
% - {0,1} for cluster 1 and cluster 2 // x1  x2 -%

for group_iter = 1 : numel( units )
    idxs = 1 : n_nodes{ group_iter };
    shift = sum( [n_nodes{1:group_iter}] ) - n_nodes{group_iter};
    idxs = idxs + shift;
    x{group_iter} = xsol(idxs);
    % x1 = xsol(1:nc1);
    % x2 = xsol(nc1+(1:nc2));
end


Xh = xsol;
Xh(1: sum( [n_nodes{:}] )) = [];
for group_iter = 1 : numel( units)-1
% - {0,1} for linkages - %

    connections = n_nodes{group_iter} * n_nodes{group_iter+1};
    X_temp = Xh(1:connections);
    Xh(1:connections) = [];
    X{group_iter} = reshape(X_temp, n_nodes{group_iter}, n_nodes{group_iter+1});
end

%%
% Check for answers that are not EXACTLY integers (but they should be ...)

integer_sol_tol = eps;
for block_iter = 1 : (n_blocks-1)
    int_bool = ismembertol( X{block_iter}(:), [0 1], integer_sol_tol, 'DataScale', 1);
    if sum( int_bool ) ~= numel( X{block_iter} )
        [row, col] = size( X{block_iter} );
        row_idxs = mod( find(~int_bool) - 1, row )+1;
        col_idxs = ceil( find(~int_bool) / row);
        fprintf('\n*** Links from block %02d to block %02d contain non-integer solutions.', ...
                block_iter, block_iter+1)
        for idx_iter = 1 : numel( row_idxs )
            fprintf('\nLink from cluster %d to cluster %d is %0.8f\n', ...
                row_idxs(idx_iter), col_idxs(idx_iter), X{block_iter}(row_idxs(idx_iter), col_idxs(idx_iter)))
            round_cand = round( X{block_iter}(row_idxs(idx_iter), col_idxs(idx_iter)),0);
            round_bool = input( sprintf('Would you like to round this value to %d?\n\t [1] <--> [yes] || [0] <--> [no] >> ', round_cand) );
            if round_bool == 1
                X{block_iter}(row_idxs(idx_iter),col_idxs(idx_iter)) = round_cand;
            else
                fprintf('Okay. I won''t round. ''run_consolidate_links'' won''t like that. **\n\n\n')
            end
        end
    end
end

