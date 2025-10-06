% leaf_to_leaf_driver.m 
%
% Make a function?
%
% Inputs:
%   tree_cell{:}: cell structure encoding info about each dendrogram 
%     (each entry is the output of a call to get_tree_info)
%   X: output of cluster_trees_by_file; linking matrix for each pair of
%      subsequent blocks
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



% Note: it is possible for the sum to be either more or less than the
% number of leaves
%  For example, compare a pair of blocks where links are
%   1->1
%   2->2
%   3->3
% (total sum of '3' over leafLink)
%
% vs. where 
% % {1,2,3}->{1,2,3}
% (total sum of '9' over leafLink; as 1 links to 1,2,3; 2 links to 1,2,3,
% etc..)
%
for j1=1:numLinks
    disp(['Block ' num2str(j1) ' to Block ' num2str(j1+1)] )
    disp(['Number of leaves in Block ' num2str(j1) ': ' num2str(size(leafProj{j1},1))])
    disp(['Number of leaves in Block ' num2str(j1+1) ': ' num2str(size(leafProj{j1+1},1))])
    disp(['Total number of leaf-to-leaf connections: ' num2str(sum(sum(leafLink{j1})))])
end