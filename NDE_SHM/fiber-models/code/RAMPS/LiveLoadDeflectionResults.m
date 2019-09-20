function LiveLoadDisp = LiveLoadDeflectionResults(uID, ModelPath, ModelName, NodeID, Parameters)
global rtNodeDisp
%% Boundary Condition 1
BCCaseNum = 1;

LiveLoadResultPath = [ModelPath '\Models_old\' ModelName '_' num2str(BCCaseNum) '_LL.lsa'];

Spectral = 0;
NumPrimary = 0;
NumSecondary = 0;
[iErr, NumPrimary, NumSecondary] = calllib('St7API', 'St7OpenResultFile', uID, LiveLoadResultPath, '', Spectral, NumPrimary, NumSecondary);
HandleError(iErr);

%% Determine Live Load Stresses
% Determine the beam element at midspan
y1 = find(any(NodeID(:,:,3)),1,'first');
y2 = find(any(NodeID(:,:,3)),1,'last');
y = (y2-y1)/(Parameters.NumGirder-1); 

LiveLoadStr = zeros(2, Parameters.NumGirder, Parameters.NumLane, 18);

for j=2:Parameters.NumLane+1
    for i=1:Parameters.NumGirder
        ResultCase = j;
        NodeRes = zeros(6,1);
        
        row = y1 + (i-1)*y;
        x1 = find(NodeID(:,row,3),1,'first');
        x2 = find(NodeID(:,row,3),1,'last');
        
        cl = x1 + floor((x2-x1)/2);
        
        NodeNum = NodeID(cl,row,3);
          
        % Get Results at midspan
        [iErr, NodeRes] = calllib('St7API', 'St7GetNodeResult',...
            uID, rtNodeDisp, NodeNum, ResultCase, NodeRes);
        HandleError(iErr);
        
        LiveLoadDisp(BCCaseNum, i, j-1,:) = NodeRes;
    end
end

iErr = calllib('St7API', 'St7CloseResultFile', uID);
HandleError(iErr);
    
%%  Boundary COndition 2
BCCaseNum = 2;

LiveLoadResultPath = [ModelPath '\Models_old\' ModelName '_' num2str(BCCaseNum) '_LL.lsa'];

Spectral = 0;
NumPrimary = 0;
NumSecondary = 0;
[iErr, NumPrimary, NumSecondary] = calllib('St7API', 'St7OpenResultFile', uID, LiveLoadResultPath, '', Spectral, NumPrimary, NumSecondary);
HandleError(iErr);

%% Determine Live Load Stresses
% Determine the beam element at midspan
y1 = find(any(NodeID(:,:,3)),1,'first');
y2 = find(any(NodeID(:,:,3)),1,'last');
y = (y2-y1)/(Parameters.NumGirder-1); 

LiveLoadStr = zeros(2, Parameters.NumGirder, Parameters.NumLane, 18);

for j=2:Parameters.NumLane+1
    for i=1:Parameters.NumGirder
        ResultCase = j;
        NodeRes = zeros(6,1);
        
        row = y1 + (i-1)*y;
        x1 = find(NodeID(:,row,3),1,'first');
        x2 = find(NodeID(:,row,3),1,'last');
        
        cl = x1 + floor((x2-x1)/2);
        
        NodeNum = NodeID(cl,row,3);
          
        % Get Results at midspan
            [iErr, NodeRes] = calllib('St7API', 'St7GetNodeResult',...
                uID, rtNodeDisp, NodeNum, ResultCase, NodeRes);
            HandleError(iErr);
        
        LiveLoadDisp(BCCaseNum, i, j-1,:) = NodeRes;
    end
end



end % LiveLoadResults()


