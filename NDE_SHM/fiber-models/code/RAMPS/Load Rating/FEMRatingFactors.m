% 10.01.14 - jbb - Replaced Parameters.NumLane with Parameters.NumRatingLane

function Parameters = FEMRatingFactors(Parameters,Options,ModelPath,ModelName)

switch Parameters.structureType
    case 'Steel'
        % Get Stresses
        if strcmp(Parameters.Rating.Code, 'ASD')
            fIOp = {'0.55*Parameters.Beam.Fy'};
            fIInv = {'0.75*Parameters.Beam.Fy'};
            F1 = 1;
            F2 = 1;
            F3 = 1;

            State = 'St1';
            Demand = 'Stress';

            % Check for variable
            if ~isfield(Parameters.Design,'Im')
                Parameters.Design.Im = 50./(Parameters.Length/12+125);
                if Parameters.Design.Im > 0.3
                    Parameters.Design.Im = 0.3;
                end
            end

        elseif strcmp(Parameters.Rating.Code, 'LRFD')
            if strcmp(Parameters.Beam.Type,'Rolled') || Parameters.Beam.Comp==1
                % Capacity Parameters for compact sections
                fIOp_pos = {'Parameters.Beam.Fy'; 'Parameters.Beam.Mn_pos'};
                fIOp_neg = {'Parameters.Beam.Fy'; 'Parameters.Beam.Fn_neg'};
                fIInv_pos = {'Parameters.Beam.Fy'; 'Parameters.Beam.Mn_pos'};
                fIInv_neg = {'Parameters.Beam.Fy'; 'Parameters.Beam.Fn_neg'};
                % Demand responses for positive moment regions
                Demand = ['Stress'; 'Moment'];
            else
                % Capacity Parameters for non-compact sections
                fIOp_pos = {'Parameters.Beam.Fy'; 'Parameters.Beam.Fn_pos'};
                fIOp_neg = {'Parameters.Beam.Fy'; 'Parameters.Beam.Fn_neg'};
                fIInv_pos = {'Parameters.Beam.Fy'; 'Parameters.Beam.Fn_pos'};
                fIInv_neg = {'Parameters.Beam.Fy'; 'Parameters.Beam.Fn_neg'};
                % Demand responses for positive moment regions
                Demand = ['Stress'; 'Stress'];
            end
            % Factors
            F1 = [0.95 1.0];
            F2 = [1.0 1.35];
            F3 = [1.30 1.75];
            F4 = [1.0 1.25];
            F5 = [1.0 1.5];
            % Limit States (Service II & Strength I for Steel Girder)
            State = ['Sv2';'St1'];    

            % Check for variable
            if ~isfield(Parameters.Design, 'IMF')
                Parameters.Design.IMF = 1.33;
            end
        end
        
        % Get Section Properties
        BeamS1 = Parameters.Beam.Ix/(Parameters.Beam.d/2);
        BeamS2 = Parameters.Beam.Iy/(Parameters.Beam.bf/2);
        BeamA = Parameters.Beam.A;

        if isfield(Parameters.Beam,'CoverPlate') && isfield(Parameters.Beam.CoverPlate, 'A')
            BeamS1_Neg = Parameters.Beam.CoverPlate.Ix/(Parameters.Beam.CoverPlate.d/2);
            BeamS2_Neg = Parameters.Beam.CoverPlate.Iy/(Parameters.Beam.bf/2);
            BeamA_Neg = Parameters.Beam.CoverPlate.A;
        else
            BeamS1_Neg = BeamS1;
            BeamS2_Neg = BeamS2;
            BeamA_Neg = BeamA;
        end

    case 'Prestressed'
        % Capacity Parameters for compact sections
        fIOp_pos = {''; 'Parameters.Beam.Mn_pos'};
        fIInv_pos = {'Parameters.Beam.Fn_pos'; 'Parameters.Beam.Mn_pos'};
        % Demand responses for positive moment regions
        Demand = ['Stress'; 'Moment'];

        % Factors
        F1 = [1.0 1.0];
        F2 = [1.0 1.35];
        F3 = [0.8 1.75];
        F4 = [1.0 1.25];
        F5 = [1.0 1.50];
        % Limit States (Service III & Strength I for Prestressed Girder)
        State = ['Sv3';'St1'];    

        % Check for variable
        if ~isfield(Parameters.Design, 'IMF')
            Parameters.Design.IMF = 1.33;
        end
        
        BeamA = Parameters.Beam.A;
        BeamS1 = Parameters.Beam.Sb;
        BeamS2 = Parameters.Beam.Iy/Parameters.Beam.xb;        
