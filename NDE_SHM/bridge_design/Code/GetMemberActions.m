% (10/20/2014) NPR: Updated to reflect manual or RAMPS design

function Parameters = GetMemberActions(Parameters)
%*************
% Gets Member Actions and Live Load Deflection Requirement
%*************

% Initial Parameters
%*************************************************************************

% Get Truck Loads
Parameters.Design = GetTruckLoads(Parameters.Design);

% Apply Impact Factor
Parameters.Design.Load.A = Parameters.Design.Load.A*1.33;
Parameters.Design.Load.TD = Parameters.Design.Load.TD*1.33;

% Lengths
SpanLength = round(Parameters.Length/12)'; %in ft
TotalLength = sum(SpanLength);
E = Parameters.Beam.E; %in psi

%  Construct stiffness matrix
%*************************************************************************
numEle = TotalLength; %number of beam elements discretized 
% at 1 foot
numNode = numEle + 1; %number of joints
numDOF = numNode*2; %number of degrees of freedom (1 deflection and
% 1 slope per node)

% assemble in global stiffness matrix - assume unit/dimensionless I - in lb/in^5
L = 12; % twelve inch lengths 
globalK = zeros(numDOF);
  
% stiffness of local element
eleK=E/L^3*[
    12, 6*L, -12, 6*L;
    6*L, 4*L^2, -6*L, 2*L^2;
    -12, -6*L, 12, -6*L;
    6*L, 2*L^2, -6*L, 4*L^2;
    ];

for i=1:numEle %for each beam element..
    Loc=2*i-1; %location of element in global matrix
    globalK(Loc:Loc+3,Loc:Loc+3) = globalK(Loc:Loc+3,Loc:Loc+3) + eleK;
end

% Set Fixed DOFS to 0 in stiffness matrix
Fixed = zeros(Parameters.Spans, 1);
for i = 1:Parameters.Spans
    Fixed(i) = sum(SpanLength(1:i));
end
Fixed = [1; 2*Fixed + 1];

