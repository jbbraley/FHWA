% Single-Line Finite Element Approximation
function [Parameters,ArgOut] = GetFEApproximation(Parameters, I_diff)
ArgOut = Parameters.Design.Load;
% Define Variables used in GetFEApproximation -----------------------------

SpanLength = round(Parameters.Length/12)'; %[ft]
TotalLength = sum(SpanLength); %[ft]
E = Parameters.Beam.E; %[psi]
L = 12; %[inches], length of beam elements 
numEle = TotalLength; % # of beam elements discretized at 1 foot
numNode = numEle + 1; % number of nodes along entire length
numDOF = numNode*2; % number of DOFs (deflection/rotation at each node)

CPratio = Parameters.Beam.CoverPlate.Ratio;

% Assemble in global stiffness matrix ------------------------------------- 
% assumimg unit/dimensionless I - in lb/in^5

% Element stiffness matrix
eleK=E/L^3*[12,  6*L,   -12,  6*L;
            6*L, 4*L^2, -6*L, 2*L^2;
            -12, -6*L,  12,   -6*L;
            6*L, 2*L^2, -6*L, 4*L^2];
        
% Pre-allocate global stiffness matrix
globalK = zeros(numDOF);

% Fill global stiffness matrix with element stiffness matricies
for ii = 1:numEle % for each beam element
    Loc = 2*ii-1; % location of element in global matrix
    if ~isempty(I_diff) && CPratio > 0
        if ii > floor((1-CPratio)*numEle/2) && ii < ceil((1+CPratio)*numEle/2)   
            K = eleK*I_diff;
        else
            K = eleK;
        end
    else
        K = eleK;
    end           
    globalK(Loc:Loc+3,Loc:Loc+3) = globalK(Loc:Loc+3,Loc:Loc+3) + K;
end

% Determine nodes with fixed DOFs 
Fixed = zeros(Parameters.Spans, 1);
for ii = 1:Parameters.Spans
    Fixed(ii) = sum(SpanLength(1:ii));
end
Fixed = [1; 2*Fixed + 1];

% Remove DOFs at fixed nodes
condInd = 1:numDOF;
condInd = removerows(condInd', Fixed);
condK = removerows(globalK, Fixed);
condK = removerows(condK', Fixed)';

% Determine displacements for DL and LL -----------------------------------
% (trucks and lane loads)

% Define loading types
if strcmp(Parameters.Design.Code, 'ASD') % Code is ASD
    lType = {'Dead';'Truck_Forward'; 'Truck_Backward'; 'Truck_Forward_Dual';... % Does ASD use truck forward, backward, dual?
        'Truck_Backward_Dual'; 'Tandem'; 'Point'; 'Lane_PatternEven';'Lane_PatternOdd'; 'Lane_All'};
else % Code is LRFD
    lType = {'Dead';'Truck_Forward'; 'Truck_Backward'; 'Truck_Forward_Dual';...
        'Truck_Backward_Dual'; 'Tandem'; 'Lane_PatternEven';'Lane_PatternOdd'; 'Lane_All'};
end

% Run GetDisplacementVector() to find displacements 
for ii = 1:length(lType)
    if strcmp(lType{ii},'Tandem') && Parameters.Design.Tandem == 0
        continue
    end
    if strcmp(lType{ii}(1:4),'Lane') && Parameters.Design.LaneLoad == 0
        continue
    end
    [Delta_Min(ii,:), Delta_Max(ii,:), D{ii}] = GetDisplacementVector(lType{ii},numDOF,condK,condInd,Fixed,Parameters); 
end

% Fill 'Delta' Matricies --------------------------------------------------
if strcmp(Parameters.Design.Code, 'ASD')
    % Superimpose lane and point loading, all [in^5]
    % Delta_Min
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(2,1,2),:) + Delta_Min((8:10),:); % Truck_Forward
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(3,1,3),:) + Delta_Min((8:10),:); % Truck_Backward
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(4,1,4),:) + Delta_Min((8:10),:); % Truck_Forward_Dual
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(5,1,5),:) + Delta_Min((8:10),:); % Truck_Backward_Dual
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(6,1,6),:) + Delta_Min((8:10),:); % Tandem
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(7,1,7),:) + Delta_Min((8:10),:); % Point
    % Delta_Max
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(2,1,2),:) + Delta_Max((8:10),:); % Truck_Forward
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(3,1,3),:) + Delta_Max((8:10),:); % Truck_Backward
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(4,1,4),:) + Delta_Max((8:10),:); % Truck_Forward_Dual
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(5,1,5),:) + Delta_Max((8:10),:); % Truck_Backward_Dual
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(6,1,6),:) + Delta_Max((8:10),:); % Tandem 
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(7,1,7),:) + Delta_Max((8:10),:); % Point 
else % Code is LRFD
    % Superimpose lane and truck loading AASHTO 2012 [3.6.1.3], all [in^5]
    % Delta_Min
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(2,1,2),:) + Delta_Min((7:9),:); % Truck_Forward
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(3,1,3),:) + Delta_Min((7:9),:); % Truck_Backward
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(4,1,4),:) + Delta_Min((7:9),:); % Truck_Forward_Dual
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(5,1,5),:) + Delta_Min((7:9),:); % Truck_Backward_Dual
    Delta_Min(end+(1:3),:) = Delta_Min(padarray(6,1,6),:) + Delta_Min((7:9),:); % Tandem
    % Delta_Max
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(2,1,2),:) + Delta_Max((7:9),:); % Truck_Forward
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(3,1,3),:) + Delta_Max((7:9),:); % Truck_Backward
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(4,1,4),:) + Delta_Max((7:9),:); % Truck_Forward_Dual
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(5,1,5),:) + Delta_Max((7:9),:); % Truck_Backward_Dual
    Delta_Max(end+(1:3),:) = Delta_Max(padarray(6,1,6),:) + Delta_Max((7:9),:); % Tandem
