function [parent_list] = find_path_to_root(node,Z,parent_list)
% find_path_to_root: Get all parents up the root.
%
% INPUTS:
%   Z:              (n_nodes x 3)  matrix encoding binary tree; each row contains a merger,
%                   including 2 node IDs and the height at which merger occured 
%   node:           designated/current node
%   parent_list:     (IF CALLED RECURSIVELY) downstream nodes

Z(:, end+1) = (size(Z, 1) + 1 + (1 : size(Z, 1))); % make a column for parents

node_idx   = find(Z(:,1) == node | Z(:,2) == node);

while node_idx < size(Z,1)

    parent_idx = Z(node_idx,end);
    parent_list = [parent_list parent_idx];
    parent_list = find_path_to_root( parent_idx, Z, parent_list);
    node_idx = parent_list(1);
   
end