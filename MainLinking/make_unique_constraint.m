function [idctr_mat] = make_unique_constraint(tree)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
ncs = size(tree,1);

idctr_mat = zeros(ncs);
for clust_iter = 1 : ncs
    parents = tree{clust_iter,2};
    parents = [clust_iter parents];
    idctr_mat( clust_iter, parents ) = 1;
end