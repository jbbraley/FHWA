function AddOverlay( uID, Node, Parameters,OverlayThickness ,LoadCase)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Compute Structural Mass for each Node
% Pressure 
density = 150/12^3; %pci


%% Find Node ID's of nodes in the roadway
for ii = 1:length(Node)
    
    % Tributary Area
    area = Parameters.Model.LMeshSize(ii)*Parameters.Model.WMeshSize;
    % Compute nodal NS Mass
    mass = area*OverlayThickness*density;
    % Put together vector for API command
    Doubles = [mass 1 0 0 0];

    RoadNodes{ii} = reshape(Node(ii).ID(:,~any(Node(ii).ID(:,:,6)),1),[],1);
    IDs = RoadNodes{ii}(RoadNodes{ii}~=0);
    for jj=1:length(IDs)
        % Add structural mass to found nodes
        iErr = calllib('St7API', 'St7SetNodeNSMass5', uID, IDs(jj), LoadCase, Doubles);
        HandleError(iErr);
    end
end

