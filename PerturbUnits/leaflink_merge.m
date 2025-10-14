function [new_leaflink] = leaflink_merge(old_leaflink, block_with_leaf, leaf_to_merge_list)
%  
%  Provide leaf-to-leaf matrices after merging 
%  Since both into- and out of- links are affected,
%  force these to be done together.
%
% IDEA: If you merge leaves, the merged unit should be linked to 
% %    each of the units that any of its components' 
% %    targets in connected blocks.
%
%  Input: 
%   old_leaflink = cell array of leaf-to-leaf link matrices
%   block_with_leaf    = which block contains the units to be merged
%   leaf_to_merge_list = which units to merge
%
numLinks = length(old_leaflink);

new_leaflink = cell(size(old_leaflink));

if block_with_leaf > numLinks+1; error('Block number not valid'); end

% This is the one we keep. The others are REMOVED
leaf_to_keep = leaf_to_merge_list(1);

for k1=1:numLinks
    if k1 == block_with_leaf-1
        % This is linking INTO the block.
        % Decrease columns, repeat the column corresponding to the
        %   desired unit
        temp     = old_leaflink{k1};
        % Replace with a vector that is 1 if ANY of the merged units 
        % 
        temp(:,leaf_to_keep) = any(temp(:,leaf_to_merge_list),2);
        % Remove unwanted units
        temp(:,leaf_to_merge_list(2:end))=[];

        new_leaflink{k1} = temp;
    elseif k1==block_with_leaf
        % This is linking AFTER the block.
        % Repeat the ROW corresponding to the desired unit
        temp     = old_leaflink{k1};
        % Replace with a vector that is 1 if ANY of the merged units 
        % 
        temp(leaf_to_keep,:) = any(temp(leaf_to_merge_list,:),1);
        % Remove unwanted units
        temp(leaf_to_merge_list(2:end),:)=[];
        new_leaflink{k1} = temp;
    else
        new_leaflink{k1}=old_leaflink{k1};
    end
end


end