end



%% Dead Load
% Get results from root
DLR = Parameters.Rating.DLR;
ws_pad = 3 - size(DLR.ForcePos, 2);
DLR.ForcePos = padarray(DLR.ForcePos, [0 ws_pad], 'post');  
DLStressP = max(abs(DLR.StrPos(:,:,:,1:2)),[],4);
DLMom1P = DLR.ForcePos(:,:,:,4);
DLMom2P = DLR.ForcePos(:,:,:,6);
DLAxialP = DLR.ForcePos(:,:,:,1);
DLCompMomP = DLR.ForcePos(:,:,:,4)-DLR.ForcePos(:,:,:,1)*(Parameters.Beam.d+Parameters.Deck.t)/2;
if Parameters.Spans~=1
ws_pad = 3 - size(DLR.ForceNeg, 2);
DLR.ForceNeg = padarray(DLR.ForceNeg, [0 ws_pad], 'post'); 
DLStressN = max(abs(DLR.StrNeg(:,:,:,1:2)),[],4);
DLMom1N = DLR.ForceNeg(:,:,:,4);
DLMom2N = DLR.ForceNeg(:,:,:,6);
DLAxialN = DLR.ForceNeg(:,:,:,1);
DLCompMomN = DLR.ForceNeg(:,:,:,4)-DLR.ForceNeg(:,:,:,1)*(Parameters.Beam.CoverPlate.d+Parameters.Deck.t)/2;
end

% Reorganize arrays with dead load type is last index
DLMoment1_Pos = permute(DLMom1P,[1 3 2]);
DLMoment2_Pos = permute(DLMom2P,[1 3 2]);
DLAxial_Pos = permute(DLAxialP,[1 3 2]);

DLStress_Pos = abs(DLMoment1_Pos/BeamS1) + abs(DLMoment2_Pos/BeamS2) + abs(DLAxial_Pos/BeamA); %permute(sum(DLStressP, 2),[1 3 2]);
DLMoment_Pos = permute(DLCompMomP,[1 3 2]);
if Parameters.Spans~=1
    DLMoment1_Neg = permute(DLMom1N,[1 3 2]);
    DLMoment2_Neg = permute(DLMom2N,[1 3 2]);
    DLAxial_Neg = permute(DLAxialN,[1 3 2]);
    
    DLStress_Neg = abs(DLMoment1_Neg/BeamS1_Neg) + abs(DLMoment2_Neg/BeamS2_Neg) + abs(DLAxial_Neg/BeamA_Neg); %permute(sum(DLStressN, 2),[1 3 2]);
    DLMoment_Neg = permute(DLCompMomN,[1 3 2]);
end

%% Live Load
% Get results from root
LLR = Parameters.Rating.LLR;

LLMom1P = LLR.ForcePos(:,:,:,:,:,4);
LLMom2P = LLR.ForcePos(:,:,:,:,:,6);
LLAxialP = LLR.ForcePos(:,:,:,:,:,1);
LLCompMomP = LLR.ForcePos(:,:,:,:,:,4)-LLR.ForcePos(:,:,:,:,:,1)*(Parameters.Beam.d+Parameters.Deck.t)/2;
if Parameters.Spans~=1
    LLMom1N = LLR.ForceNeg(:,:,:,:,:,4);
    LLMom2N = LLR.ForceNeg(:,:,:,:,:,6);
    LLAxialN = LLR.ForceNeg(:,:,:,:,:,1);
    LLCompMomN = LLR.ForceNeg(:,:,:,:,:,4)-LLR.ForceNeg(:,:,:,:,:,1)*(Parameters.Beam.CoverPlate.d+Parameters.Deck.t)/2;
end

