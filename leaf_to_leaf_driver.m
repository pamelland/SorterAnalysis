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

% Run this AFTER a call to cluster_trees_by_file.m

[leafProj,leafLink] = tree_to_leaf_map(tree_cell,X);

leafLink

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


% Try splitting a unit
nb = 2;
whichu = 5;
disp(['After splitting ' num2str(whichu) ' on ' num2str(nb)])
newll = leaflink_split(leafLink,nb,whichu);
newll


% After merging two units
nb2 = 1;
whichu2 = [7 8 11];
disp(['After merging ' num2str(whichu2) ' on ' num2str(nb2)])
newll2 = leaflink_merge(leafLink,nb2,whichu2);
newll2
