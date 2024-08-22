ccg_ops.Fs = 30000;

%%% make plot
% st1, st2 already loaded into workspace
% set use st1 = st1 and st2 = st1 for autocorr

plot_ccg(st1, ...
         st1, ...
         [5], ..., ...
         ccg_ops)