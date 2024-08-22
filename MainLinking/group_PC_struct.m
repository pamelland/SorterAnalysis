function [PC_struct_grouped,proj_waveforms_stacked,units_grouped] = group_PC_struct(units,proj_waveforms)
% ----------------------------------------------------------------------- %
% On input:
%   units           <--> cell of unit IDs for each sorting blocks
%   proj_waveforms  <--> cell of denoised waveform averages for each unit in
%                        each block
%
% On exit:
%   PC_struct_grouped       <--> PCs (+other PC stuff) for denoised
%                                waveforms in common PC space
%   proj_waveforms_stacked  <--> Collect all denoised waveforms for all
%                                units across all blocks
%   units_grouped           <--> Unit IDs for those waveforms
% ----------------------------------------------------------------------- %


% stacked waveforms
% 4 channels per waveforms feature hardcoded in
proj_waveforms_stacked = vertcat(proj_waveforms{:});
time_per_chn_samp = size( proj_waveforms_stacked,2 ) / 4;

% stacked units with original indexing
units_grouped_col2 = vertcat( units{:} );

% stacked units with new indexing
units_grouped_col1 = 1:numel(units_grouped_col2);


units_grouped = [units_grouped_col1(:) units_grouped_col2(:)];

proj_waveforms_grouped = cell(size(proj_waveforms_stacked,1), 4);
for wf_iter = 1 : size(proj_waveforms_stacked,1)
    
    proj_waveforms_grouped{wf_iter,1} = reshape( proj_waveforms_stacked(wf_iter, :),time_per_chn_samp,4)';
    proj_waveforms_grouped{wf_iter,2} = 1;
    proj_waveforms_grouped{wf_iter,3} = units_grouped(wf_iter,1);
    proj_waveforms_grouped{wf_iter,4} = [1 2 3 4]; % should change to match waves_cell
end


% extract common PCs

PC_struct_grouped = compute_PCs_waveforms(1,units_grouped(:,1), proj_waveforms_grouped);

end