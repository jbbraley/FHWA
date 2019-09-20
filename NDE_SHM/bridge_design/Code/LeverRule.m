function [ DF ] = LeverRule( Parameters )
%Distance to load furthest to exterior
FarLoadDist = max(Parameters.GirderSpacing)+Parameters.Overhang-Parameters.Barrier.Width-min(Parameters.Sidewalk.Right, Parameters.Sidewalk.Left)-24;

%Number of loads that will fit before the second girder in
NumLoads = floor(FarLoadDist/(6*12))+1;

% Apply multi-presence factor
lanes = ceil(NumLoads/2);
if lanes>3
    lanes = 4;
elseif lanes < 1
    lanes = 1;
end
MultiPresence = Parameters.Design.MulPres(lanes);

%Distance to the load closest to second girder in
LastLoadDist = rem(FarLoadDist, 6*12);

%Distance from second girder to all loads
LoadDist = [FarLoadDist:-(6*12):LastLoadDist];

%Distribution factor
DF = (sum(LoadDist)/min(Parameters.GirderSpacing)*MultiPresence)/2;
end

