function [child_list, linkage_list] = find_leaf(Z,node,total_points,child_list, linkage_list)


%% subtract total points from that
if node <= total_points
    child1 = node;
    child2 = -inf;
    linkage = 0;
else
    idx_mkr = node - total_points;
    child1  = Z(idx_mkr,1);
    child2  = Z(idx_mkr,2);
    linkage = Z(idx_mkr,3);
end



%% check if child1 <= total points

% if not do again
if child1 <= total_points
    % fprintf('\nMade it to leaf %d\n',child1);
    child_list = [child_list child1];
else
    [child_list, linkage_list] = find_leaf(Z, child1, total_points, child_list, linkage_list);
end


if child2 <= total_points 
    % fprintf('\nMade it to leaf %d\n',child2);
    child_list = [child_list child2];
    child_list( isinf(child_list) ) = [];
else
    [child_list, linkage_list] = find_leaf(Z, child2, total_points, child_list, linkage_list);
end

linkage_list = [linkage_list linkage];

end