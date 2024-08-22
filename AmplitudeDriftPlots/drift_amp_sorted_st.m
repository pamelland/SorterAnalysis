%%
unit_list = [15];
N = 10000;

Fs = 30000;
t_start = 0;
t_end   = 12;
mean_window_hours = 1/6;

C1 = [0.05 0.05 0.05;
      0.25 0.25 0.25;
      0.5 0.5 0.5;
      0.75 0.75 0.75];

C1 = [1 0.5 0;
      0 0.5 1;
      1 0.5 1;
      0 0.5 0];


figure
% tt = tiledlayout(numel(unit_list),1);
patch([10 12 12 10], [-1000 -1000 1000 1000], ...
    [0.95 0.95 0.95], ...
    'EdgeColor', 'none')

patch([20 22 22 20], [-1000 -1000 1000 1000], ...
    [0.95 0.95 0.95], ...
    'EdgeColor', 'none')
hold on

yMIN = 0;
yMAX = 0;

% Amplitudes are only sampled. Those without amplitudes are nan
events_with_amps = ~isnan( st_amps(:,4) );

for unit_iter = 1 : numel(unit_list)
    unit_no = unit_list( unit_iter );
    
    unit_events_all = st_amps(:,2) == unit_no; 
    unit_events_with_amps = events_with_amps & unit_events_all;
    
    unit_times = st_amps( unit_events_with_amps );
    
    
    unit_amps = st_amps( unit_events_with_amps, 4:7 );
    

    N_samps = min(N, sum(unit_events_with_amps));
    samps = sort( randperm( sum(unit_events_with_amps), N_samps) );
    
    temp_times_samps = unit_times(samps)' ./ (60*60);


    unit_sliding_means = movmean( unit_amps(samps,:), mean_window_hours, ...
                                  'SamplePoints',temp_times_samps);

    unit_sliding_stds = movstd( unit_amps(samps,:), mean_window_hours, ...
                                  'SamplePoints',temp_times_samps);
    % nexttile()
    hold on
    for j=1:4

        mean_line   = unit_sliding_means(:,j)';
        bottom_line = mean_line - 1*unit_sliding_stds(:,j)';
        top_line    = mean_line + 1*unit_sliding_stds(:,j)';
        % plot(temp_times_samps, unit_amps_block(samps,j).*10^6,'-', ...
        %     'color', [C1(j,:) 0.2]);
        patch([temp_times_samps  fliplr(temp_times_samps)], ...
              [bottom_line  fliplr( top_line )], ...
              C1(j,:), ...
              'FaceAlpha', 0.05, ...
              'EdgeColor', C1(j,:), ...
              'LineWidth', 0.5)
        plot(temp_times_samps, mean_line, ...
            'Color', C1(j,:), ...
            'LineWidth',1)
        ax = gca;
        ax.TickDir = 'out';
        box off
        % grid off
        % yMIN = min(yMIN, min(unit_amps_block(samps,j).*10^6));
        % yMAX = max(yMAX, max(unit_amps_block(samps,j).*10^6));

    end
end

% for j = 1 : numel(unit_list)
%     nexttile(j)
%     xticks(0:1:max(xlim))
%     if j < numel(unit_list)
%         xticklabels({});
%     else
%         xlabel('Hours since recording start')
%     end
%     ylabel('$\mu$V', 'Interpreter','latex')
%     % ylim([yMIN yMAX])
%     ylim(ylim)
%     text(max(xlim), min(ylim), ...
%         sprintf('Sorted unit %d', unit_list(j)), ...
%         'HorizontalAlignment','right', ...
%         'VerticalAlignment','bottom')
% end

xticks(10:2:22)
xlim([10 22])
ylim([-410 0])
tt.TileSpacing = 'compact';
fig_width   = 1.75;
fig_height  = 1;

set(gca, 'FontSize', 8)
resize_figure(gcf, gca, fig_width, fig_height, 'inches');

% tt.Units = 'inches';
% set(gcf, 'Units', 'Inches')
% set(gcf, 'Position', [0 0 10 10])
% % tt.OuterPosition = [0 0 3*[fig_width fig_height]];
% tt.InnerPosition = [fig_width/4 fig_width/4 fig_width fig_width];
%%
% figure
% scatter(temp_times(samps) ./ (60 * 60), unit_amps_block(samps,:).*10^4, 10, ...
%     C1);
% 
% xticks(0:1:max(xlim))
% grid on
% set(gca, 'LineWidth', 1.5)
% title(sprintf('Unit: %d', unit_no))