end


% Determine Member Actions Due to DL and LL -------------------------------
% (Moment and Shear)

% Run GetMemberForceVector() to find member actions
for i = 1:length(lType)
    if strcmp(lType{ii},'Tandem') && Parameters.Design.Tandem == 0
        continue
    end
    if strcmp(lType{ii}(1:4),'Lane') && Parameters.Design.LaneLoad == 0
        continue
    end
    [M_Max(i,:), M_Min(i,:), V_Max(i,:), V_Min(i,:), M{i}, V{i}] = GetMemberForceVector(D{i}, lType{i}, Parameters, numEle, I_diff); 
end

% Fill 'M' and 'V' matricies ----------------------------------------------
if strcmp(Parameters.Design.Code, 'ASD')
    % Superimpose Moment for lane and truck loading, all [lb.in]
    % M_Min
    M_Min(end+(1:3),:) = M_Min(padarray(2,1,2),:) + M_Min((8:10),:); % Truck_Forward
    M_Min(end+(1:3),:) = M_Min(padarray(3,1,3),:) + M_Min((8:10),:); % Truck_Backward
    M_Min(end+(1:3),:) = M_Min(padarray(4,1,4),:) + M_Min((8:10),:); % Truck_Forward_Dual
    M_Min(end+(1:3),:) = M_Min(padarray(5,1,5),:) + M_Min((8:10),:); % Truck_Backward_Dual
    M_Min(end+(1:3),:) = M_Min(padarray(6,1,6),:) + M_Min((8:10),:); % Tandem
    M_Min(end+(1:3),:) = M_Min(padarray(7,1,7),:) + M_Min((8:10),:); % Point
    % M_Max
    M_Max(end+(1:3),:) = M_Max(padarray(2,1,2),:) + M_Max((8:10),:); % Truck_Forward
    M_Max(end+(1:3),:) = M_Max(padarray(3,1,3),:) + M_Max((8:10),:); % Truck_Backward
    M_Max(end+(1:3),:) = M_Max(padarray(4,1,4),:) + M_Max((8:10),:); % Truck_Forward_Dual
    M_Max(end+(1:3),:) = M_Max(padarray(5,1,5),:) + M_Max((8:10),:); % Truck_Backward_Dual
    M_Max(end+(1:3),:) = M_Max(padarray(6,1,6),:) + M_Max((8:10),:); % Tandem 
    M_Max(end+(1:3),:) = M_Max(padarray(7,1,7),:) + M_Max((8:10),:); % Point 
    
    % Superimpose Shear for lane and truck loading, all [lb.in]
    % M_Min
    V_Min(end+(1:3),:) = V_Min(padarray(2,1,2),:) + V_Min((8:10),:); % Truck_Forward
    V_Min(end+(1:3),:) = V_Min(padarray(3,1,3),:) + V_Min((8:10),:); % Truck_Backward
    V_Min(end+(1:3),:) = V_Min(padarray(4,1,4),:) + V_Min((8:10),:); % Truck_Forward_Dual
    V_Min(end+(1:3),:) = V_Min(padarray(5,1,5),:) + V_Min((8:10),:); % Truck_Backward_Dual
    V_Min(end+(1:3),:) = V_Min(padarray(6,1,6),:) + V_Min((8:10),:); % Tandem
    V_Min(end+(1:3),:) = V_Min(padarray(7,1,7),:) + V_Min((8:10),:); % Point
    % M_Max
    V_Max(end+(1:3),:) = V_Max(padarray(2,1,2),:) + V_Max((8:10),:); % Truck_Forward
    V_Max(end+(1:3),:) = V_Max(padarray(3,1,3),:) + V_Max((8:10),:); % Truck_Backward
    V_Max(end+(1:3),:) = V_Max(padarray(4,1,4),:) + V_Max((8:10),:); % Truck_Forward_Dual
    V_Max(end+(1:3),:) = V_Max(padarray(5,1,5),:) + V_Max((8:10),:); % Truck_Backward_Dual
    V_Max(end+(1:3),:) = V_Max(padarray(6,1,6),:) + V_Max((8:10),:); % Tandem 
    V_Max(end+(1:3),:) = V_Max(padarray(7,1,7),:) + V_Max((8:10),:); % Point 
        