if strcmp(Parameters.Rating.Code, 'LRFD')
    vect = 1:Parameters.Spans;
    vect = padarray(vect, [0,Parameters.Spans-1],'pre');
    LaneComb = unique(nchoosek(vect,Parameters.Spans),'rows');
  
    LaneLoadMom1P = LLMom1P(:,:,:,end-Parameters.Spans+1:end,:);
    LaneLoadMom2P = LLMom2P(:,:,:,end-Parameters.Spans+1:end,:);
    LaneLoadAxP = LLAxialP(:,:,:,end-Parameters.Spans+1:end,:);
    LaneLoadCompMomP = LLCompMomP(:,:,:,end-Parameters.Spans+1:end,:);
    if Parameters.Spans~=1
        LaneLoadMom1N = LLMom1N(:,:,:,end-Parameters.Spans+1:end,:);
        LaneLoadMom2N = LLMom2N(:,:,:,end-Parameters.Spans+1:end,:);
        LaneLoadAxN = LLAxialN(:,:,:,end-Parameters.Spans+1:end,:);
        LaneLoadCompMomN = LLCompMomN(:,:,:,end-Parameters.Spans+1:end,:);
    end
    
    LaneLoadMoment1P = [];
    LaneLoadMoment2P = [];
    LaneLoadAxialP = [];
    LaneLoadCompMomentP = [];
    TruckLaneMoment1P = [];
    TruckLaneMoment2P = [];
    TruckLaneAxialP = [];
    TruckLaneCompMomentP = [];
    if Parameters.Spans~=1
        LaneLoadMoment1N = [];
        LaneLoadMoment2N = [];
        LaneLoadAxialN = [];
        LaneLoadMomentN = [];
        TruckLaneMoment1N = [];
        TruckLaneMoment2N = [];
        TruckLaneAxialN = [];
        TruckLaneCompMomentN = [];
    end
    
    for k = 1:size(LaneComb, 1)
        spans = nonzeros(LaneComb(k,:));   

        % Sum stress and Moment for different spans corresponding to lane combo at each girder at each poi
        LaneLoadMoment1P = cat(5,LaneLoadMoment1P,permute(sum(LaneLoadMom1P(:,:,:,spans,:),4),[1 2 3 5 4]));
        LaneLoadMoment2P = cat(5,LaneLoadMoment2P,permute(sum(LaneLoadMom2P(:,:,:,spans,:),4),[1 2 3 5 4]));
        LaneLoadAxialP = cat(5,LaneLoadAxialP,permute(sum(LaneLoadAxP(:,:,:,spans,:),4),[1 2 3 5 4]));        
        LaneLoadCompMomentP = cat(5,LaneLoadCompMomentP,permute(sum(LaneLoadCompMomP(:,:,:,spans,:),4),[1 2 3 5 4])); 
        
        if Parameters.Spans~=1
            LaneLoadMoment1N = cat(5,LaneLoadMoment1N,permute(sum(LaneLoadMom1N(:,:,:,spans,:),4),[1 2 3 5 4]));
            LaneLoadMoment2N = cat(5,LaneLoadMoment2N,permute(sum(LaneLoadMom2N(:,:,:,spans,:),4),[1 2 3 5 4]));
            LaneLoadAxialN = cat(5,LaneLoadAxialN,permute(sum(LaneLoadAxN(:,:,:,spans,:),4),[1 2 3 5 4]));    
            LaneLoadMomentN = cat(5,LaneLoadMomentN,permute(sum(LaneLoadCompMomN(:,:,:,spans,:),4),[1 2 3 5 4]));
        end
        % Add truck Loads to Lane Load Combos (any truck load + plus any lane load
        % per lane)
        for j=1:size(LLMom1P,4)-Parameters.Spans
            TruckLaneMoment1P = cat(5,TruckLaneMoment1P,LaneLoadMoment1P(:,:,:,:,k)+permute(LLMom1P(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
            TruckLaneMoment2P = cat(5,TruckLaneMoment2P,LaneLoadMoment2P(:,:,:,:,k)+permute(LLMom2P(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
            TruckLaneAxialP = cat(5,TruckLaneAxialP,LaneLoadAxialP(:,:,:,:,k)+permute(LLAxialP(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
            TruckLaneCompMomentP = cat(5,TruckLaneCompMomentP,LaneLoadCompMomentP(:,:,:,:,k)+permute(LLCompMomP(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
            if Parameters.Spans~=1
                TruckLaneMoment1N = cat(5,TruckLaneMoment1N,LaneLoadMoment1N(:,:,:,:,k)+permute(LLMom1N(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
                TruckLaneMoment2N = cat(5,TruckLaneMoment2N,LaneLoadMoment2N(:,:,:,:,k)+permute(LLMom2N(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
                TruckLaneAxialN = cat(5,TruckLaneAxialN,LaneLoadAxialN(:,:,:,:,k)+permute(LLAxialN(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
                TruckLaneCompMomentN = cat(5,TruckLaneCompMomentN,LaneLoadMomentN(:,:,:,:,k)+permute(LLCompMomN(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
            end
        end
    end
else
    TruckLaneMoment1P = permute(LLMom1P,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
    TruckLaneMoment2P = permute(LLMom2P,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
    TruckLaneAxialP = permute(LLAxialP,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
    TruckLaneCompMomentP = permute(LLCompMomP,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
    if Parameters.Spans~=1
        TruckLaneMoment1N = permute(LLMom1N,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
        TruckLaneMoment2N = permute(LLMom2N,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
        TruckLaneAxialN = permute(LLAxialN,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
        TruckLaneCompMomentN = permute(LLCompMomN,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
    end
end

vect = 1:Parameters.Rating.NumLane;
vect = padarray(vect, [0,Parameters.Rating.NumLane-1],'pre');
MultiPresComb = unique(nchoosek(vect,Parameters.Rating.NumLane),'rows');
LLMoment1_TotP = [];
LLMoment2_TotP = [];
LLAxial_TotP = [];
LLCompMoment_TotP = [];
if Parameters.Spans~=1
    LLMoment1_TotN = [];
    LLMoment2_TotN = [];
    LLAxial_TotN = [];
    LLCompMoment_TotN = [];
end
for ii=1:size(MultiPresComb,1)
    lanes = nonzeros(MultiPresComb(ii,:));
    NumRatingLanes = length(lanes);
        
    if strcmp(Parameters.Rating.Code, 'ASD')
        if NumRatingLanes <= 2
            redfact = 1;
        elseif NumRatingLanes == 3
            redfact = 0.9;
        else
            redfact = 0.75;
        end
    elseif strcmp(Parameters.Rating.Code, 'LRFD')
        if NumRatingLanes>3
            NumRatingLanes = 4;
        end
        redfact = Parameters.Rating.MulPres(NumRatingLanes);
        
    end
    
    % Sum stress for different combinations of having multiple lanes loaded
    LLMoment1_TotP = cat(5,LLMoment1_TotP,permute(sum(TruckLaneMoment1P(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
    LLMoment2_TotP = cat(5,LLMoment2_TotP,permute(sum(TruckLaneMoment2P(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
    LLAxial_TotP = cat(5,LLAxial_TotP,permute(sum(TruckLaneAxialP(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);

    LLCompMoment_TotP = cat(5,LLCompMoment_TotP,permute(sum(TruckLaneCompMomentP(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
    if Parameters.Spans~=1
        LLMoment1_TotN = cat(5,LLMoment1_TotN,permute(sum(TruckLaneMoment1N(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
        LLMoment2_TotN = cat(5,LLMoment2_TotN,permute(sum(TruckLaneMoment2N(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
        LLAxial_TotN = cat(5,LLAxial_TotN,permute(sum(TruckLaneAxialN(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
        LLCompMoment_TotN = cat(5,LLCompMoment_TotN,permute(sum(TruckLaneCompMomentN(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
    end
end
    
LLComputedStressPos = abs(LLMoment1_TotP/BeamS1) + abs(LLMoment2_TotP/BeamS2) + abs(LLAxial_TotP/BeamA);

LLStress_Pos = permute(max(max(LLComputedStressPos,[],5),[],4),[2 3 1]); %permute(max(max(LLStress_TotP,[],5),[],4),[2 3 1]);
LLMoment_Pos = permute(max(max(LLCompMoment_TotP,[],5),[],4),[2 3 1]);
if Parameters.Spans~=1
    LLComputedStressNeg = abs(LLMoment1_TotN/BeamS1_Neg) + abs(LLMoment2_TotN/BeamS2_Neg) + abs(LLAxial_TotN/BeamA_Neg);
    LLStress_Neg = permute(max(max(abs(LLComputedStressNeg),[],5),[],4),[2 3 1]);%permute(max(max(abs(LLStress_TotN),[],5),[],4),[2 3 1]);
    LLMoment_Neg = permute(max(max(abs(LLCompMoment_TotN),[],5),[],4),[2 3 1]);
end

%% Compute Rating Factors
% Clear any previously stored rating data
% Parameters.Rating = [];
for jj = 1:length(F2)
    
    
%% Service & Strength Rating
%Inventory Rating Factor
% Compute rating factors for all girders and all positve moment regions for
% all three lane positions
if ~isempty(fIInv_pos{jj})
for ii=1:size(LLStress_Pos,3)
    RFInv_allP(:,:,ii) = (F1(jj)*eval(fIInv_pos{jj}) - F4(jj)*abs(sum(eval(['DL' Demand(jj,:) '_Pos(:,:,1:2)']),3))-F5(jj)*abs(eval(['DL' Demand(jj,:) '_Pos(:,:,3)'])))./(F3(jj)*abs(eval(['LL' Demand(jj,:) '_Pos(:,:,ii)'])));
end
% Find lane position that creates lowest rating 
[RFInvLaneP, RFInvP_indL] = min(RFInv_allP,[],3);
% Find locations with minimum 
[RFInvLocP, RFInvP_ind] = min(RFInvLaneP,[],2);
% Find girder with minimum
[RFInvGirdP, RFInvP_ind2] = min(RFInvLocP);
% Organize Indices into vector (Girder, Location, Max or Min stress)
ind(1,:) = [RFInvP_ind2 RFInvP_ind(RFInvP_ind2) RFInvP_indL(RFInvP_ind(RFInvP_ind2))];
end
% Compute rating factors for all girders and all negative moment regions
if Parameters.Spans~=1 && ~isempty(fIInv_neg{jj})
    for ii=1:size(LLStress_Neg,3)
        RFInv_allN(:,:,ii) = (F1(jj)*eval(fIInv_neg{jj}) - F4(jj)*abs(sum(eval(['DL' Demand(1,:) '_Neg(:,:,1:2)']),3))-F5(jj)*abs(eval(['DL' Demand(1,:) '_Neg(:,:,3)'])))./(F3(jj)*abs(eval(['LL' Demand(1,:) '_Neg(:,:,ii)'])));
    end
    % Find lane position that creates lowest rating 
    [RFInvLaneN, RFInvN_indL] = min(RFInv_allN,[],3);
    % Find locations with minimum 
    [RFInvLocN, RFInvN_ind] = min(RFInvLaneN,[],2);
    % Find girder with minimum
    [RFInvGirdN, RFInvN_ind2] = min(RFInvLocN);
    % Organize Indices into vector (Girder, Location, Max or Min stress)
    ind(2,:) = [RFInvN_ind2 RFInvN_ind(RFInvN_ind2) RFInvN_indL(RFInvN_ind(RFInvN_ind2))];

    % Find overall minimum rating (positive or negative moment region)
    [RFInv, ind3] = min([RFInvGirdP,RFInvGirdN]);
    RFInv_ind = [ind3 ind(ind3,:)]; %Positive or Neg. moment region, Girder, Location along bridge, max or min stress
else
    try
    % If only a single span--only a positive moment region
    RFInv = RFInvGirdP;
    % Indexed location of minimum rating factor
    RFInv_ind = [1 ind(1,:)]; %Positive moment region, Girder, Location along bridge, max or min stress
    catch
    end
end

%Operating Rating Factor
if ~isempty(fIOp_pos{jj})
for ii=1:size(LLStress_Pos,3)
    % Compute rating factors for all girders and all positve moment regions and
    % all 3 lane positions
    RFOp_allP(:,:,ii) = (F1(jj)*eval(fIOp_pos{jj}) - F4(jj)*abs(sum(eval(['DL' Demand(jj,:) '_Pos(:,:,1:2)']),3))-F5(jj)*abs(eval(['DL' Demand(jj,:) '_Pos(:,:,3)'])))./(F2(jj)*abs(eval(['LL' Demand(jj,:) '_Pos(:,:,ii)'])));
end
% Find lane position that creates lowest rating 
[RFOpLaneP, RFOpP_indL] = min(RFOp_allP,[],3);
% Find locations with minimum 
[RFOpLocP, RFOpP_ind] = min(RFOpLaneP,[],2);
% Find girder with minimum
[RFOpGirdP, RFOpP_ind2] = min(RFOpLocP);
% Organize Indices into vector (Girder, Location, Max or Min stress)
ind(1,:) = [RFOpP_ind2 RFOpP_ind(RFOpP_ind2) RFOpP_indL(RFOpP_ind(RFOpP_ind2))];
end

if Parameters.Spans~=1 && ~isempty(fIOp_neg{jj})
    for ii=1:size(LLStress_Neg,3)
        % Compute rating factors for all girders and all negative moment regions
        RFOp_allN(:,:,ii) = (F1(jj)*eval(fIOp_neg{jj}) - F4(jj)*abs(sum(eval(['DL' Demand(1,:) '_Neg(:,:,1:2)']),3))-F5(jj)*abs(eval(['DL' Demand(1,:) '_Neg(:,:,3)'])))./(F2(jj)*abs(eval(['LL' Demand(1,:) '_Neg(:,:,ii)'])));
    end
    % Find lane position that creates lowest rating 
    [RFOpLaneN, RFOpN_indL] = min(RFOp_allN,[],3);
    % Find locations with minimum 
    [RFOpLocN, RFOpN_ind] = min(RFOpLaneN,[],2);
    % Find girder with minimum
    [RFOpGirdN, RFOpN_ind2] = min(RFOpLocN);
    % Organize Indices into vector (Girder, Location, Lane Position)
    ind(2,:) = [RFOpN_ind2 RFOpN_ind(RFOpN_ind2) RFOpN_indL(RFOpN_ind(RFOpN_ind2))];


    % Find overall minimum rating (positive or negative moment region)
    [RFOp, ind3] = min([RFOpGirdP,RFOpGirdN]);
    % Indexed location of minimum rating factor
    RFOp_ind = [ind3 ind(ind3,:)]; %Positive or Neg. region, Girder, Location along bridge, Lane Position
else
    try
    % If only a single span--only a positive moment region
    RFOp = RFOpGirdP;
    % Indexed location of minimum rating factor
    RFOp_ind = [1 ind(1,:)];
    catch
    end
end

%% Store Rating Factors in Parameters

% Minimum Factors
try
    Parameters.Rating.(State(jj,:)).RFOp = RFOp;
    Parameters.Rating.(State(jj,:)).LocationOp = RFOp_ind;
catch
end
try
    Parameters.Rating.(State(jj,:)).RFInv = RFInv;
    Parameters.Rating.(State(jj,:)).LocationInv = RFInv_ind;
catch
end

% All Factors
% Reorder factors to be coherant with bridge geometry
% Operating Factors
if exist('RFOp_allP','var') 
    Parameters.Rating.(State(jj,:)).RatingFactors_Op(:,1:2:2*Parameters.Spans-1,:)  = RFOp_allP;
end

if exist('RFOp_allN','var')    
    Parameters.Rating.(State(jj,:)).RatingFactors_Op(:,2:2:end-1,:) = RFOp_allN;
end
%Inventory Ratings
if exist('RFInv_allP','var') 
Parameters.Rating.(State(jj,:)).RatingFactors_Inv(:,1:2:2*Parameters.Spans-1,:)  = RFInv_allP;
end
if exist('RFInv_allN','var')    
    Parameters.Rating.(State(jj,:)).RatingFactors_Inv(:,2:2:end-1,:) = RFInv_allN;
end
end

% Save Stresses and Moments
Parameters.Rating.DeadLoadStresses(:,1:2:2*Parameters.Spans-1,:) = DLStress_Pos;
Parameters.Rating.LiveLoadStresses(:,1:2:2*Parameters.Spans-1,:) = LLStress_Pos;
Parameters.Rating.DeadLoadMoments(:,1:2:2*Parameters.Spans-1,:) = DLMoment_Pos;
Parameters.Rating.LiveLoadMoments(:,1:2:2*Parameters.Spans-1,:) = LLMoment_Pos;
if exist('DLStress_Neg','var')    
    Parameters.Rating.DeadLoadStresses(:,2:2:end-1,:) = DLStress_Neg;
    Parameters.Rating.LiveLoadStresses(:,2:2:end-1,:) = LLStress_Neg;
    Parameters.Rating.DeadLoadMoments(:,2:2:end-1,:) = DLMoment_Neg;
    Parameters.Rating.LiveLoadMoments(:,2:2:end-1,:) = LLMoment_Neg;
end

end %RatingFactors()