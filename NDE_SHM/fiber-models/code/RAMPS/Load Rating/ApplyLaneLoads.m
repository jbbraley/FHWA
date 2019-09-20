function LoadCase = ApplyLaneLoads(uID, Parameters, LoadCase, LaneBound,Node)
global kAccelerations

%% Determine Nodes within Lane boundaries
for kk = 1:size(LaneBound,2)
    for ii=1:Parameters.Spans
        Deck(ii).Nodes = arrayfun(@(x) Node(ii).ID(find(Node(ii).ID(:,x,1),1,'first'),x,1),1:size(Node(ii).ID(:,:,1),2));
        Deck(ii).Num = arrayfun(@(x) find(Node(ii).Num==Deck(ii).Nodes(x)),1:length(Deck(ii).Nodes));
        for jj=1:Parameters.Rating.NumLane
            % Find Columns of Node.IDs corresponding to Lane edges
            [~,col1] = min(abs(Node(ii).y(Deck(ii).Num)-LaneBound(jj,kk).L(ii,2)));
            [~,col2] = min(abs(Node(ii).y(Deck(ii).Num)-LaneBound(jj,kk).R(ii,2)));

            % Find point loads that will equal distributed load
            Patch(ii,jj).Nodes = Node(ii).ID(:,col1:col2); 
            NumLoads = nnz(Patch(ii,jj).Nodes);
            Corners(1) = find(Node(ii).Num==Patch(ii,jj).Nodes(find(Patch(ii,jj).Nodes(:,1),1,'first'),1));
            Corners(2) = find(Node(ii).Num==Patch(ii,jj).Nodes(find(Patch(ii,jj).Nodes(:,end),1,'first'),end));
            Corners(3) = find(Node(ii).Num==Patch(ii,jj).Nodes(find(Patch(ii,jj).Nodes(:,end),1,'last'),end));
            Corners(4) = find(Node(ii).Num==Patch(ii,jj).Nodes(find(Patch(ii,jj).Nodes(:,1),1,'last'),1));
            Area = polyarea(Node(ii).x(Corners),[0 120 120 0]);
            Load = 64/144*Area/NumLoads; %lbs

            Doubles = zeros(3,1);
            Doubles(3) = -Load;

            % Create Load Case
            iErr = calllib('St7API', 'St7NewLoadCase', uID, ['Live Load', ' - Lane ', num2str(LoadCase-1)]);
            HandleError(iErr);
            iErr = calllib('St7API', 'St7SetLoadCaseType', uID, LoadCase, kAccelerations);
            HandleError(iErr);
            Defaults = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
            iErr = calllib('St7API', 'St7SetLoadCaseDefaults', uID, LoadCase, Defaults);
            HandleError(iErr);
            iErr = calllib('St7API', 'St7SetLoadCaseMassOption', uID, LoadCase, 0, 0);
            HandleError(iErr);

            % Apply point loads to nodes
            for k=col1:col2
                for p=1:length(Node(ii).ID(:,k))
                    if Node(ii).ID(p,k,1)==0
                        continue
                    end
                    NodeNum = Node(ii).ID(p,k,1);
                    iErr = calllib('St7API', 'St7SetNodeForce3', uID, NodeNum, LoadCase, Doubles);
                    HandleError(iErr);
                end
            end
            LoadCase=LoadCase+1;
        end
    end
end

end % ApplyLaneLoads()