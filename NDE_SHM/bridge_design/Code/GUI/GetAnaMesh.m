function meshData = GetAnaMesh(Node)
% Get x and y coords From Node.ID
for i=1:length(Node)
    nID{i} = nonzeros(Node(i).ID(:,:,1));
    X{i} = Node(i).x(nonzeros(Node(i).ID(:,:,1)));
    Y{i} = Node(i).y(nonzeros(Node(i).ID(:,:,1)));
    
    % Get boundary nodes
    for j=1:size(Node(i).ID(:,:,1),2) % columnwise iteration
        I = find(Node(i).ID(:,j,1),1,'first');
        xBn{i}(j) = Node(i).x(Node(i).ID(I,j,1));
        yBn{i}(j) = Node(i).y(Node(i).ID(I,j,1));
        
        I = find(Node(i).ID(:,j,1),1,'last');
        xBf{i}(j) = Node(i).x(Node(i).ID(I,j,1));
        yBf{i}(j) = Node(i).y(Node(i).ID(I,j,1));
    end
end
meshData.nodeID = vertcat(nID{:});
meshData.x = vertcat(X{:})';
meshData.y = vertcat(Y{:})';
meshData.xB = [xBn{:}'; xBf{:}'];
meshData.yB = [yBn{:}'; yBf{:}'];
end