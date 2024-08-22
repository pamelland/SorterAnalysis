function [newSortObject,discardObject] = remove_redundant_units(sortObject,redunThresh,binSize, units_to_check)
%
% remove_redundant_units: remove redundant units from a file produced by MS4 or MS5
%   INPUTS: 
%       sortObject:  structure containing results of spike sorting
%       redunThresh:  redundancy threshold, expressed as % overlap in zero
%               CCG bin
%       binSize:      bin size (in s) for computing CCG
%           
%   OUTPUTS:
%       newSortObject: new structure
%           ORIGINAL UNIT INDICES ARE PRESERVED
%       discardObject: all discarded spikes, saved in the same format
%           (but with their original unit numbers)
%
%% Note: I wrote this to do this thing where I only do the upper half of 
%% the CCG, and then have to flip back and forth between two views to
%% decide on the redundant unit.  (i.e. 4 vs. 5). 
%% This may be unneccessary. I think that you can possibly just use the
%% symmetric CCG matrix, multiply on the right by diagonal matrix to get
%% ones on the diagonal, and then use the COLUMNS as the signifier.
%% i.e. If 0.99 appears in column 6, you remove unit 6.
%% 
%% This would be simpler!! Don't have time to think through it right now
%% though

% sortObject must contain (see Mountainsort doc for definitions):
%     unit_ids:
%     num_segment:
%     sampling_frequency:
%     spike_indexes_seg0:
%     spike_labels_seg0:

%% Prepare to compute CCGs
nUnits = length(sortObject.unit_ids);

spike_times_all = double(sortObject.spike_indexes_seg0)/sortObject.sampling_frequency;
spike_times = cell(nUnits, 1);

for j1=1:nUnits
    whereID = find(sortObject.spike_labels_seg0==j1);
    spike_times{j1}=spike_times_all(whereID);
end

%% Compute CCGs
nbins = 50;
allCCG = cell(nUnits);

for j1=1:nUnits
    st1 = spike_times{j1};
    for j2=j1:nUnits
        st2 = spike_times{j2};
        [K, Qi, Q00, Q01, Ri] = ccg(st1, st2, nbins, binSize);
        allCCG{j1,j2}=K;

    end
end

%% Extract "0" bin; finds spike coincidences
zeroCCG = zeros(nUnits);

for j1=1:nUnits
    for j2=j1:nUnits
        zeroCCG(j1,j2)=allCCG{j1,j2}(nbins+1);
    end
end
% Flips so that we see C_(k given j) rather than C(j given k)
zeroCCG_flip = zeroCCG';

selfCountDiag       = diag(diag(zeroCCG));
invSelfCountDiag    = inv(selfCountDiag);

%% Check for redundancy. Iteratively remove units until 
%% there is no redundancy over redunThresh
badUnits = [];
overlapUnit    = [];
overlapPerc    = [];

goodUnits = 1:nUnits;
r1flag = 1;
r2flag = 1;
while (r1flag || r2flag)
    %% One side of the CCG matrix
    overlapFrac  = zeroCCG(goodUnits,goodUnits)*invSelfCountDiag(goodUnits,goodUnits);
    %% remove ones, we don't care about them
    worstR = max(max(overlapFrac - eye(size(overlapFrac))));
    if (worstR < redunThresh)
        r1flag = 0;  %no redundant units
    else
        [I,J]=find(overlapFrac==worstR);

        % add "J" to bad units; it should be removed
        badUnits = [badUnits goodUnits(J(1))];
        overlapUnit = [overlapUnit goodUnits(I(1))];
        overlapPerc = [overlapPerc worstR];

        % Update goodunits
        goodUnits = setdiff(goodUnits,badUnits);
    end

    %% The other side of the CCG matrix
    overlapFrac  = zeroCCG_flip(goodUnits,goodUnits)*invSelfCountDiag(goodUnits,goodUnits);
    %% remove ones, we don't care about them
    worstR = max(max(overlapFrac - eye(size(overlapFrac))));
    if (worstR < redunThresh)
        r2flag = 0;  %no redundant units
    else
        [I,J]=find(overlapFrac==worstR);

        % add "J" to bad units; it should be removed
        badUnits = [badUnits goodUnits(J(1))];
        overlapUnit = [overlapUnit goodUnits(I(1))];
        overlapPerc = [overlapPerc worstR];
        
        % Update goodunits
        goodUnits = setdiff(goodUnits,badUnits);
    end    

end

%% Make sure "unit_ids we send back coincide with 
%% original ones we were given
goodUnits   = sortObject.unit_ids(goodUnits);
badUnits    = sortObject.unit_ids(badUnits);

%% goodUnits are the ones we want to keep
%% badUnits to discard
discardObject = [];
discardObject.unit_ids      = badUnits;
discardObject.num_segment   = sortObject.num_segment;
discardObject.sampling_frequency   = sortObject.sampling_frequency;

whichDisc = ismember(sortObject.spike_labels_seg0,badUnits);
discardObject.spike_indexes_seg0    = sortObject.spike_indexes_seg0(whichDisc);
discardObject.spike_labels_seg0     = sortObject.spike_labels_seg0(whichDisc);

discardObject.overlapUnit=overlapUnit;
discardObject.overlapPerc=overlapPerc;

%% To keep
newSortObject = [];
newSortObject.unit_ids      = goodUnits;
newSortObject.num_segment   = sortObject.num_segment;
newSortObject.sampling_frequency   = sortObject.sampling_frequency;

newSortObject.spike_indexes_seg0    = sortObject.spike_indexes_seg0(not(whichDisc));
newSortObject.spike_labels_seg0     = sortObject.spike_labels_seg0(not(whichDisc));

end