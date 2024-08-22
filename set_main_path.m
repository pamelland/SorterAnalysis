clc
clear paths 
%%

start_in_hours  = 10;
end_in_hours    = 22;

%% path to MATLAB directory

paths.matlab_folder_path  = './';

addpath( genpath(paths.matlab_folder_path) );

%% path to binary file (needed for waveforms)

paths.bin_file = '/Volumes/PM-HD/FAST_data/VoltageTrace/TETS-01.bin';


%% path to ground truth (needed for ground truth comparisons)
paths.ground_truth = '/Volumes/PM-HD/FAST_data/GroundTruth/24hrs/Spike_Data.mat';


%% path to sorted file
% paths.sorted_spikes = sprintf('/Volumes/PM-HD/FAST_data/SorterOutput/MS5/%04d-%04d/STD-14_ClipSize-50',start_in_hours*60,end_in_hours*60);
paths.sorted_spikes = sprintf('/Volumes/PM-HD/FAST_data/SorterOutput/MS5/%04d-%04d_%04d-%04d/STD-14_ClipSize-50',600,720,1200,1320);

%% print path structure

disp( paths )

%%
