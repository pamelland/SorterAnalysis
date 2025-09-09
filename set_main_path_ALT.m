clc
clear paths 

%%
%% _ALT.m
%% On Andrea's computer

%% It doesn't seem like this is used. 
start_in_hours  = 0;
end_in_hours    = 4;

%% path to MATLAB directory

paths.matlab_folder_path  = './';

addpath( genpath(paths.matlab_folder_path) );

%% path to binary file (needed for waveforms)

%paths.bin_file = '/Volumes/PM-HD/FAST_data/VoltageTrace/TETS-01.bin';


%% path to ground truth (needed for ground truth comparisons)
%paths.ground_truth = '/Volumes/PM-HD/FAST_data/GroundTruth/24hrs/Spike_Data.mat';

paths.ground_truth = '/Users/andreakbarreiro/Dropbox/MyProjects_Current/Pake/FUSE/GroundTruth/Spike_Data.mat';
%

%% path to sorted file
% paths.sorted_spikes = sprintf('/Volumes/PM-HD/FAST_data/SorterOutput/MS5/%04d-%04d/STD-14_ClipSize-50',start_in_hours*60,end_in_hours*60);
%paths.sorted_spikes = sprintf('/Volumes/PM-HD/FAST_data/SorterOutput/MS5/%04d-%04d_%04d-%04d/STD-14_ClipSize-50',600,720,1200,1320);

paths.sorted_spikes = sprintf('/Users/andreakbarreiro/Dropbox/MyProjects_Current/Pake/FUSE/Local_Sorter_Output/');

%% print path structure

disp( paths )

%%
