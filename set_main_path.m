clc
clear paths 


%% path to MATLAB directory

paths.matlab_folder_path  = './';

addpath( genpath(paths.matlab_folder_path) );

%% path to binary file (needed for waveforms)

paths.bin_file = '/Volumes/PM-HD/FAST_data/VoltageTrace/TETS-01.bin';


%% path to ground truth (needed for ground truth comparisons)
paths.ground_truth = '/Volumes/PM-HD/FAST_data/GroundTruth/24hrs/Spike_Data.mat';


%% path to sorted file
paths.sorted_spikes = '/Volumes/PM-HD/FAST_data/SorterOutput/0000-0120/';


%% print path structure

disp( paths )
