# SorterAnalysis

Overall Description
FUSE: 

CONTENTS: 
| File name | Description |  
| --------- | ----------- |
| **MainLinking/** | *Main algorithm* for FUSE: linking the results of multiple local sorted epochs|
| MainLinking/cluster_trees_by_file.m | Driver routine for FUSE |
| MainLinking/center_spikes.m | Center spikes on their peak (minimum) voltage |
| MainLinking/compute_cluster_scores.m | Compute cluster quality |
| MainLinking/compute_cluster_sim_mat.m | Compute similarity between units in adjacent blocks, based on common PC space |
| MainLinking/compute_PC_center.m |  Compute central location of a set of waveforms in PC space |
| MainLinking/compute_PCs_waveforms.m | Apply PCA to a set of waveforms | 
| MainLinking/find_leaf.m | Return a list of children of a designated node and their linkage values |
| MainLinking/find_path_to_root.m | Get all parents of a designated node, up to the root. |
| MainLinking/get_constraints_mats_cell.m | Generate constraint matrices for solving linear programming problem |
| MainLinking/get_tree_info.m |  Beginning from a compact hierarchal tree structure created by *linkage*, extract structure info needed to create constraint matrix for integer programming problem |
| MainLinking/group_PC_struct.m | | 
| MainLinking/make_unique_constraint.m | |
| MainLinking/solve_linkage.m | Solve an integer programming problem to link neural units across sorted epochs | 
| **AmplitudeDriftPlots/** |  |
| AmplitudeDriftPlots/file1.m |  |
| AmplitudeDriftPlots/file2.m  |  |
| **ConsolidateFigures/** |   |
| **ExtractWaveforms/** |  |
| **MS5_SanityChecks/** |  |
| **PostSorter-PreAnalysis/** |  |
| **RedundantUnits/** |  |
| **SorterAssessmentPlots/** |  |
| **SpikeTrainSimilarity/** |  |
