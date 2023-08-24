function [K_cross] = plot_ccg(st1, ...
                              st2, ...
                              units1, ...
                              units2, ...
                              ops)
% Plot cross / autocorrelogram

tic
Fs = ops.Fs;


for t1 = 1:numel(units1)
    unit1_label = units1( t1 );
    unit1_idxs = find( st1(:,2) == unit1_label );
    spike_train1 = st1(unit1_idxs,1);
    for t2 = 1 : numel(units2)
        unit2_label = units2( t2 );
        unit2_idxs = find( st2(:,2) == unit2_label );
        spike_train2 = st2(unit2_idxs,1);
        [K, ~, ~, ~, ~] = ccg(spike_train1, spike_train2, 500, 1/1000); % % compute the auto-correlogram with 500 bins at 1ms bins
        K_cross{t1,t2} = K;
%         K_cross{t2,t1} = K;
    end
end
toc

figure
tt = tiledlayout(numel( units1 ), numel( units2 ) );
C1 = [135 135 255] ./ 255;
C2 = [255 135 135] ./ 255;
for i = 1 : numel(units1)
    for j = 1 : numel(units2)
        nexttile
        K_temp = K_cross{i,j};
        if units1(i) == units2(j)
            K_temp( ceil( numel(K_temp)/2 ) ) = 0;
            CC = C2;
        else
            CC = C1;
        end
        bar( (-500:500) ./ 1000, (K_temp), 'FaceColor', CC, ...
            'FaceAlpha', 1)
        xlim([-50 50]./1000)
        YLIM = ylim;
        ylim(YLIM) % just fix y limits to not change
        title(sprintf('st1 unit: %d vs st2 unit: %d', units1(i), units2(j)), ...
            'FontWeight', 'normal')
        line([-11 11;-11 11]./1000, ylim, 'Color', 'k')
        line([0 0], ylim, 'Color', [0.3 0.3 0.3 0.7], 'LineStyle', '--')
        ax = gca;
        ax.TickDir = 'out';
        if i ~= numel(units1)
            xticklabels({})
        end
        box off
    end
end
tt.TileSpacing = 'compact'
tt.Padding = 'tight';
end

