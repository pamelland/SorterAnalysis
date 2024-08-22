function [center_measure,label_id] = compute_PC_center(score,labels,cent_func)
% On input:
%   score       --> PC scores [n_obs  x  obs_dim]
%   labels      --> labels for PC (likely from a clustering)
%   cent_func   --> central measure for PCs (median, mean, mode, ...)

label_id = unique( labels(:) );
center_measure = nan(numel(label_id), size(score,2));

for label_iter = 1 : numel(label_id)
    curr_label = label_id( label_iter );
    curr_idxs  = labels == curr_label;

    center_measure(label_iter, :) = cent_func( score( curr_idxs, :),1 );
end