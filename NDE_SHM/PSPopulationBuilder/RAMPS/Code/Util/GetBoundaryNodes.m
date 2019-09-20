function [ BoundNodes ] = GetBoundaryNodes( Node, Parameters, Level )
%GETBOUNDARYNODES Returns the boundary nodes on the specified layer or level
%   Node - Node structure
%   Parameters - Parameters structure
%   Level - String specifying what type of elements to find the boundary nodes of: 'girder',
%           'deck', 'support', 'barreir', or 'sidewalk'

switch Level
    case {'girder', 'beam'}
        layerind = 3;
    case 'deck'
        layerind = 1;
    case 'support'
        layerind = 4;
    case 'barrier'
        layerind = 5;
    case 'sidewalk'
        layerind = 6;
    otherwise
        layerind = 1;
end

for jj=1:length(Node)
    % find populated columns
    y = find(any(Node(jj).ID(:,:,layerind)));
    if layerind==3 && length(y)~=Parameters.NumGirder
        % Select only columns corresponding to girders
        y = y(1:floor((length(y)+1)/Parameters.NumGirder):end);
    end
    
    % Locate the first nonzero (nodeID) entry in each column
    for kk = 1:length(y)
        x1 = find(Node(jj).ID(:,y(kk),layerind),1,'first');
        x2 = find(Node(jj).ID(:,y(kk),layerind),1,'last');
        BNode1(kk) = Node(jj).ID(x1,y(kk),layerind);
        BNode2(kk) = Node(jj).ID(x2,y(kk),layerind);
    end
    
    % Gather boundary node ID numbers
    BoundNodes(:,1,jj) = BNode1;
    BoundNodes(:,2,jj) = BNode2;
   
end

end

