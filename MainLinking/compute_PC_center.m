function [center_measure,label_id] = compute_PC_center(score,labels,cent_func)
% compute_PC_center: Compute central location of a set of waveforms in PC space
% INPUTS:
%   score       --> PC scores [n_obs  x  obs_dim]
%   labels      --> labels for PC [n_obs x 1]
%   cent_func   --> central measure for PCs [function_handle]
% %        (such as median, mean, mode, ...)
%
% OUTPUTS:
%   center_measure: [n_labels x obs_dim] 
%       Center for each distinct class (e.g. label = 1, 2, 3, etc..)
%   label_id:       [n_labels x 1] list of unique label IDs
%
% Called by: cluster_trees_by_file
%

label_id = unique( labels(:) );
center_measure = nan(numel(label_id), size(score,2));

for label_iter = 1 : numel(label_id)
    curr_label = label_id( label_iter );
    curr_idxs  = labels == curr_label;

    center_measure(label_iter, :) = cent_func( score( curr_idxs, :),1 );
end