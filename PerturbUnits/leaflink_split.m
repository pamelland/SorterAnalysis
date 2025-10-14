function [new_leaflink] = leaflink_split(old_leaflink, block_with_leaf, leaf_to_split)
%  
%  Provide leaf-to-leaf matrices after splitting 
%  Since both into- and out of- links are affected,
%  force these to be done together.
%
% IDEA: If you split a leaf, it should still be linked to the same units
%   in connected blocks.
%
%  Input: 
%   old_leaflink = cell array of leaf-to-leaf link matrices
%   block_with_leaf    = which block contains the unit to be split
%   leaf_to_split      = which unit to split
%
numLinks = length(old_leaflink);

new_leaflink = cell(size(old_leaflink));

if block_with_leaf > numLinks+1; error('Block number not valid'); end

for k1=1:numLinks
    if k1 == block_with_leaf-1
        % This is linking INTO the block.
        % Increase columns, repeat the column corresponding to the
        %   desired unit
        new_leaflink{k1} = [old_leaflink{k1} old_leaflink{k1}(:,leaf_to_split)];
    elseif k1==block_with_leaf
        % This is linking AFTER the block.
        % Repeat the ROW corresponding to the desired unit
        new_leaflink{k1} = [old_leaflink{k1}; old_leaflink{k1}(leaf_to_split,:)];
    else
        new_leaflink{k1}=old_leaflink{k1};
    end
end


end