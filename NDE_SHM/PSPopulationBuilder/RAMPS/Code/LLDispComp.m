function Parameters = LLDispComp(Parameters,Options,ModelPath,ModelName)
%% Live Load
DataPathName = [ModelPath '\Data\Results_old\' ModelName '_LLD.mat'];

LLD = load(DataPathName);
LLDisp = LLD.LiveLoadDisp;

% Create live load lane combo list
vect = 1:Parameters.NumLane;
vect = padarray(vect, [0, Parameters.NumLane - 1], 'pre');
LLComb = unique(nchoosek(vect,Parameters.NumLane),'rows');

% Find max disp for each girder per lane
% BC 1
LaneMax = permute(min(LLDisp(:,:,:,2),[],1),[2 3 1]);

% Find max single lane displacement:
Parameters.ASD.FEM.Disp_sing = min(min(LaneMax))*(1+Parameters.ASD.Im);

% Envelope Live Load Disp
LLDisp_TotalGirder = zeros(Parameters.NumGirder,size(LLComb, 1));
for k = 1:size(LLComb, 1)
    if size(nonzeros(LLComb(k,:)),2) <= 2
        redfact = 1;
    elseif size(nonzeros(LLComb(k,:)),2) == 3
        redfact = 0.9;
    else
        redfact = 0.75;
    end
    
    % Find maxvert disp for lane combo for each girder
    LLDisp_TotalGirder(:,k) = sum(LaneMax(:,nonzeros(LLComb(k,:))),2)*redfact;
end

Parameters.ASD.FEM.Disp_gird = LLDisp_TotalGirder;

[Parameters.ASD.FEM.Disp, Parameters.ASD.FEM.Disp_ind] = min(Parameters.ASD.FEM.Disp_gird);

%% Liner girder disp
L = Parameters.Length;

switch Parameters.ASD.DesignLoad
    case '1'
        % H 10
        Parameters.DesignTruckName = 'H-10';
        
        Parameters.Load.A1 = 4000;
        Parameters.Load.A2 = 15000;
        Parameters.Load.A3 = 0;
        
        Parameters.Load.S1 = 168;
        Parameters.Load.S2 = 0;
    case '2'
        % H 15
        Parameters.DesignTruckName = 'H-15';
        
        Parameters.Load.A1 = 6000;
        Parameters.Load.A2 = 24000;
        Parameters.Load.A3 = 0;
        
        Parameters.Load.S1 = 168;
        Parameters.Load.S2 = 0;
    case '3'
        % HS 15
        Parameters.DesignTruckName = 'HS-15';
        
        Parameters.Load.A1 = 6000;
        Parameters.Load.A2 = 24000;
        Parameters.Load.A3 = 24000;
        
        Parameters.Load.S1 = 168;
        Parameters.Load.S2 = 168;
    case '4'
        % H 20
        Parameters.DesignTruckName = 'H-20';
        
        Parameters.Load.A1 = 8000;
        Parameters.Load.A2 = 32000;
        Parameters.Load.A3 = 0;
        
        Parameters.Load.S1 = 168;
        Parameters.Load.S2 = 0;
    case '5'
        % HS 20
        Parameters.DesignTruckName = 'HS-20';
        
        Parameters.Load.A1 = 8000;
        Parameters.Load.A2 = 32000;
        Parameters.Load.A3 = 32000;
        
        Parameters.Load.S1 = 168;
        Parameters.Load.S2 = 168;
    case '6'
        % HS 20 + Mod (HS 20 + Military Loading)
        if Parameters.Length >= 45.7632*12   % Use Hs-20 44
            Parameters.DesignTruckName = 'HS-20';
            
            Parameters.Load.A1 = 8000;
            Parameters.Load.A2 = 32000;
            Parameters.Load.A3 = 32000;
            
            Parameters.Load.S1 = 168;
            Parameters.Load.S2 = 168;
        else  % Use Alt. Military Loading
            Parameters.DesignTruckName = 'Alternate Military Loading';
            
            Parameters.Load.A1 = 24000;
            Parameters.Load.A2 = 24000;
            Parameters.Load.A3 = 0;
            
            Parameters.Load.S1 = 48;
            Parameters.Load.S2 = 0;
        end
    case '9'
        % HS 25 or greater - Assume HS 25
        Parameters.DesignTruckName = 'HS-25';
        
        Parameters.Load.A1 = 10000;
        Parameters.Load.A2 = 40000;
        Parameters.Load.A3 = 40000;
        
        Parameters.Load.S1 = 168;
        Parameters.Load.S2 = 168;
end

if Parameters.Load.A3 ~= 0   
    j = 0;
    V = zeros(length(1:L-337),1);
    Delta = zeros(length(1:L),3);
    for i = 1:L-337
        j = j+1;
        
        A = i;
        X = 1:A;
        B = L - A;
        P = Parameters.Load.A1;
        Delta(1:length(X),1) = P*B*X/(6*Parameters.Beam.E*L).*(L^2 - B^2 - X.^2);
        X = B:-1:1;
        Delta(A+1:L,1) = P*A*X/(6*Parameters.Beam.E*L).*(L^2 - A^2 - X.^2);
        
        A = i + Parameters.Load.S1;
        X = 1:A;
        B = L - A;
        P = Parameters.Load.A2;
        Delta(1:length(X),2) = P*B*X/(6*Parameters.Beam.E*L).*(L^2 - B^2 - X.^2);
        X = B:-1:1;
        Delta(A+1:L,2) = P*A*X/(6*Parameters.Beam.E*L).*(L^2 - A^2 - X.^2);
        
        A = i + Parameters.Load.S1 + Parameters.Load.S2;
        X = 1:A;
        B = L - A;
        P = Parameters.Load.A3;
        Delta(1:length(X),3) = P*B*X/(6*Parameters.Beam.E*L).*(L^2 - B^2 - X.^2);
        X = B:-1:1;
        Delta(A+1:L,3) = P*A*X/(6*Parameters.Beam.E*L).*(L^2 - A^2 - X.^2);
        
        V(j) = max(sum(Delta,2));
    end
    VMAX = max(V);
    
elseif Parameters.Load.A1 == Parameters.Load.A2
    B = L/2 - 24;
    X = L/2;
    P = Parameters.Load.A1;
    
    VMAX = 2*P*B*X/(6*Parameters.Beam.E*L)*(L^2 - B^2 - X^2);
else
    j = 0;
    V = zeros(length(1:L-169),1);
    Delta = zeros(length(1:L),2);
    
    for i = 1:L-169
        j = j+1;
        
        A = i;
        X = 1:A;
        B = L - A;
        P = Parameters.Load.A1;
        Delta(1:length(X),1) = P*B*X/(6*Parameters.Beam.E*L).*(L^2 - B^2 - X.^2);
        X = B:-1:1;
        Delta(A+1:L,1) = P*A*X/(6*Parameters.Beam.E*L).*(L^2 - A^2 - X.^2);
        
        A = i + Parameters.Load.S1;
        X = 1:A;
        B = L - A;
        P = Parameters.Load.A2;
        Delta(1:length(X),2) = P*B*X/(6*Parameters.Beam.E*L).*(L^2 - B^2 - X.^2);
        X = B:-1:1;
        Delta(A+1:L,2) = P*A*X/(6*Parameters.Beam.E*L).*(L^2 - A^2 - X.^2);
    
        V(j) = max(sum(Delta,2));
    end
    
    VMAX = max(V);
end

Veff = VMAX*(1+Parameters.ASD.Im)*Parameters.ASD.DF;
Parameters.ASD.Disp = Veff/Parameters.Beam.Ist;

end %FEMRatingFactors()