function [DeadLoad] = DeadLoadResults(uID, ModelPath, ModelName, Node, Parameters, Options, DLCase)
global tyBEAM rtBeamStress rtBeamForce stBeamLocal rtNodeReact stBeamGlobal

ResultCase = DLCase;

% Initialize
if Parameters.Deck.WearingSurface ~=0
    DeadLoads = 1:3;
else
    DeadLoads = 1:2;
end

% Preallocate for results storage
DeadLoad.StrPos = zeros(Parameters.NumGirder,length(DeadLoads),Parameters.Spans,18);
DeadLoad.ForcePos = zeros(Parameters.NumGirder,length(DeadLoads),Parameters.Spans,6);
DeadLoad.StrNeg = zeros(Parameters.NumGirder,length(DeadLoads),Parameters.Spans-1,18);
DeadLoad.ForceNeg = zeros(Parameters.NumGirder,length(DeadLoads),Parameters.Spans-1,6);
DeadLoad.Rxn = zeros(Parameters.NumGirder,length(DeadLoads),Parameters.Spans+1, 6);

% Apply loads
for ii = DeadLoads
    DeadLoadType = ii;
    
    % Open Appropriate Result File
    DeadLoadResultPath = [ModelPath ModelName '_' num2str(DeadLoadType) '.lsa'];
    St7OpenResultFile(uID,DeadLoadResultPath)
        
    % Pull results from interior spans (midspan poi)
    if Parameters.Spans~=2
        if Parameters.Spans == 1
            intspans = 1;
        else
            intspans = 2:Parameters.Spans-1;
        end
        for jj = intspans
            % Determine the beam element at midspan
            y1 = find(any(Node(jj).ID(:,:,3)),1,'first');
            y2 = find(any(Node(jj).ID(:,:,3)),1,'last');
            y = (y2-y1)/(Parameters.NumGirder-1); 

            for kk=1:Parameters.NumGirder
                NumColumns = 18;
                BeamRes = zeros(1,NumColumns);
                BeamF = zeros(1,6);

                row = y1 + (kk-1)*y;
                x1 = find(Node(jj).ID(:,row,3),1,'first');
                x2 = find(Node(jj).ID(:,row,3),1,'last');

                cl = x1 + floor((x2-x1)/2);

                midspan = Node(jj).ID(cl,row,3);
                BeamNum = Node(jj).ElementCon(midspan,1);
                   
                % Determine length of element
                EltData = 0;
                [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
                HandleError(iErr);

                if rem(x2-x1,2) ~= 0 % Even number of nodes.  Get results at middle of element
                    BeamPos = EltData/2;
                    [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamStress, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                    HandleError(iErr);

                    [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                    HandleError(iErr);

                else % Odd number of nodes.  Get Results at beginning of element
                    BeamPos = 0;
                    [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamStress, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                    HandleError(iErr);

                     [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                    HandleError(iErr);
                end

                DeadLoad.StrPos(kk,DeadLoadType,jj, :) = BeamRes;
                DeadLoad.ForcePos(kk,DeadLoadType,jj,:) = BeamF;
                
                if Parameters.Spans ~= 1
                    %Stresses at internal supports
                    poi = Node(jj).ID(x2,row,3);
                    BeamNum = Node(jj).ElementCon(poi,2);

                    EltData = 0;
                    [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
                    HandleError(iErr);

                    BeamPos = EltData;
                    [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamStress, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                    HandleError(iErr);

                    [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                    HandleError(iErr);

                    DeadLoad.StrNeg(kk, DeadLoadType, jj, :) = BeamRes;
                    DeadLoad.ForceNeg(kk, DeadLoadType, jj, :) = BeamF;
                end
            end
        end
    end

    % Pull results from first exterior span (0.4L poi)
    if length(Parameters.Length)~=1
        for jj=1
            y1 = find(any(Node(jj).ID(:,:,3)),1,'first');
            y2 = find(any(Node(jj).ID(:,:,3)),1,'last');
            y = (y2-y1)/(Parameters.NumGirder-1);  
            for kk=1:Parameters.NumGirder
                NumColumns = 18;
                BeamRes = zeros(1,NumColumns);
                BeamF = zeros(1,6);

                row = y1 + (kk-1)*y;
                x1 = find(Node(jj).ID(:,row,3),1,'first');
                x2 = find(Node(jj).ID(:,row,3),1,'last');

                cl = x1 + round((x2-x1)*0.4);

                poi = Node(jj).ID(cl,row,3);
                BeamNum = Node(jj).ElementCon(poi,1);

                BeamPos = 0;
                [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                HandleError(iErr);

                [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                HandleError(iErr);

                DeadLoad.StrPos(kk,DeadLoadType, jj, :) = BeamRes;
                DeadLoad.ForcePos(kk,DeadLoadType, jj, :) = BeamF;

                %Stresses at internal supports
                poi = Node(jj).ID(x2,row,3);
                BeamNum = Node(jj).ElementCon(poi,2);

                 EltData = 0;
                [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
                HandleError(iErr);

                BeamPos = EltData;
                [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                HandleError(iErr);

                [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                HandleError(iErr);

                DeadLoad.StrNeg(kk, DeadLoadType, jj, :) = BeamRes;
                DeadLoad.ForceNeg(kk, DeadLoadType, jj, :) = BeamF;
             end
        end
        
        for jj=length(Parameters.Length) % (only last span is sampled at 0.6 L)
            y1 = find(any(Node(jj).ID(:,:,3)),1,'first');
            y2 = find(any(Node(jj).ID(:,:,3)),1,'last');
            y = (y2-y1)/(Parameters.NumGirder-1);
            
            for kk=1:Parameters.NumGirder
                NumColumns = 18;
                BeamRes = zeros(1,NumColumns);
                BeamF = zeros(1,6);

                row = y1 + (kk-1)*y;
                x1 = find(Node(jj).ID(:,row,3),1,'first');
                x2 = find(Node(jj).ID(:,row,3),1,'last');

                cl = x1 + round((x2-x1)*0.6);

                poi = Node(jj).ID(cl,row,3);
                BeamNum = Node(jj).ElementCon(poi,1);

                BeamPos = 0;
                [iErr, ~, BeamRes] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes);
                HandleError(iErr);

                [iErr, ~, BeamF] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                    uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF);
                HandleError(iErr);

                DeadLoad.StrPos(kk,DeadLoadType, jj, :) = BeamRes;
                DeadLoad.ForcePos(kk,DeadLoadType, jj, :) = BeamF;                
             end
        end
    end
if Options.LoadRating.ShearRating
    % Get Vertical Reactions at the Supports
    for jj=1:Parameters.Spans
        y1 = find(any(Node(jj).ID(:,:,3)),1,'first');
        y2 = find(any(Node(jj).ID(:,:,3)),1,'last');
        y = (y2-y1)/(Parameters.NumGirder-1);
        for kk=1:Parameters.NumGirder
            NodeRes = zeros(2,6);

            row = y1 + (kk-1)*y;
            x1 = find(Node(jj).ID(:,row,3),1,'first');
            x2 = find(Node(jj).ID(:,row,3),1,'last');
            near = Node(jj).ID(x1,row,4);
            far = Node(jj).ID(x2,row,4);

            if jj==1
                [iErr, NodeRes(1,:)] = calllib('St7API', 'St7GetNodeResult', uID, rtNodeReact, near, ResultCase,NodeRes(1,:));
                HandleError(iErr);
                DeadLoad.Rxn(kk, DeadLoadType, (jj), :) = NodeRes(1,:)';
            end
            [iErr, NodeRes(2,:)] = calllib('St7API', 'St7GetNodeResult', uID, rtNodeReact, far, ResultCase,NodeRes(2,:));
            HandleError(iErr);

            DeadLoad.Rxn(kk, DeadLoadType, jj+1, :) = NodeRes(2,:)';
        end
    end
end
    St7CloseResultFile(uID);
end
end