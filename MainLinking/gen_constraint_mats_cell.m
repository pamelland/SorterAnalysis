function [A,B,C] = gen_constraint_mats_cell(tree_cell)
% generate constraint matrices for solving linear programming problem of
% linking trees
% On input: tree_cell   --> cell array whose entries are cells containing
%                           tree structure for each tree to be linked.
% On exit:  A           --> matrix for constaining that each outgoing link
%                           is less than cluster inidcator
%           B           --> matrix for constraining that each incoming link
%                           is less than cluster indicator
%           C           --> matrix for constraining that each leaf node is
%                           only in one selected cluster (node)
% ----------------------------------------------------------------------- %

% get number of trees
n_trees = numel( tree_cell );

% generate size of each tree (number of nodes)
nodes_in_tree = nan( n_trees, 1);
for tree_iter = 1 : n_trees
    nodes_in_tree( tree_iter ) = size( tree_cell{tree_iter}, 1);
end
connections = arrayfun(@(j) nodes_in_tree(j)*nodes_in_tree(j+1), 1:(n_trees-1));
total_connections = sum( connections );


for conn_iter = 1 : (n_trees - 1)
    nc1 = nodes_in_tree( conn_iter  );
    nc2 = nodes_in_tree( conn_iter+1);
    
    for inner_iter = 1 : (n_trees)
        if inner_iter == conn_iter
            A_n{conn_iter,inner_iter} = -1 * eye(nc1);
        else
            A_n{conn_iter,inner_iter} = zeros(nc1, nodes_in_tree(inner_iter) );
        end
    end


    
    for inner_iter = 1 : (n_trees)
        if inner_iter == ( conn_iter + 1 )
            B_n{conn_iter,inner_iter} = -1 * eye(nc2);
        else
            B_n{conn_iter,inner_iter} = zeros(nc2, nodes_in_tree(inner_iter) );
        end
    end


    for inner_iter = 1 : (n_trees-1)
        if inner_iter == conn_iter
            A_c{conn_iter,inner_iter} = repmat(eye(nc1),1,nc2);
        else
            A_c{conn_iter,inner_iter} = zeros(nc1, connections(inner_iter));
        end
    end


    for inner_iter = 1 : (n_trees-1)
        if inner_iter == conn_iter
        
            b1 = 1 : 1 : (nc1 * nc2);
            b2 = nc1 : nc1 : (nc1*nc2);
            b3 = 0 : nc1 : (nc1*(nc2-1));
            B2 = 1* ( b1 <= b2' & b1 > b3');
            B_c{conn_iter,inner_iter} = B2;
        else
            B_c{conn_iter,inner_iter} = zeros(nc2, connections(inner_iter));
        end
    end 
end


for unique_iter = 1 : n_trees

    nc1 = nodes_in_tree( unique_iter  );
    for inner_iter = 1 : n_trees
        if inner_iter == unique_iter
            C_n{unique_iter, inner_iter} = make_unique_constraint( tree_cell{unique_iter} );
        else
            C_n{unique_iter, inner_iter} = zeros(nc1, nodes_in_tree(inner_iter));
        end
    end


    for inner_iter = 1 : n_trees-1
            C_c{unique_iter, inner_iter} = zeros(nc1, connections(inner_iter));
    end
end


A_con = [A_n A_c];
B_con = [B_n B_c];
C_con = [C_n C_c];

A = [];
B = [];
C = [];


for concat_iter = 1 : n_trees-1
    A = [A; horzcat(A_con{concat_iter,:})];
    B = [B; horzcat(B_con{concat_iter,:})];

end

for concat_iter = 1 : n_trees
    C = [C; horzcat(C_con{concat_iter,:})];
end

end