condInd = 1:numDOF;
condInd = removerows(condInd', Fixed);
condK = removerows(globalK, Fixed);
condK = removerows(condK', Fixed)';

% Determine minimum stiffness for delta and span length
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Displacement for 3 Type of Loading/3 types of responses
%**************************************************************************

%% NEED TO ADD 90% TRUCK & LANE LOADING FOR NEGATIVE MOMENT LRFD
%% IS TRUCKFORWARD/BACKWARD/DUAL USED IN ASD???

if strcmp(Parameters.Design.Code, 'ASD')
    loadType = {'Truck_Forward'; 'Truck_Backward'; 'Truck_Forward_Dual'; 'Truck_Backward_Dual'; 'Tandem'; 'Point'; 'Lane_PatternEven'; 'Lane_PatternOdd'; 'Lane_All'};
else % Code is LRFD
    loadType = {'Truck_Forward'; 'Truck_Backward'; 'Truck_Forward_Dual'; 'Truck_Backward_Dual'; 'Tandem'; 'Lane_PatternEven'; 'Lane_PatternOdd'; 'Lane_All'};
end

for i = 1:length(loadType)
    if i == 5 && Parameters.Design.Tandem == 0
        continue
    end
    
    if (i == 7 || i == 8 || i == 9) && Parameters.Design.LaneLoad == 0
        continue
    end
    
    [Delta_Min(i,:), Delta_Max(i,:), D{i}] = GetDisplacementVector(loadType{i}, numDOF, condK, condInd, Fixed, Parameters);    
end

if strcmp(Parameters.Design.Code, 'ASD') 
    % Superimpose lane and point loading.............. all in in^5
    Delta_Min(10,:) = Delta_Min(6,:) + Delta_Min(7,:); % Point & Lane_PatternEven
    Delta_Min(11,:) = Delta_Min(6,:) + Delta_Min(8,:); % Point & Lane_PatternOdd
    Delta_Min(12,:) = Delta_Min(6,:) + Delta_Min(9,:); % Point & Lane_All
    Delta_Max(10,:) = Delta_Max(6,:) + Delta_Max(7,:); % Point & Lane_PatternEven
    Delta_Max(11,:) = Delta_Max(6,:) + Delta_Max(8,:); % Point & Lane_PatternOdd
    Delta_Max(12,:) = Delta_Max(6,:) + Delta_Max(9,:); % Point & Lane_All
else % Code is LRFD
    % Superimpose lane and truck loading AASHTO 2012 [3.6.1.3]
    %all [in^5]
    Delta_Min(9,:) = Delta_Min(1,:) + Delta_Min(6,:);  % Truck_Forward & Lane_PatternEven
    Delta_Min(10,:) = Delta_Min(1,:) + Delta_Min(7,:); % Truck_Forward & Lane_PatternOdd
    Delta_Min(11,:) = Delta_Min(1,:) + Delta_Min(8,:); % Truck_Forward & Lane_All
    Delta_Min(12,:) = Delta_Min(2,:) + Delta_Min(6,:); % Truck_Backward & Lane_PatternEven
    Delta_Min(13,:) = Delta_Min(2,:) + Delta_Min(7,:); % Truck_Backward & Lane_PatternOdd
    Delta_Min(14,:) = Delta_Min(2,:) + Delta_Min(8,:); % Truck_Backward & Lane_All
    Delta_Min(15,:) = Delta_Min(3,:) + Delta_Min(6,:); % Truck_Forward_Dual & Lane_PatternEven
    Delta_Min(16,:) = Delta_Min(3,:) + Delta_Min(7,:); % Truck_Forward_Dual & Lane_PatternOdd
    Delta_Min(17,:) = Delta_Min(3,:) + Delta_Min(8,:); % Truck_Forward_Dual & Lane_All
    Delta_Min(18,:) = Delta_Min(4,:) + Delta_Min(6,:); % Truck_Backward_Dual & Lane_PatternEven
    Delta_Min(19,:) = Delta_Min(4,:) + Delta_Min(7,:); % Truck_Backward_Dual & Lane_PatternOdd
    Delta_Min(20,:) = Delta_Min(4,:) + Delta_Min(8,:); % Truck_Backward_Dual & Lane_All
    Delta_Min(21,:) = Delta_Min(5,:) + Delta_Min(6,:); % Tandem & Lane_PatternEven 
    Delta_Min(22,:) = Delta_Min(5,:) + Delta_Min(7,:); % Tandem & Lane_PatternOdd
    Delta_Min(23,:) = Delta_Min(5,:) + Delta_Min(8,:); % Tandem & Lane_All
    %all [in^5]
    Delta_Max(9,:) = Delta_Max(1,:) + Delta_Max(6,:);  % Truck_Forward & Lane_PatternEven
    Delta_Max(10,:) = Delta_Max(1,:) + Delta_Max(7,:); % Truck_Forward & Lane_PatternOdd
    Delta_Max(11,:) = Delta_Max(1,:) + Delta_Max(8,:); % Truck_Forward & Lane_All
    Delta_Max(12,:) = Delta_Max(2,:) + Delta_Max(6,:); % Truck_Backward & Lane_PatternEven
    Delta_Max(13,:) = Delta_Max(2,:) + Delta_Max(7,:); % Truck_Backward & Lane_PatternOdd
    Delta_Max(14,:) = Delta_Max(2,:) + Delta_Max(8,:); % Truck_Backward & Lane_All
    Delta_Max(15,:) = Delta_Max(3,:) + Delta_Max(6,:); % Truck_Forward_Dual & Lane_PatternEven
    Delta_Max(16,:) = Delta_Max(3,:) + Delta_Max(7,:); % Truck_Forward_Dual & Lane_PatternOdd    
    Delta_Max(17,:) = Delta_Max(3,:) + Delta_Max(8,:); % Truck_Forward_Dual & Lane_All
    Delta_Max(18,:) = Delta_Max(4,:) + Delta_Max(6,:); % Truck_Backward_Dual & Lane_PatternEven
    Delta_Max(19,:) = Delta_Max(4,:) + Delta_Max(7,:); % Truck_Backward_Dual & Lane_PatternOdd    
    Delta_Max(20,:) = Delta_Max(4,:) + Delta_Max(8,:); % Truck_Backward_Dual & Lane_All
    Delta_Max(21,:) = Delta_Max(5,:) + Delta_Max(6,:); % Tandem & Lane_PatternEven
    Delta_Max(22,:) = Delta_Max(5,:) + Delta_Max(7,:); % Tandem & Lane_PatternOdd
    Delta_Max(23,:) = Delta_Max(5,:) + Delta_Max(8,:); % Tandem & Lane_All
end

% Determine Member Actions Due to Live Load Bending and Shear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Member actions are in terms of lb*in^4 and lb*in^5 for shear and moment
% Divide by each new moment of inertia when updating the beam

% Get Moment Vectors for Each Displacement Vector
%**************************************************************************
for i = 1:length(loadType)
    if i == 5 && Parameters.Design.Tandem == 0
        continue
    end
    
    if (i == 7 || i == 8 || i == 9) && Parameters.Design.LaneLoad == 0
        continue
    end
    
    [M_Max(i,:), M_Min(i,:), V_Max(i,:), V_Min(i,:), ~, ~] = GetMemberForceVector(D{i}, loadType{i}, Parameters, numEle);
end

if strcmp(Parameters.Design.Code, 'ASD')
    % Superimpose Moment for lane and point loading
    % all [lb.in]    
    M_Min(10,:) = M_Min(6,:) + M_Min(7,:); % Point & Lane_PatternEven    
    M_Min(11,:) = M_Min(6,:) + M_Min(8,:); % Point & Lane_PatternOdd    
    M_Min(12,:) = M_Min(6,:) + M_Min(9,:); % Point & Lane_All
    % all [lb.in]  
    M_Max(10,:) = M_Max(6,:) + M_Max(7,:); % Point & Lane_PatternEven
    M_Max(11,:) = M_Max(6,:) + M_Max(8,:); % Point & Lane_PatternOdd
    M_Max(12,:) = M_Max(6,:) + M_Max(9,:); % Point & Lane_All
    
    % Superimpose Moment for lane and point loading
    % all [lb]
    V_Min(10,:) = V_Min(6,:) + V_Min(7,:); % Point & Lane_PatternEven 
    V_Min(11,:) = V_Min(6,:) + V_Min(8,:); % Point & Lane_PatternOdd   
    V_Min(12,:) = V_Min(6,:) + V_Min(9,:); % Point & Lane_All
    % all [lb]
    V_Max(10,:) = V_Max(6,:) + V_Max(7,:); % Point & Lane_PatternEven
    V_Max(11,:) = V_Max(6,:) + V_Max(8,:); % Point & Lane_PatternOdd
    V_Max(12,:) = V_Max(6,:) + V_Max(9,:); % Point & Lane_All
    
else % Code is LRFD
    % Superimpose Moment for lane and point loading
    % all [lb.in]    
    M_Min(9,:) = M_Min(1,:) + M_Min(6,:);  % Truck_Forward & Lane_PatternEven    
    M_Min(10,:) = M_Min(1,:) + M_Min(7,:); % Truck_Forward & Lane_PatternOdd    
    M_Min(11,:) = M_Min(1,:) + M_Min(8,:); % Truck_Forward & Lane_All
    M_Min(12,:) = M_Min(2,:) + M_Min(6,:); % Truck_Backward & Lane_PatternEven    
    M_Min(13,:) = M_Min(2,:) + M_Min(7,:); % Truck_Backward & Lane_PatternOdd    
    M_Min(14,:) = M_Min(2,:) + M_Min(8,:); % Truck_Backward & Lane_All
    M_Min(15,:) = M_Min(3,:) + M_Min(6,:); % Truck_Forward_Dual & Lane_PatternEven
    M_Min(16,:) = M_Min(3,:) + M_Min(7,:); % Truck_Forward_Dual & Lane_PatternOdd
    M_Min(17,:) = M_Min(3,:) + M_Min(8,:); % Truck_Forward_Dual & Lane_All
    M_Min(18,:) = M_Min(4,:) + M_Min(6,:); % Truck_Backward_Dual & Lane_PatternEven
    M_Min(19,:) = M_Min(4,:) + M_Min(7,:); % Truck_Backward_Dual & Lane_PatternOdd
    M_Min(20,:) = M_Min(4,:) + M_Min(8,:); % Truck_Backward_Dual & Lane_All    
    M_Min(21,:) = M_Min(5,:) + M_Min(6,:); % Tandem & Lane_PatternEven
    M_Min(22,:) = M_Min(5,:) + M_Min(7,:); % Tandem & Lane_PatternOdd    
    M_Min(23,:) = M_Min(5,:) + M_Min(8,:); % Tandem & Lane_All    
    % all [lb.in]    
    M_Max(9,:) = M_Max(1,:) + M_Max(6,:);  % Truck_Forward & Lane_PatternEven    
    M_Max(10,:) = M_Max(1,:) + M_Max(7,:); % Truck_Forward & Lane_PatternOdd    
    M_Max(11,:) = M_Max(1,:) + M_Max(8,:); % Truck_Forward & Lane_All
    M_Max(12,:) = M_Max(2,:) + M_Max(6,:); % Truck_Backward & Lane_PatternEven    
    M_Max(13,:) = M_Max(2,:) + M_Max(7,:); % Truck_Backward & Lane_PatternOdd    
    M_Max(14,:) = M_Max(2,:) + M_Max(8,:); % Truck_Backward & Lane_All
    M_Max(15,:) = M_Max(3,:) + M_Max(6,:); % Truck_Forward_Dual & Lane_PatternEven
    M_Max(16,:) = M_Max(3,:) + M_Max(7,:); % Truck_Forward_Dual & Lane_PatternOdd
    M_Max(17,:) = M_Max(3,:) + M_Max(8,:); % Truck_Forward_Dual & Lane_All
    M_Max(18,:) = M_Max(4,:) + M_Max(6,:); % Truck_Backward_Dual & Lane_PatternEven
    M_Max(19,:) = M_Max(4,:) + M_Max(7,:); % Truck_Backward_Dual & Lane_PatternOdd
    M_Max(20,:) = M_Max(4,:) + M_Max(8,:); % Truck_Backward_Dual & Lane_All    
    M_Max(21,:) = M_Max(5,:) + M_Max(6,:); % Tandem & Lane_PatternEven
    M_Max(22,:) = M_Max(5,:) + M_Max(7,:); % Tandem & Lane_PatternOdd    
    M_Max(23,:) = M_Max(5,:) + M_Max(8,:); % Tandem & Lane_All    
    
    % Superimpose Shear for lane and point loading
    % all [lb]
    V_Min(9,:) = V_Min(1,:) + V_Min(6,:);  % Truck_Forward & Lane_PatternEven    
    V_Min(10,:) = V_Min(1,:) + V_Min(7,:); % Truck_Forward & Lane_PatternOdd    
    V_Min(11,:) = V_Min(1,:) + V_Min(8,:); % Truck_Forward & Lane_All
    V_Min(12,:) = V_Min(2,:) + V_Min(6,:); % Truck_Backward & Lane_PatternEven    
    V_Min(13,:) = V_Min(2,:) + V_Min(7,:); % Truck_Backward & Lane_PatternOdd    
    V_Min(14,:) = V_Min(2,:) + V_Min(8,:); % Truck_Backward & Lane_All
    V_Min(15,:) = V_Min(3,:) + V_Min(6,:); % Truck_Forward_Dual & Lane_PatternEven
    V_Min(16,:) = V_Min(3,:) + V_Min(7,:); % Truck_Forward_Dual & Lane_PatternOdd
    V_Min(17,:) = V_Min(3,:) + V_Min(8,:); % Truck_Forward_Dual & Lane_All
    V_Min(18,:) = V_Min(4,:) + V_Min(6,:); % Truck_Backward_Dual & Lane_PatternEven
    V_Min(19,:) = V_Min(4,:) + V_Min(7,:); % Truck_Backward_Dual & Lane_PatternOdd
    V_Min(20,:) = V_Min(4,:) + V_Min(8,:); % Truck_Backward_Dual & Lane_All    
    V_Min(21,:) = V_Min(5,:) + V_Min(6,:); % Tandem & Lane_PatternEven
    V_Min(22,:) = V_Min(5,:) + V_Min(7,:); % Tandem & Lane_PatternOdd    
    V_Min(23,:) = V_Min(5,:) + V_Min(8,:); % Tandem & Lane_All    
    % all [lb]
    V_Max(9,:) = V_Max(1,:) + V_Max(6,:);  % Truck_Forward & Lane_PatternEven    
    V_Max(10,:) = V_Max(1,:) + V_Max(7,:); % Truck_Forward & Lane_PatternOdd    
    V_Max(11,:) = V_Max(1,:) + V_Max(8,:); % Truck_Forward & Lane_All
    V_Max(12,:) = V_Max(2,:) + V_Max(6,:); % Truck_Backward & Lane_PatternEven    
    V_Max(13,:) = V_Max(2,:) + V_Max(7,:); % Truck_Backward & Lane_PatternOdd    
    V_Max(14,:) = V_Max(2,:) + V_Max(8,:); % Truck_Backward & Lane_All
    V_Max(15,:) = V_Max(3,:) + V_Max(6,:); % Truck_Forward_Dual & Lane_PatternEven
    V_Max(16,:) = V_Max(3,:) + V_Max(7,:); % Truck_Forward_Dual & Lane_PatternOdd
    V_Max(17,:) = V_Max(3,:) + V_Max(8,:); % Truck_Forward_Dual & Lane_All
    V_Max(18,:) = V_Max(4,:) + V_Max(6,:); % Truck_Backward_Dual & Lane_PatternEven
    V_Max(19,:) = V_Max(4,:) + V_Max(7,:); % Truck_Backward_Dual & Lane_PatternOdd
    V_Max(20,:) = V_Max(4,:) + V_Max(8,:); % Truck_Backward_Dual & Lane_All    
    V_Max(21,:) = V_Max(5,:) + V_Max(6,:); % Tandem & Lane_PatternEven
    V_Max(22,:) = V_Max(5,:) + V_Max(7,:); % Tandem & Lane_PatternOdd    
    V_Max(23,:) = V_Max(5,:) + V_Max(8,:); % Tandem & Lane_All    
end
    

Parameters.Design.Load.M_Max = M_Max;
Parameters.Design.Load.M_Min = M_Min;
Parameters.Design.Load.V_Max = V_Max;
Parameters.Design.Load.V_Min = V_Min;

% Find max\min for each span
for i=1:length(Fixed)-1
    range = (Fixed(i)+1)/2:(Fixed(i+1)+1)/2;
    Parameters.Design.Load.maxM(i) = max(max(M_Max(:,range))); % in lb.in
    Parameters.Design.Load.minM(i) = min(min(M_Min(:,range))); 
    
    Parameters.Design.Load.maxV(i) = max(max(V_Max(:,range))); % in lb
    Parameters.Design.Load.minV(i) = min(min(V_Min(:,range)));
end

% Find max/min for points of interest
%**************************************************************************
% Simple spans: Moment at midspan and shear at supports
% Continuous spans: Positive moment at midspan for interior spans and 0.4L
% at exterior spans. Negative moment and shear over supports
maxSpan = zeros(Parameters.Spans, 2);
for i=1:Parameters.Spans
    range = (Fixed(i)+1)/2:(Fixed(i+1)+1)/2;
    % POI
    if Parameters.Spans == 1
        POI = round(0.5*(range(end)-range(1)))+range(1);
    elseif i == 1 
        POI = round(0.4*(range(end)-range(1)))+range(1);
    elseif i == Parameters.Spans 
        POI = round(0.6*(range(end)-range(1)))+range(1);
    else
        POI = round(0.5*(range(end)-range(1)))+range(1);
    end
    
    % Displacement
    maxSpan(i,1) = max(max(Delta_Max(:,Fixed(i):2:Fixed(i+1)),[],1));
    maxSpan(i,2) = max(-1*min(Delta_Min(:,Fixed(i):2:Fixed(i+1)),[],1));
    
    % Actions
    % Positive moment
    Parameters.Design.Load.maxM_POI(i,:) = max(M_Max(:,POI)); % in lb.in
    
    % Negative Moments
    Parameters.Design.Load.minM_POI(i,:) = min(M_Min(:,[(Fixed(i)+1)/2, (Fixed(i+1)+1)/2]));
    
    % Shear
    Parameters.Design.Load.maxV_POI(i,:) = max(abs(V_Max(:,[(Fixed(i)+1)/2, (Fixed(i+1)+1)/2]))); % in lb
end

% find max deflection per span length and return single value
Parameters.Design.Load.DeltaPrime = max(maxSpan,[],2);

% Determine Member Actions Due to Distributed Load on All Spans - (Dead
% Load)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Member actions are in terms of in^4 and in^5 for shear and moment
% Unit distributed load and moment of inertia assumed.  Multiply by 
% distributed load and divide by moment of inertia.

% Get Moment Vectors for Each Displacement Vector
%**************************************************************************
% Get displacement and force vector for distributed unit load
load = 'Dead';
[~, ~, DD] = GetDisplacementVector(load, numDOF, condK, condInd, Fixed, Parameters);

if strcmp(Parameters.Design.Code, 'ASD')
    [M_Max(13,:), M_Min(13,:), V_Max(13,:), V_Min(13,:), ~, ~] = GetMemberForceVector(DD, load, Parameters, numEle);
else % Code is LRFD
    [M_Max(24,:), M_Min(24,:), V_Max(24,:), V_Min(24,:), ~, ~] = GetMemberForceVector(DD, load, Parameters, numEle); 
end

Parameters.Design.Load.M_Max(24,:) = M_Max(24,:);
Parameters.Design.Load.M_Min(24,:) = M_Min(24,:);
Parameters.Design.Load.V_Max(24,:) = V_Max(24,:);
Parameters.Design.Load.V_Min(24,:) = V_Min(24,:);

% Find max\min for each span
for i=1:length(Fixed)-1
    range = (Fixed(i)+1)/2:(Fixed(i+1)+1)/2;
    if strcmp(Parameters.Design.Code, 'ASD')
        Parameters.Design.Load.maxDLM(i) = max(max(M_Max(13,range))); % in lb.in
        Parameters.Design.Load.minDLM(i) = min(min(M_Min(13,range)));     
        Parameters.Design.Load.maxDLV(i) = max(max(V_Max(13,range))); % in lb
        Parameters.Design.Load.minDLV(i) = min(min(V_Min(13,range)));
    else % Code is LRFD
        Parameters.Design.Load.maxDLM(i) = max(max(M_Max(24,range))); % in lb.in
        Parameters.Design.Load.minDLM(i) = min(min(M_Min(24,range)));     
        Parameters.Design.Load.maxDLV(i) = max(max(V_Max(24,range))); % in lb
        Parameters.Design.Load.minDLV(i) = min(min(V_Min(24,range)));
    end
end

% Find max/min for points of interest
% Simple spans: Moment at midspan and shear at supports
% Continuous spans: Positive moment at midspan for interior spans and 0.4L
% at exterior spans. Negative moment and shear over supports
for i=1:Parameters.Spans
    range = (Fixed(i)+1)/2:(Fixed(i+1)+1)/2;
    
    if Parameters.Spans == 1
        POI = round(0.5*(range(end)-range(1)))+range(1);
    elseif i == 1 
        POI = round(0.4*(range(end)-range(1)))+range(1);
    elseif i == Parameters.Spans 
        POI = round(0.6*(range(end)-range(1)))+range(1);
    else
        POI = round(0.5*(range(end)-range(1)))+range(1);
    end
    
    if strcmp(Parameters.Design.Code, 'ASD')
        % Positive moment
        Parameters.Design.Load.maxDLM_POI(i,1) = M_Max(13,POI); % in lb.in    
        % Negative Moments
        Parameters.Design.Load.minDLM_POI(i,:) = M_Min(13,[(Fixed(i)+1)/2, (Fixed(i+1)+1)/2]);    
        % Shear
        Parameters.Design.Load.maxDLV_POI(i,:) = abs(V_Max(13,[(Fixed(i)+1)/2, (Fixed(i+1)+1)/2])); % in lb
    else
        % Positive moment
        Parameters.Design.Load.maxDLM_POI(i,1) = M_Max(24,POI); % in lb.in    
        % Negative Moments
        Parameters.Design.Load.minDLM_POI(i,:) = M_Min(24,[(Fixed(i)+1)/2, (Fixed(i+1)+1)/2]);    
        % Shear
        Parameters.Design.Load.maxDLV_POI(i,:) = abs(V_Max(24,[(Fixed(i)+1)/2, (Fixed(i+1)+1)/2])); % in lb
    end
    
end

% Find points of contraflexure under dead load for each span
if strcmp(Parameters.Design.Code, 'ASD')
    for i=1:numEle
        if (M_Max(13,i) <= 0 && M_Max(13,i+1) >= 0) || (M_Max(13,i) >= 0 && M_Max(13,i+1) <= 0)
            zeroM(i) = 1;
        else
            zeroM(i) = 0;
        end
    end
    zeroM(1) = 1;
    zeroM(end+1) = 1;
else
    for i=1:numEle
        if (M_Max(24,i) <= 0 && M_Max(24,i+1) >= 0) || (M_Max(24,i) >= 0 && M_Max(24,i+1) <= 0)
            zeroM(i) = 1;
        else
            zeroM(i) = 0;
        end
    end
    zeroM(1) = 1;
    zeroM(end+1) = 1;
end

for i=1:length(Fixed)-1
    range = (Fixed(i)+1)/2:(Fixed(i+1)+1)/2;
    Parameters.zeroMoment(i,:) = ((Fixed(i)-1)/2 + find(zeroM(range), 2)-1)*12;
    Parameters.EffectiveLength(i) = Parameters.zeroMoment(i,2) - Parameters.zeroMoment(i,1);
end
end