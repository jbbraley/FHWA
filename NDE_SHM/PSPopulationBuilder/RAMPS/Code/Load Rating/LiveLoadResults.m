function [LiveLoad] = LiveLoadResults(uID, ModelPath, ModelName, Node, Parameters, Options, ArgIn, LLCaseStart)

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

% Options
NumLaneOffsets = Options.LoadPath.Divisions;
Code = Parameters.Rating.Code;
if Parameters.Rating.(Code).Tandem ~= 0
    Tandem = 1;
end

% Get Number of load Cases
NumLoadCase = 0;
[iErr, NumLoadCase] = calllib('St7API', 'St7GetNumLoadCase', uID, NumLoadCase);
HandleError(iErr);
LiveLoadResultPath = [ModelPath ModelName '_LL.lsa'];

Spectral = 0;
NumPrimary = 0;
NumSecondary = 0;
[iErr, ~, ~] = calllib('St7API', 'St7OpenResultFile', uID, LiveLoadResultPath, '', Spectral, NumPrimary, NumSecondary);
HandleError(iErr);

if strcmp(Parameters.Rating.Code, 'LRFD')
    LaneLoad = 1;
else
    LaneLoad = 0;
end
% Divide by NumLaneOffsets for three lane positions
Trucks = (NumLoadCase-LLCaseStart+1)/NumLaneOffsets/ArgIn.NumLane-LaneLoad*Parameters.Spans; % Truck loads per lane per lane position

%% Determine Live Load Stresses
% Determine the beam element at midspan
if Parameters.Spans~=2
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
        for jj = 1:NumLaneOffsets % Lane positions
            for kk = 1:ArgIn.NumLane % Lanes
                for h = 1:Trucks + LaneLoad*Parameters.Spans 
                    if h <= Trucks
                        ResultCase = ArgIn.NumLane*(Trucks)*(jj-1)+(kk-1)*Trucks+h;
                    else
                        ResultCase = ArgIn.NumLane*(LaneLoad*Parameters.Spans)*(jj-1) + ... % Lane load number
                            NumLaneOffsets*ArgIn.NumLane*Trucks + ... % Number of truck positions
                            (h-Trucks-1)*ArgIn.NumLane + kk;
                        
                    end

                    for pp=1:Parameters.NumGirder
                        NumColumns = 18;
                        BeamRes = zeros(1,NumColumns);
                        BeamF = zeros(1,6);

                        row = y1 + (pp-1)*y;
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

                        LiveLoad.StrPos(jj, kk, pp, h, ii, :) = BeamRes;
                        LiveLoad.ForcePos(jj, kk, pp, h, ii, :) = BeamF;
                        
                        if Parameters.Spans ~= 1
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

                            LiveLoad.StrNeg(jj,kk, pp, h, ii, :) = BeamRes(:,2);
                            LiveLoad.ForceNeg(jj,kk, pp, h, ii, :) = BeamF(:,2);
                        end
                    end
                end
            end
        end
    end
end

