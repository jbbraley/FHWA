function [LiveLoad] = LiveLoadResults(uID, ModelPath, ModelName, Node, Parameters)

%% Format of saved results by index
% 1: Lane group position (Far side, near side, centered)
% 2: Individual Lane
% 3: Girder
% 4: Load Case (Truck position, lane loads)
%   Truck positioning is ordered as follows
%       Center of each span (seperately)
%       32' axle spacing over piers
%       14' axle spacing over piers
%       Double trucks over piers
%       Trucks at each abutment
% 5: Span/Location
% 6: Resultants (Global):
%       FX MX FY MY FZ MZ


global tyBEAM rtBeamStress rtBeamForce stBeamLocal kNodeReact stBeamGlobal
% Get Number of load Cases
NumLoadCase = 0;
[iErr, NumLoadCase] = calllib('St7API', 'St7GetNumLoadCase', uID, NumLoadCase);
HandleError(iErr);
LiveLoadResultPath = [ModelPath ModelName '_LL.lsa'];

Spectral = 0;
NumPrimary = 0;
NumSecondary = 0;
[iErr, NumPrimary, NumSecondary] = calllib('St7API', 'St7OpenResultFile', uID, LiveLoadResultPath, '', Spectral, NumPrimary, NumSecondary);
HandleError(iErr);

if strcmp(Parameters.Rating.Code, 'LRFD')
    LaneLoad = 1;
else
    LaneLoad = 0;
end
% Divide by 3 for three lane positions
Trucks = (NumLoadCase-1)/3/Parameters.Rating.NumLane-LaneLoad*Parameters.Spans;

%% Determine Live Load Stresses
% Determine the beam element at midspan
if Parameters.Spans~=2
    if Parameters.Spans == 1
        intspans = 1;
    else
        intspans = 2:Parameters.Spans-1;
    end
    for ii = intspans
        y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
        y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
        y = (y2-y1)/(Parameters.NumGirder-1); 

        %     LiveLoadStr = zeros(2, Parameters.NumGirder, Parameters.NumLane, 18);
        for jj = 1:3
            for k=1:Parameters.Rating.NumLane
                for h=1:Trucks+LaneLoad*Parameters.Spans 
                    if h<=Trucks
                        ResultCase = Parameters.Rating.NumLane*(Trucks)*(jj-1)+(k-1)*Trucks+h+1;
                    else
                        ResultCase = Parameters.Rating.NumLane*(LaneLoad*Parameters.Spans)*(jj-1)+3*Parameters.Rating.NumLane*Trucks+1+(h-Trucks-1)*Parameters.Rating.NumLane+k;
                    end

                    for i=1:Parameters.NumGirder
                        NumColumns = 18;
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

                        LiveLoad.StrPos(jj,k, i, h, ii, :) = BeamRes;
                        LiveLoad.ForcePos(jj,k, i, h, ii, :) = BeamF;
                    end
                end
            end
        end
    end
end

if length(Parameters.Length)~=1
    %Determine at poi's before interior spans (0.6L for side spans, & at
    %supports)
  for jj = 1:3  
    for k=1:Parameters.Rating.NumLane
        for h=1:Trucks+LaneLoad*Parameters.Spans 
            if h<=Trucks
                ResultCase = Parameters.Rating.NumLane*(Trucks)*(jj-1)+(k-1)*Trucks+h+1;
            else
                ResultCase = Parameters.Rating.NumLane*(LaneLoad*Parameters.Spans)*(jj-1)+3*Parameters.Rating.NumLane*Trucks+1+(h-Trucks-1)*Parameters.Rating.NumLane+k;
            end
        
            for ii=1
                y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
                y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
                y = (y2-y1)/(Parameters.NumGirder-1);  
                for i=1:Parameters.NumGirder
                    NumColumns = 18;
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

                    LiveLoad.StrPos(jj,k, i, h, ii, :) = BeamRes(:,1);
                    LiveLoad.ForcePos(jj,k, i, h, ii, :) = BeamF(:,1);

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

                    LiveLoad.StrNeg(jj,k, i, h, ii, :) = BeamRes(:,2);
                    LiveLoad.ForceNeg(jj,k, i, h, ii, :) = BeamF(:,2);
                end
            end
            for ii=length(Parameters.Length)
                y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
                y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
                y = (y2-y1)/(Parameters.NumGirder-1);  
                for i=1:Parameters.NumGirder
                    NumColumns = 18;
                    BeamRes = zeros(NumColumns,2);
                    BeamF = zeros(6,2);

                    row = y1 + (i-1)*y;
                    x1 = find(Node(ii).ID(:,row,3),1,'first');
                    x2 = find(Node(ii).ID(:,row,3),1,'last');

                    cl = x1 + round((x2-x1)*0.6);

                    poi = Node(ii).ID(cl,row,3);
                    BeamNum = Node(ii).ElementCon(poi,1);

                    BeamPos = 0;
                    [iErr, ~, BeamRes(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(:,1));
                    HandleError(iErr);
                    
                    [iErr, ~, BeamF(:,1)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(:,1));
                    HandleError(iErr);

                    LiveLoad.StrPos(jj,k, i, h, ii, :) = BeamRes(:,1);
                    LiveLoad.ForcePos(jj,k, i, h, ii, :) = BeamF(:,1);

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

                    LiveLoad.StrNeg(jj,k, i, h, ii-1, :) = BeamRes(:,2);
                    LiveLoad.ForceNeg(jj,k, i, h, ii-1, :) = BeamF(:,2);
                end
            end
        end
    end
  end
end

                

% Get Vertical Reactions at the Supports
% LiveLoad.Rxn = zeros(4, Parameters.NumGirder, Parameters.NumLane, 6);

for jj=1:3
for k=1:Parameters.Rating.NumLane
    for h=1:Trucks+LaneLoad*Parameters.Spans 
        if h<=Trucks
            ResultCase = Parameters.Rating.NumLane*(Trucks+LaneLoad*Parameters.Spans)*(jj-1)+(k-1)*Trucks+h+1;
        else
            ResultCase = Parameters.Rating.NumLane*(Trucks+LaneLoad*Parameters.Spans)*(jj-1)+Parameters.Rating.NumLane*Trucks+1+(h-Trucks-1)*Parameters.Rating.NumLane+k;
        end
        for ii = 1:Parameters.Spans
            y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
            y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
            y = (y2-y1)/(Parameters.NumGirder-1); 

            for i=1:Parameters.NumGirder

                NodeRes = zeros(6,2);

                row = y1 + (i-1)*y;
                x1 = find(Node(ii).ID(:,row,3),1,'first');
                x2 = find(Node(ii).ID(:,row,3),1,'last');
                near = Node(ii).ID(x1,row,4);
                far = Node(ii).ID(x2,row,4);

                [iErr, NodeRes(:,1)] = calllib('St7API', 'St7GetNodeResult', uID, kNodeReact, near, ResultCase, NodeRes(:,1));
                HandleError(iErr);

                LiveLoad.Rxn(jj,k, i, h, ii, :) = NodeRes(:,1);

                if ii == Parameters.Spans
                [iErr, NodeRes(:,2)] = calllib('St7API', 'St7GetNodeResult', uID, kNodeReact, far, ResultCase, NodeRes(:,2));
                HandleError(iErr);

                LiveLoad.Rxn(jj,k, i, h, ii+1, :) = NodeRes(:,2);
                end
            end
        end
    end
end
end


iErr = calllib('St7API', 'St7CloseResultFile', uID);
HandleError(iErr);

end % LiveLoadResults()


