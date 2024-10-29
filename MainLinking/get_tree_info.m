function [tree_cell] = get_tree_info(Z,leaf_list,leaf_coords,cent_func)
% get_tree_info: Beginning from a compact hierarchal tree structure created
%       by ``linkage", extract structure info needed to create constraint
%       matrix for integer programming problem
% INPUTS:
%   Z:          (n_nodes x 3)  matrix encoding binary tree; each row contains a merger,
% %                 including 2 node IDs and the height at which merger occured 
%   leaf_list:  (n_leaf x 1) list of nodes which are leafs in the tree
%   leaf_coords: (n_leaf x nPC): coordinates of each leaf in PC space
%   cent_func:  (function_handle): function to use to get coordinates for
%           non-leaf nodes.
% OUTPUTS:
%   tree_cell:  (n_nodes x 5) cell array
%   tree_cell{:,1}:     Node IDs
%   tree_cell{:,2}:     All ancestors of each node (path_to_root)
%   tree_cell{:,3}:     All leafs which are children of each node
%   tree_cell{:,4}:     Coordinates of each node in PC space
%   tree_cell{:,5}:     Linkage value of each node
%
% Called by: cluster_trees_by_file
% Calls: find_path_to_root, find_leaf
%

nodes = sort( [unique(Z(:,1)); unique(Z(:,2))] );

tree_cell = cell( numel(nodes), 5);
for node_iter = 1 : numel(nodes)
    curr_node = nodes( node_iter );
    [children_nodes,linkages] = find_leaf(Z,curr_node, numel(leaf_list), [],[]);
    children_nodes = sort( children_nodes);
    leaf_nodes     = leaf_list( ismember( leaf_list, children_nodes ) );
    centroid       = cent_func( leaf_coords( leaf_nodes, :), 1 );
    path_to_root   = find_path_to_root( curr_node, Z, []);
    
    linkage = linkages(end);
    tree_cell{ node_iter,1 } = curr_node;
    tree_cell{ node_iter,2 } = path_to_root;
    tree_cell{ node_iter,3 } = leaf_nodes;
    tree_cell{ node_iter,4 } = centroid;
    tree_cell{ node_iter,5 } = linkage;
end