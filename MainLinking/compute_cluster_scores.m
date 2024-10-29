function [link_out] = compute_cluster_scores(tree1,ops)
%% compute_cluster_scores.m: Compute cluster quality based on various methods. 
% %  Most empirical success:  'parent_diff'
% ----------------------------------------------------------------------- %
%
% INPUTS:   tree1:      (nNode x 5) cell array defining a tree
%           ops:        options
%          USED IN THIS FUNCTION
%           ops.alpha:      Linkage value of leaves 
%           ops.link:       Formula for quality of nodes
%               ['zero'/'zero_flip'/'one'/'tier'/'parent_diff']
%  %??% NEEDED: quick summary of what these different options mean
%      Some options use different  "ops." arguments
%       %??% ops.quant: used if ops.link='tier'
%
% OUTPUTS:  link_out:       List of node qualities
% -----------------------------------------------------------------------
% Called by: solve_linkage
% Calls: ??
    
% alpha < -- > what linkage value do you assign leaves ???
alpha = ops.alpha;

% stack up linkage scores
link1 = vertcat( tree1{:,5} );

% assign linkage values to leaves
link1( link1 == 0 ) = inf;
link1( isinf(link1) ) = alpha * min(link1);

if strcmp( ops.link, 'zero')
    
    linkM = max(link1);
    
    link1 =  - (link1) ./ (linkM);
    link_out = link1;
elseif strcmp( ops.link, 'zero_flip')
    
    linkM = max(link1);
    
    link1 =  - (link1) ./ (linkM);
    link_out = -link1;
elseif strcmp( ops.link, 'one')
    
    linkM = max(link1);
    
    link1 =  1 - (link1) ./ (linkM);
    link_out = link1;

elseif strcmp( ops.link, 'tier')

    qs = quantile( link1( link1~= link1(1) ), ops.quants ./ 100 );
    qs = [0 qs(:)'];

    link_out = ( link1(:) >= qs(1:end-1) ) & ( link1(:) < qs(2:end) );
    link_out(end,end) = true;
    sum( link_out,2 )

    link_out = arrayfun(@(row) find(link_out(row,:)), 1:size(link_out,1));
    link_out = 1 - ops.quants( link_out ) ./ 100;
elseif strcmp( ops.link, 'parent_diff')
    % first scale leaves to zero node to 1
    linkM = max(link1);
    
    link1 =  1 - (link1) ./ (linkM);
    
    % then loop through each node and make its linkage into:
    %   (own linkage) - (parent linkage)
    for node_iter = 1 : numel( link1 )
        if isempty( tree1{node_iter,2} )
            
            % what should score be for root ???
            parent_score = 0;
        else
            parent_node = tree1{node_iter,2}(1);
            parent_score = link1( parent_node );
            
        end
        link_out(node_iter) = link1(node_iter) - parent_score ;
    end

end



end