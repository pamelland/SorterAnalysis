function [tree_cell] = get_tree_info(Z,leaf_list,leaf_coords,cent_func)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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