# SorterAnalysis

Overall Description
FUSE (Feature-space Unification of Sorted Epochs) is an algorithm to
track neural units across multiple, individually sorted blocks. 

General Workflow, and where to find the associated files:

| Step | Directory | Description |
----- | ---------| --------| 
| Pre-processing | InflateSnippets |  Create a continuous voltage trace, if necessary |
|  | ExtractWaveforms |  After local sorter, extract sample waveforms for each unit |
| | PostSorter-PreAnalysis |  (?) Compensate for the a removed time gap, if necessary (used when local sorter is kilosort, which fails if there is more than a ## gap between events |
| | RedundantUnits |  Remove units that have only redundant spikes (addresses problem in MS4) |
| FUSE | MainLinking | Main linking program |
| Post-processing | Anything here? | ? |
| Analysis and Visualization |  AmplitudePlots | ? |
|   | ConsolidateFigures | ? |
|   | SorterAsssessmentPlots | ? |
|   | SpikeTrainSimilarity | ? |



CONTENTS: 
| File name | Description |  
| --------- | ----------- |
| **MainLinking/** | *Main algorithm* for FUSE: linking the results of multiple local sorted epochs|
| MainLinking/cluster_trees_by_file.m | Driver routine for FUSE |
| MainLinking/center_spikes.m | Center spikes on their peak (minimum) voltage |
| MainLinking/compute_PC_center.m |  Compute central location of a set of waveforms in PC space |
| MainLinking/compute_PCs_waveforms.m | Apply PCA to a set of waveforms | 
| MainLinking/group_PC_struct.m |  Apply PCA to a *cell array* of sets of waveforms | 
| MainLinking/compute_cluster_scores.m | Compute cluster (unit) quality |
| MainLinking/compute_cluster_sim_mat.m | Compute similarity between units in adjacent blocks, based on common PC space |
| MainLinking/find_leaf.m | Return a list of children of a designated node and their linkage values |
| MainLinking/find_path_to_root.m | Get all parents of a designated node, up to the root. |
| MainLinking/get_tree_info.m |  Beginning from a compact hierarchal tree structure created by *linkage*, extract structure info needed to create constraint matrix for integer programming problem |
| MainLinking/get_constraints_mats_cell.m | Generate constraint matrices for solving linear programming problem |
| MainLinking/make_unique_constraint.m | Helper function for get_constraint_mats_cell.m |
| MainLinking/solve_linkage.m | Solve an integer programming problem to link neural units across sorted epochs | 
| ***Pre-processing*** |   | 
| **ExtractWaveforms/** |  Extract Waveforms |
| **PostSorter-PreAnalysis/** |  |
| **RedundantUnits/** |  |
| ***Visualization*** | |
| **AmplitudeDriftPlots/** |  |
| AmplitudeDriftPlots/drift_amp_test.m |  What is the starting point for this script? |
| AmplitudeDriftPlots/file2.m  |  |
| **ConsolidateFigures/** |   |
| ConsolidateFigures/waves_PC_link.m | 3 figures to illustrate linked units: waveforms, PC space, and trees |
| **MS5_SanityChecks/** |  |
| **SorterAssessmentPlots/** |  |
| **SpikeTrainSimilarity/** |  |
