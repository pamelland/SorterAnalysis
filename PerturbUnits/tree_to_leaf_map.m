function [leafProj,leafLink] = tree_to_leaf_map(tree_cell,X)
%tree_to_leaf_map
%
%  Project tree-to-tree link matrices down
%    to leaf-to-leaf link matrices
% 
% Inputs:
%   tree_cell{:}: cell structure encoding info about each dendrogram 
%     (each entry is the output of a call to get_tree_info)
%   X: output of cluster_trees_by_file; linking matrix for each pair of
%      subsequent blocks
%
% Outputs:
%   leafProj: cell structure with a matrix for each tree
%       leafProj{k} is nLeaf(k) x nNode(k) 
%       leafProj{k}(i,j)=1 iff leaf{k}(i) is a descendant of node{k}(j)
%
%   leafLink: cell structure w/ matrix for each link
%       leafLink{k} is nLeaf(k) x nLeaf(k+1)
%       leafLink{k}(i,j)=1 iff some ancestor of leaf{k}(i)
%           is linked to some ancestor of leaf{k+1}(j)
%
numTrees = length(tree_cell);
numLinks = length(X);

leafProj = cell(numTrees,1);
for j1=1:numTrees
    leaf_list = tree_cell{j1}(:,3);
    nnode_j   = length(leaf_list);
    all_leaf      = unique(cell2mat(leaf_list'));
    nleaf_j         = max(all_leaf);

    leafProj_j   = zeros(nleaf_j, nnode_j);
    for j2=1:nnode_j
        leafProj_j(leaf_list{j2},j2)=1;
    end
    leafProj{j1}=leafProj_j;
end


% This cell contains leaf-to-leaf connections
% which "mods out" the tree structure
% It encodes whether a node which contains set A of leaves
%   in Block j was linked to set B of leaves in Block j+1
leafLink = cell(numLinks,1);
for j1=1:numLinks
    leafLink{j1}=leafProj{j1}*X{j1}*leafProj{j1+1}';
end


end