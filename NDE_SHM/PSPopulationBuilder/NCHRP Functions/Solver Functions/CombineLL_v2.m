function LLResults = CombineLL_v2(LLResults,Parameters)

% reduce data and fix dynamic impact factor
TruckLBeamForce = LLResults.TruckLBeamForce(:,:,:,:,:,:,[1 4 6]);
LaneLBeamForce = LLResults.LaneLBeamForce(:,:,:,:,:,:,[1 4 6]);

% Obtain all possible lane combinations
vect = 1:Parameters.Spans;
vect = padarray(vect, [0,Parameters.Spans-1],'pre');
LaneComb = unique(nchoosek(vect,Parameters.Spans),'rows');

% Pre-allocate
CombinedLaneLoads = [];
CombinedLoads = [];
TotalCombinedLoads = [];

Trucks = size(LLResults.TruckLNodeRxn,4);

for q = 1:size(LaneComb, 1)

% Superposition of different lane combinations
spans = nonzeros(LaneComb(q,:));
CombinedLaneLoads = cat(7,CombinedLaneLoads,permute(sum(LaneLBeamForce(:,:,:,:,spans,:,:),5),[1 2 3 4 7 6 5]));

% Superposition of trucks with different lane combinations
% CombinedLoads:
    % 1 = beam elements
    % 2 = girders
    % 3 = spans
    % 4 = lanes
    % 5 = result 
    % 6 = lane positions
    % 7 = total Lane/truck combinations
for p = 1:Trucks
    CombinedLoads = cat(7,CombinedLoads, CombinedLaneLoads(:,:,:,:,:,:,q)+permute(TruckLBeamForce(:,:,:,:,p,:,:),[1 2 3 4 7 6 5]));
end

end

% Get resutls for multiple presence combinations

% Obtain all possible multiple presence combinations
vect = 1:Parameters.Rating.LRFD.NumLane;
vect = padarray(vect, [0,Parameters.Rating.LRFD.NumLane-1],'pre');
MultiPresComb = unique(nchoosek(vect,Parameters.Rating.LRFD.NumLane),'rows');

for q = 1:size(MultiPresComb,1)

lanes = nonzeros(MultiPresComb(q,:));
NumRatingLanes = length(lanes);

% Multi-presence reduction factor
if NumRatingLanes>3
    NumRatingLanes = 4;
end
redfact = Parameters.Rating.LRFD.MulPres(NumRatingLanes);

% Superposition of multipresence combinations
TotalCombinedLoads = cat(7,TotalCombinedLoads,permute(sum(CombinedLoads(:,:,:,lanes,:,:,:),4),[1 2 3 5 6 7 4])*redfact);

end

% Total Combined Loads 
% [BeamElements Girders Spans Resultants Divisions LaneComb MultiComb]
LLResults.TotalCombinedLoads = permute(TotalCombinedLoads, [1 2 3 5 6 7 4]);

% Total Combined Reactions
LLResults.TotalCombinedRxns = CombineRxns(Parameters,LLResults);

end