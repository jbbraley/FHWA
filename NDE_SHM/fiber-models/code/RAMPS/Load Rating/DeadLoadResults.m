function [DeadLoad] = DeadLoadResults(uID, ModelPath, ModelName, Node, Parameters)
global tyBEAM rtBeamStress rtBeamForce stBeamLocal kNodeReact stBeamGlobal
%% Deck Dead Load
DeadLoadType = 1;

% DeadLoad.StrPos = zeros(2, 2, Parameters.NumGirder, 18);
DeadLoad.Rxn = zeros(2, 4, Parameters.NumGirder, 6);

DeadLoadResultPath = [ModelPath ModelName '_' num2str(DeadLoadType) '.lsa'];

Spectral = 0;
NumPrimary = 0;
NumSecondary = 0;
[iErr, NumPrimary, NumSecondary] = calllib('St7API', 'St7OpenResultFile', uID, DeadLoadResultPath, '', Spectral, NumPrimary, NumSecondary);
HandleError(iErr);
if Parameters.Spans~=2
    % Determine Dead Load Stresses
    if Parameters.Spans == 1
        intspans = 1;
    else
        intspans = 2:Parameters.Spans-1;
    end
    for ii = intspans
        % Determine the beam element at midspan
        y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
        y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
        y = (y2-y1)/(Parameters.NumGirder-1); 

        for i=1:Parameters.NumGirder
            NumColumns = 18;
            ResultCase = 1;
            BeamRes = zeros(NumColumns,1);
            BeamF = zeros(6,1);

            row = y1 + (i-1)*y;
            x1 = find(Node(ii).ID(:,row,3),1,'first');
            x2 = find(Node(ii).ID(:,row,3),1,'last');

            cl = x1 + floor((x2-x1)/2);

            midspan = Node(ii).ID(cl,row,3);
            BeamNum = Node(ii).ElementCon(midspan,1);

            EltData = 0;
            [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
            HandleError(iErr);

            if rem(x2-x1,2) ~= 0 % Even number of nodes.  Get results at middle of element
                BeamPos = EltData/2;
                [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                HandleError(iErr);

                [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                HandleError(iErr);

            else % Odd number of nodes.  Get Results at end of element
                BeamPos = 0;
                [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                HandleError(iErr);

                 [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                HandleError(iErr);
            end

            DeadLoad.StrPos(i,DeadLoadType,ii, :) = BeamRes;
            DeadLoad.ForcePos(i,DeadLoadType,ii,:) = BeamF;
        end
    end
end

if length(Parameters.Length)~=1
    %Determine at poi's before middle span (0.6L for side spans, & at
    %supports)
    for ii=1%:floor(length(Parameters.Length)/2) (Only the first span is sampled at 0.4 L)
        y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
        y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
        y = (y2-y1)/(Parameters.NumGirder-1);  
        for i=1:Parameters.NumGirder
            NumColumns = 18;
            ResultCase = 1;
            BeamRes = zeros(NumColumns,2);
            BeamF = zeros(6,2);

            row = y1 + (i-1)*y;
            x1 = find(Node(ii).ID(:,row,3),1,'first');
            x2 = find(Node(ii).ID(:,row,3),1,'last');

            cl = x1 + round((x2-x1)*0.4);
            
            poi = Node(ii).ID(cl,row,3);
            BeamNum = Node(ii).ElementCon(poi,1);
            
            BeamPos = 0;
            [iErr, ~, BeamRes(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,1));
            HandleError(iErr);
            
            [iErr, ~, BeamF(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,1));
            HandleError(iErr);
            
            DeadLoad.StrPos(i,DeadLoadType, ii, :) = BeamRes(:,1);
            DeadLoad.ForcePos(i,DeadLoadType, ii, :) = BeamF(:,1);
            
            %Stresses at internal supports
            poi = Node(ii).ID(x2,row,3);
            BeamNum = Node(ii).ElementCon(poi,2);
            
             EltData = 0;
            [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
            HandleError(iErr);
            
            BeamPos = EltData;
            [iErr, ~, BeamRes(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,2));
            HandleError(iErr);
            
            [iErr, ~, BeamF(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,2));
            HandleError(iErr);
            
            DeadLoad.StrNeg(i, DeadLoadType, ii, :) = BeamRes(:,2);
            DeadLoad.ForceNeg(i, DeadLoadType, ii, :) = BeamF(:,2);
         end
    end
    n=0;
    for ii=length(Parameters.Length) % (only last span is sampled at 0.6 L)
        y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
        y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
        y = (y2-y1)/(Parameters.NumGirder-1);
        n=n+1;
        for i=1:Parameters.NumGirder
            NumColumns = 18;
            ResultCase = 1;
            BeamRes = zeros(NumColumns,2);
            BeamF = zeros(6,2);

            row = y1 + (i-1)*y;
            x1 = find(Node(ii).ID(:,row,3),1,'first');
            x2 = find(Node(ii).ID(:,row,3),1,'last');

            cl = x1 + round((x2-x1)*0.6);
            
            poi = Node(ii).ID(cl,row,3);
            BeamNum = Node(ii).ElementCon(poi,1);
            
            EltData = 0;
            [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
            HandleError(iErr);
                
            BeamPos = 0;
            [iErr, ~, BeamRes(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,1));
            HandleError(iErr);
            
            [iErr, ~, BeamF(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,1));
            HandleError(iErr);
            
            DeadLoad.StrPos(i,DeadLoadType, ii, :) = BeamRes(:,1);
            DeadLoad.ForcePos(i,DeadLoadType, ii, :) = BeamF(:,1);
            
            %Stresses at internal supports
            poi = Node(ii).ID(x1,row,3);
            BeamNum = Node(ii).ElementCon(poi,1);

            BeamPos = 0;
            [iErr, ~, BeamRes(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,2));
            HandleError(iErr);
            
            [iErr, ~, BeamF(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,2));
            HandleError(iErr);
            
            DeadLoad.StrNeg(i, DeadLoadType, ii-1, :) = BeamRes(:,2);
            DeadLoad.ForceNeg(i, DeadLoadType, ii-1, :) = BeamF(:,2);
         end
    end
end

% Get Vertical Reactions at the Supports
for h=1:Parameters.Spans
    for i=1:Parameters.NumGirder
        ResultCase = 1;
        NodeRes = zeros(6,2);

        row = y1 + (i-1)*y;
        x1 = find(Node(h).ID(:,row,3),1,'first');
        x2 = find(Node(h).ID(:,row,3),1,'last');
        near = Node(h).ID(x1,row,4);
        far = Node(h).ID(x2,row,4);
        
        if h==1
        [iErr, NodeRes(:,1)] = calllib('St7API', 'St7GetNodeResult', uID, kNodeReact, near, ResultCase, NodeRes(:,1));
        HandleError(iErr);
        DeadLoad.Rxn(i, DeadLoadType, (h), :) = NodeRes(:,1);
        end
        [iErr, NodeRes(:,2)] = calllib('St7API', 'St7GetNodeResult', uID, kNodeReact, far, ResultCase, NodeRes(:,2));
        HandleError(iErr);
        
        DeadLoad.Rxn(i, DeadLoadType, h+1, :) = NodeRes(:,2);
    end
end

iErr = calllib('St7API', 'St7CloseResultFile', uID);
HandleError(iErr);
    

%% Superimposed Dead Load
DeadLoadType = 2;

DeadLoadResultPath = [ModelPath ModelName '_' num2str(DeadLoadType) '.lsa'];

Spectral = 0;
NumPrimary = 0;
NumSecondary = 0;
[iErr, NumPrimary, NumSecondary] = calllib('St7API', 'St7OpenResultFile', uID, DeadLoadResultPath, '', Spectral, NumPrimary, NumSecondary);
HandleError(iErr);

if Parameters.Spans~=2
    % Determine Dead Load Stresses
    if Parameters.Spans == 1
        intspans = 1;
    else
        intspans = 2:Parameters.Spans-1;
    end
    for ii = intspans
        % Determine the beam element at midspan
        y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
        y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
        y = (y2-y1)/(Parameters.NumGirder-1); 

        for i=1:Parameters.NumGirder
            NumColumns = 18;
            ResultCase = 1;
            BeamRes = zeros(NumColumns,1);
            BeamF = zeros(6,1);

            row = y1 + (i-1)*y;
            x1 = find(Node(ii).ID(:,row,3),1,'first');
            x2 = find(Node(ii).ID(:,row,3),1,'last');

            cl = x1 + floor((x2-x1)/2);

            midspan = Node(ii).ID(cl,row,3);
            BeamNum = Node(ii).ElementCon(midspan,1);

            EltData = 0;
            [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
            HandleError(iErr);

            if rem(x2-x1,2) ~= 0 % Even number of nodes.  Get results at middle of element
                BeamPos = EltData/2;
                [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                HandleError(iErr);

                [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);

                HandleError(iErr);
            else % Odd number of nodes.  Get Results at end of element
                BeamPos = 0;
                [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                HandleError(iErr);

                [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                HandleError(iErr);
            end

            DeadLoad.StrPos(i,DeadLoadType,ii, :) = BeamRes;
            DeadLoad.ForcePos(i,DeadLoadType, ii, :) = BeamF;
        end
    end
end
if length(Parameters.Length)~=1
    %Determine at poi's before middle span (0.6L for side spans, & at
    %supports)
    for ii=1%:floor(length(Parameters.Length)/2)
        y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
        y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
        y = (y2-y1)/(Parameters.NumGirder-1);  
        for i=1:Parameters.NumGirder
            NumColumns = 18;
            ResultCase = 1;
            BeamRes = zeros(NumColumns,2);
            BeamF = zeros(6,2);

            row = y1 + (i-1)*y;
            x1 = find(Node(ii).ID(:,row,3),1,'first');
            x2 = find(Node(ii).ID(:,row,3),1,'last');

            cl = x1 + round((x2-x1)*0.4);
            
            poi = Node(ii).ID(cl,row,3);
            BeamNum = Node(ii).ElementCon(poi,1);
            
            BeamPos = 0;
            [iErr, ~, BeamRes(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,1));
            HandleError(iErr);
            
            [iErr, ~, BeamF(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,1));
            HandleError(iErr);
            
            DeadLoad.StrPos(i,DeadLoadType, ii, :) = BeamRes(:,1);
            DeadLoad.ForcePos(i,DeadLoadType, ii, :) = BeamF(:,1);
            
            %Stresses at internal supports
            poi = Node(ii).ID(x2,row,3);
            BeamNum = Node(ii).ElementCon(poi,2);
            
             EltData = 0;
            [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
            HandleError(iErr);
            
            BeamPos = EltData;
            [iErr, ~, BeamRes(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,2));
            HandleError(iErr);
            
            [iErr, ~, BeamF(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,2));
            HandleError(iErr);
            
            DeadLoad.StrNeg(i, DeadLoadType, ii, :) = BeamRes(:,2);
            DeadLoad.ForceNeg(i,DeadLoadType, ii, :) = BeamF(:,2);
         end
    end
    n=0;
    for ii=length(Parameters.Length)
        y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
        y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
        y = (y2-y1)/(Parameters.NumGirder-1);
        n=n+1;
        for i=1:Parameters.NumGirder
            NumColumns = 18;
            ResultCase = 1;
            BeamRes = zeros(NumColumns,2);
            BeamF = zeros(6,2);

            row = y1 + (i-1)*y;
            x1 = find(Node(ii).ID(:,row,3),1,'first');
            x2 = find(Node(ii).ID(:,row,3),1,'last');

            cl = x1 + round((x2-x1)*0.6);
            
            poi = Node(ii).ID(cl,row,3);
            BeamNum = Node(ii).ElementCon(poi,1);
            
            EltData = 0;
            [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
            HandleError(iErr);
                
            BeamPos = 0;
            [iErr, ~, BeamRes(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,1));
            HandleError(iErr);
            
            [iErr, ~, BeamF(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,1));
            HandleError(iErr);
            
            DeadLoad.StrPos(i,DeadLoadType, ii, :) = BeamRes(:,1);
            DeadLoad.ForcePos(i,DeadLoadType, ii, :) = BeamF(:,1);
            
            %Stresses at internal supports
            poi = Node(ii).ID(x1,row,3);
            BeamNum = Node(ii).ElementCon(poi,1);

            BeamPos = 0;
            [iErr, ~, BeamRes(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,2));
            HandleError(iErr);
            
            [iErr, ~, BeamF(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,2));
            HandleError(iErr);
            
            DeadLoad.StrNeg(i, DeadLoadType, ii-1, :) = BeamRes(:,2);
            DeadLoad.ForceNeg(i,DeadLoadType, ii-1, :) = BeamF(:,2);
         end
    end
end

% Get Vertical Reactions at the Supports
for h=1:length(Parameters.Length)
    for i=1:Parameters.NumGirder
        ResultCase = 1;
        NodeRes = zeros(6,2);

        row = y1 + (i-1)*y;
        x1 = find(Node(h).ID(:,row,3),1,'first');
        x2 = find(Node(h).ID(:,row,3),1,'last');
        near = Node(h).ID(x1,row,4);
        far = Node(h).ID(x2,row,4);
        
        if h==1
        [iErr, NodeRes(:,1)] = calllib('St7API', 'St7GetNodeResult', uID, kNodeReact, near, ResultCase, NodeRes(:,1));
        HandleError(iErr);
        DeadLoad.Rxn(DeadLoadType, (length(Parameters.Length)+1)+(h), i, :) = NodeRes(:,1);
        end
        [iErr, NodeRes(:,2)] = calllib('St7API', 'St7GetNodeResult', uID, kNodeReact, far, ResultCase, NodeRes(:,2));
        HandleError(iErr);
        
        DeadLoad.Rxn(i, DeadLoadType, h+1, :) = NodeRes(:,2);
    end
end


iErr = calllib('St7API', 'St7CloseResultFile', uID);
HandleError(iErr);

%% Non-Structural mass Load
if Parameters.Deck.WearingSurface ~=0
    DeadLoadType = 3;

    DeadLoadResultPath = [ModelPath ModelName '_' num2str(DeadLoadType) '.lsa'];

    Spectral = 0;
    NumPrimary = 0;
    NumSecondary = 0;
    [iErr, NumPrimary, NumSecondary] = calllib('St7API', 'St7OpenResultFile', uID, DeadLoadResultPath, '', Spectral, NumPrimary, NumSecondary);
    HandleError(iErr);

    if Parameters.Spans~=2
        % Determine Dead Load Stresses
        if Parameters.Spans == 1
            intspans = 1;
        else
            intspans = 2:Parameters.Spans-1;
        end
        for ii = intspans
            % Determine the beam element at midspan
            y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
            y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
            y = (y2-y1)/(Parameters.NumGirder-1); 

            for i=1:Parameters.NumGirder
                NumColumns = 18;
                ResultCase = 1;
                BeamRes = zeros(NumColumns,1);
                BeamF = zeros(6,1);

                row = y1 + (i-1)*y;
                x1 = find(Node(ii).ID(:,row,3),1,'first');
                x2 = find(Node(ii).ID(:,row,3),1,'last');

                cl = x1 + floor((x2-x1)/2);

                midspan = Node(ii).ID(cl,row,3);
                BeamNum = Node(ii).ElementCon(midspan,1);

                EltData = 0;
                [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
                HandleError(iErr);

                if rem(x2-x1,2) ~= 0 % Even number of nodes.  Get results at middle of element
                    BeamPos = EltData/2;
                    [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                    HandleError(iErr);

                    [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                    HandleError(iErr);
                else % Odd number of nodes.  Get Results at end of element
                    BeamPos = 0;
                    [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                    HandleError(iErr);

                    [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                    HandleError(iErr);
                end

                DeadLoad.StrPos(i,DeadLoadType,ii, :) = BeamRes;
                DeadLoad.ForcePos(i,DeadLoadType, ii, :) = BeamF;
            end
        end
    end
    if length(Parameters.Length)~=1
        %Determine at poi's before interior spans (0.6L for side spans, & at
        %supports)
        for ii=1%:floor(length(Parameters.Length)/2)
            y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
            y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
            y = (y2-y1)/(Parameters.NumGirder-1);  
            for i=1:Parameters.NumGirder
                NumColumns = 18;
                ResultCase = 1;
                BeamRes = zeros(NumColumns,2);
                BeamF = zeros(6,2);

                row = y1 + (i-1)*y;
                x1 = find(Node(ii).ID(:,row,3),1,'first');
                x2 = find(Node(ii).ID(:,row,3),1,'last');

                cl = x1 + round((x2-x1)*0.4);

                poi = Node(ii).ID(cl,row,3);
                BeamNum = Node(ii).ElementCon(poi,1);

                BeamPos = 0;
                [iErr, ~, BeamRes(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,1));
                HandleError(iErr);
                
                [iErr, ~, BeamF(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,1));
                HandleError(iErr);

                DeadLoad.StrPos(i,DeadLoadType, ii, :) = BeamRes(:,1);
                DeadLoad.ForcePos(i,DeadLoadType, ii, :) = BeamF(:,1);

                %Stresses at internal supports
                poi = Node(ii).ID(x2,row,3);
                BeamNum = Node(ii).ElementCon(poi,2);

                 EltData = 0;
                [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
                HandleError(iErr);

                BeamPos = EltData;
                [iErr, ~, BeamRes(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,2));
                HandleError(iErr);
                
                [iErr, ~, BeamF(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,2));
                HandleError(iErr);

                DeadLoad.StrNeg(i, DeadLoadType, ii, :) = BeamRes(:,2);
                DeadLoad.ForceNeg(i,DeadLoadType, ii, :) = BeamF(:,2);
             end
        end
        n=0;
        for ii=length(Parameters.Length)
            y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
            y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
            y = (y2-y1)/(Parameters.NumGirder-1);
            n=n+1;
            for i=1:Parameters.NumGirder
                NumColumns = 18;
                ResultCase = 1;
                BeamRes = zeros(NumColumns,2);
                BeamF = zeros(6,2);

                row = y1 + (i-1)*y;
                x1 = find(Node(ii).ID(:,row,3),1,'first');
                x2 = find(Node(ii).ID(:,row,3),1,'last');

                cl = x1 + round((x2-x1)*0.6);

                poi = Node(ii).ID(cl,row,3);
                BeamNum = Node(ii).ElementCon(poi,1);

                EltData = 0;
                [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
                HandleError(iErr);

                BeamPos = 0;
                [iErr, ~, BeamRes(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,1));
                HandleError(iErr);
                
                [iErr, ~, BeamF(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,1));
                HandleError(iErr);

                DeadLoad.StrPos(i,DeadLoadType, ii, :) = BeamRes(:,1);
                DeadLoad.ForcePos(i,DeadLoadType, ii, :) = BeamF(:,1);
                %Stresses at internal supports
                poi = Node(ii).ID(x1,row,3);
                BeamNum = Node(ii).ElementCon(poi,1);

                BeamPos = 0;
                [iErr, ~, BeamRes(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,2));
                HandleError(iErr);
                
                [iErr, ~, BeamF(:,2)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,2));
                HandleError(iErr);

                DeadLoad.StrNeg(i, DeadLoadType, ii-1, :) = BeamRes(:,2);
                DeadLoad.ForceNeg(i,DeadLoadType, ii-1, :) = BeamF(:,2);
             end
        end
    end

    % Get Vertical Reactions at the Supports
    for h=1:length(Parameters.Length)
        for i=1:Parameters.NumGirder
            ResultCase = 1;
            NodeRes = zeros(6,2);

            row = y1 + (i-1)*y;
            x1 = find(Node(h).ID(:,row,3),1,'first');
            x2 = find(Node(h).ID(:,row,3),1,'last');
            near = Node(h).ID(x1,row,4);
            far = Node(h).ID(x2,row,4);

            if h==1
            [iErr, NodeRes(:,1)] = calllib('St7API', 'St7GetNodeResult', uID, kNodeReact, near, ResultCase, NodeRes(:,1));
            HandleError(iErr);
            DeadLoad.Rxn(DeadLoadType, (length(Parameters.Length)+1)+(h), i, :) = NodeRes(:,1);
            end
            [iErr, NodeRes(:,2)] = calllib('St7API', 'St7GetNodeResult', uID, kNodeReact, far, ResultCase, NodeRes(:,2));
            HandleError(iErr);

            DeadLoad.Rxn(i, DeadLoadType, h+1, :) = NodeRes(:,2);
        end
    end
    
    iErr = calllib('St7API', 'St7CloseResultFile', uID);
    HandleError(iErr);
end


end