if Parameters.Spans~=1
    %Determine at poi's for exterior spans (0.6/0.4L for side spans, & at
    %supports)
  for jj = 1:NumLaneOffsets  
    for kk=1:ArgIn.NumLane
        for h=1:Trucks+LaneLoad*Parameters.Spans 
            if h<=Trucks
                ResultCase = ArgIn.NumLane*(Trucks)*(jj-1)+(kk-1)*Trucks+h;
            else
                ResultCase = ArgIn.NumLane*(LaneLoad*Parameters.Spans)*(jj-1) + ... % Lane load number
                            NumLaneOffsets*ArgIn.NumLane*Trucks + ... % Number of truck positions
                            (h-Trucks-1)*ArgIn.NumLane + kk;
            end
        
            for ii=1
                y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
                y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
                y = (y2-y1)/(Parameters.NumGirder-1);  
                for pp=1:Parameters.NumGirder
                    NumColumns = 18;
                    BeamRes = zeros(2,NumColumns);
                    BeamF = zeros(2,6);

                    row = y1 + (pp-1)*y;
                    x1 = find(Node(ii).ID(:,row,3),1,'first');
                    x2 = find(Node(ii).ID(:,row,3),1,'last');

                    cl = x1 + round((x2-x1)*0.4);

                    poi = Node(ii).ID(cl,row,3);
                    BeamNum = Node(ii).ElementCon(poi,1);

                    BeamPos = 0;
                    [iErr, ~, BeamRes(1,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(1,:));
                    HandleError(iErr);
                    
                    [iErr, ~, BeamF(1,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(1,:));
                    HandleError(iErr);

                    LiveLoad.StrPos(jj,kk, pp, h, ii, :) = BeamRes(1,:)';
                    LiveLoad.ForcePos(jj,kk, pp, h, ii, :) = BeamF(1,:)';

                    %Stresses at internal supports
                    poi = Node(ii).ID(x2,row,3);
                    BeamNum = Node(ii).ElementCon(poi,2);

                    EltData = 0;
                    [iErr, EltData] = calllib('St7API', 'St7GetElementData', uID, tyBEAM, BeamNum, EltData);
                    HandleError(iErr);

                    BeamPos = EltData;
                    [iErr, ~, BeamRes(2,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(2,:));
                    HandleError(iErr);
                    
                    [iErr, ~, BeamF(2,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(2,:));
                    HandleError(iErr);

                    LiveLoad.StrNeg(jj,kk, pp, h, ii, :) = BeamRes(2,:)';
                    LiveLoad.ForceNeg(jj,kk, pp, h, ii, :) = BeamF(2,:)';
                end
            end
            for ii=length(Parameters.Length) % (only last span is sampled at 0.6 L)
                y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
                y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
                y = (y2-y1)/(Parameters.NumGirder-1);  
                for pp=1:Parameters.NumGirder
                    NumColumns = 18;
                    BeamRes = zeros(2,NumColumns);
                    BeamF = zeros(2,6);

                    row = y1 + (pp-1)*y;
                    x1 = find(Node(ii).ID(:,row,3),1,'first');
                    x2 = find(Node(ii).ID(:,row,3),1,'last');

                    cl = x1 + round((x2-x1)*0.6);

                    poi = Node(ii).ID(cl,row,3);
                    BeamNum = Node(ii).ElementCon(poi,1);

                    BeamPos = 0;
                    [iErr, ~, BeamRes(1,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamStress, stBeamLocal, BeamNum, ResultCase, BeamPos, NumColumns, BeamRes(1,:));
                    HandleError(iErr);
                    
                    [iErr, ~, BeamF(1,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                        uID, rtBeamForce, stBeamGlobal, BeamNum, ResultCase, BeamPos, NumColumns, BeamF(1,:));
                    HandleError(iErr);

                    LiveLoad.StrPos(jj,kk, pp, h, ii, :) = BeamRes(1,:)';
                    LiveLoad.ForcePos(jj,kk, pp, h, ii, :) = BeamF(1,:)';
                end
            end
        end
    end
  end
end

                

% Get Vertical Reactions at the Supports
% LiveLoad.Rxn = zeros(4, Parameters.NumGirder, Parameters.NumLane, 6);
if Options.LoadRating.ShearRating
    for jj=1:NumLaneOffsets
        for kk=1:ArgIn.NumLane
            for h=1:Trucks+LaneLoad*Parameters.Spans
                if h<=Trucks
                    ResultCase = ArgIn.NumLane*(Trucks)*(jj-1)+(kk-1)*Trucks+h;
                else
                    ResultCase = ArgIn.NumLane*(LaneLoad*Parameters.Spans)*(jj-1) + ... % Lane load number
                        NumLaneOffsets*ArgIn.NumLane*Trucks + ... % Number of truck positions
                        (h-Trucks-1)*ArgIn.NumLane + kk;
                end
                for ii = 1:Parameters.Spans
                    y1 = find(any(Node(ii).ID(:,:,3)),1,'first');
                    y2 = find(any(Node(ii).ID(:,:,3)),1,'last');
                    y = (y2-y1)/(Parameters.NumGirder-1);
                    
                    for pp=1:Parameters.NumGirder
                        
                        NodeRes = zeros(2,6);
                        
                        row = y1 + (pp-1)*y;
                        x1 = find(Node(ii).ID(:,row,3),1,'first');
                        x2 = find(Node(ii).ID(:,row,3),1,'last');
                        near = Node(ii).ID(x1,row,4);
                        far = Node(ii).ID(x2,row,4);
                        
                        if ii == 1
                            [iErr, NodeRes(1,:)] = calllib('St7API', 'St7GetNodeResult', uID, kNodeReact, near, ResultCase, NodeRes(1,:));
                            HandleError(iErr);
                            
                            LiveLoad.Rxn(jj,kk, pp, h, ii, :) = NodeRes(1,:)';
                        end
                        
                        [iErr, NodeRes(2,:)] = calllib('St7API', 'St7GetNodeResult', uID, kNodeReact, far, ResultCase, NodeRes(2,:));
                        HandleError(iErr);
                        
                        LiveLoad.Rxn(jj,kk, pp, h, ii+1, :) = NodeRes(2,:)';
                        
                    end
                end
            end
        end
    end
end
St7CloseResultFile(uID);

end % LiveLoadResults()