else % Code is LRFD
    % Superimpose Moment for lane and truck loading, all [lb.in]
    % M_Min
    M_Min(end+(1:3),:) = M_Min(padarray(2,1,2),:) + M_Min((7:9),:); % Truck_Forward
    M_Min(end+(1:3),:) = M_Min(padarray(3,1,3),:) + M_Min((7:9),:); % Truck_Backward
    M_Min(end+(1:3),:) = M_Min(padarray(4,1,4),:) + M_Min((7:9),:); % Truck_Forward_Dual
    M_Min(end+(1:3),:) = M_Min(padarray(5,1,5),:) + M_Min((7:9),:); % Truck_Backward_Dual
    M_Min(end+(1:3),:) = M_Min(padarray(6,1,6),:) + M_Min((7:9),:); % Tandem
    % M_Max
    M_Max(end+(1:3),:) = M_Max(padarray(2,1,2),:) + M_Max((7:9),:); % Truck_Forward
    M_Max(end+(1:3),:) = M_Max(padarray(3,1,3),:) + M_Max((7:9),:); % Truck_Backward
    M_Max(end+(1:3),:) = M_Max(padarray(4,1,4),:) + M_Max((7:9),:); % Truck_Forward_Dual
    M_Max(end+(1:3),:) = M_Max(padarray(5,1,5),:) + M_Max((7:9),:); % Truck_Backward_Dual
    M_Max(end+(1:3),:) = M_Max(padarray(6,1,6),:) + M_Max((7:9),:); % Tandem 
    
    % Superimpose Shear for lane and truck loading, all [lb.in]
    % M_Min
    V_Min(end+(1:3),:) = V_Min(padarray(2,1,2),:) + V_Min((7:9),:); % Truck_Forward
    V_Min(end+(1:3),:) = V_Min(padarray(3,1,3),:) + V_Min((7:9),:); % Truck_Backward
    V_Min(end+(1:3),:) = V_Min(padarray(4,1,4),:) + V_Min((7:9),:); % Truck_Forward_Dual
    V_Min(end+(1:3),:) = V_Min(padarray(5,1,5),:) + V_Min((7:9),:); % Truck_Backward_Dual
    V_Min(end+(1:3),:) = V_Min(padarray(6,1,6),:) + V_Min((7:9),:); % Tandem
    % M_Max
    V_Max(end+(1:3),:) = V_Max(padarray(2,1,2),:) + V_Max((7:9),:); % Truck_Forward
    V_Max(end+(1:3),:) = V_Max(padarray(3,1,3),:) + V_Max((7:9),:); % Truck_Backward
    V_Max(end+(1:3),:) = V_Max(padarray(4,1,4),:) + V_Max((7:9),:); % Truck_Forward_Dual
    V_Max(end+(1:3),:) = V_Max(padarray(5,1,5),:) + V_Max((7:9),:); % Truck_Backward_Dual
    V_Max(end+(1:3),:) = V_Max(padarray(6,1,6),:) + V_Max((7:9),:); % Tandem 
end

% Save to Parameters
ArgOut.M_Max = M_Max;
ArgOut.M_Min = M_Min;
ArgOut.V_Max = V_Max;
ArgOut.V_Min = V_Min;

% Save responses for Fatigue Limit State (Single truck with 30' axle
% spacing) and impact factor for fatigue
ArgOut.maxFM = (max(M{1,2}(:,:,3),[],2)')*(Parameters.Design.IMF/Parameters.Design.IM);
ArgOut.minFM = (min(M{1,2}(:,:,3),[],2)')*(Parameters.Design.IMF/Parameters.Design.IM);


% Find max\min DL and LL for each span ------------------------------------

for i=1:length(Fixed)-1
    range = (Fixed(i)+1)/2:(Fixed(i+1)+1)/2;
    % Dead Load Moment
    ArgOut.maxDLM(i) = max(max(M_Max(1,range))); % in lb.in
    ArgOut.minDLM(i) = min(min(M_Min(1,range)));
    % Dead Load Shear
    ArgOut.maxDLV(i) = max(max(V_Max(1,range))); % in lb
    ArgOut.minDLV(i) = min(min(V_Min(1,range)));
    % Live Load Moment
    ArgOut.maxM(i) = max(max(M_Max(:,range))); % in lb.in
    ArgOut.minM(i) = min(min(M_Min(:,range))); 
    % Live Load Shear 
    ArgOut.maxV(i) = max(max(V_Max(:,range))); % in lb
    ArgOut.minV(i) = min(min(V_Min(:,range)));
end

% Find max/min DL and LL for points of interest ---------------------------

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
    
    % Displacements
    maxSpan(i,1) = max(max(Delta_Max(:,Fixed(i):2:Fixed(i+1)),[],1));
    maxSpan(i,2) = max(-1*min(Delta_Min(:,Fixed(i):2:Fixed(i+1)),[],1));    
    % Dead Load Moment
    ArgOut.minDLM_POI(i,:) = M_Min(1,[(Fixed(i)+1)/2, (Fixed(i+1)+1)/2]);
    ArgOut.maxDLM_POI(i,1) = M_Max(1,POI); % in lb.in  
    % Dead Load Shear
    ArgOut.maxDLV_POI(i,:) = abs(V_Max(1,[(Fixed(i)+1)/2, (Fixed(i+1)+1)/2])); % in lb
    % Live Load Moment
    ArgOut.minM_POI(i,:) = min(M_Min(:,[(Fixed(i)+1)/2, (Fixed(i+1)+1)/2])); % [lb.in]
    ArgOut.maxM_POI(i,:) = max(M_Max(:,POI)); % [lb.in]
    % Live Load Shear
    ArgOut.maxV_POI(i,:) = max(abs(V_Max(:,[(Fixed(i)+1)/2, (Fixed(i+1)+1)/2]))); % [lb]
end

% find max deflection per span length and return single value
Parameters.Design.DeltaPrime = max(maxSpan,[],2);


% Find points of contraflexure under dead load for each span

for i=1:numEle
    if (M_Max(1,i) <= 0 && M_Max(1,i+1) >= 0) || (M_Max(1,i) >= 0 && M_Max(1,i+1) <= 0)
        zeroM(i) = 1;
    else
        zeroM(i) = 0;
    end
end
zeroM(1) = 1;
zeroM(end+1) = 1;

if Parameters.Spans > 1
    for i=1:length(Fixed)-1
        range = (Fixed(i)+1)/2:(Fixed(i+1)+1)/2;
        Parameters.zeroMoment(i,:) = ((Fixed(i)-1)/2 + find(zeroM(range), 2)-1)*12;
        Parameters.EffectiveLength(i) = Parameters.zeroMoment(i,2) - Parameters.zeroMoment(i,1);
    end
end
end