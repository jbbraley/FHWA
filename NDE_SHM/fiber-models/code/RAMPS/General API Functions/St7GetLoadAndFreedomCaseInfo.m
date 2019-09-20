function Parameters = FEMRatingFactors(Parameters,Options,ModelPath,ModelName)
% Get Stresses
if strcmp(Parameters.Rating.Code, 'ASD')
    fIOp = '0.55*Parameters.Beam.Fy';
    fIInv = '0.75*Parameters.Beam.Fy';
    F1 = 1;
    F2 = 1;
    F3 = 1;
    
    State = 'St1';
    Demand = 'Stress';
elseif strcmp(Parameters.Rating.Code, 'LRFD')
    if strcmp(Parameters.Beam.Type,'Rolled') || Parameters.Beam.Comp==1
        fIOp_pos = ['Parameters.Beam.Fy    '; 'Parameters.Beam.Mn_pos'];
        fIOp_neg = ['Parameters.Beam.Fy    '; 'Parameters.Beam.Mn_neg'];
        fIInv_pos = ['Parameters.Beam.Fy    '; 'Parameters.Beam.Mn_pos'];
        fIInv_neg = ['Parameters.Beam.Fy    '; 'Parameters.Beam.Mn_neg'];

        Demand = ['Stress'; 'Moment'];
    else
        fIOp_pos = ['Parameters.Beam.Fy'; 'Parameters.Beam.Fy'];
        fIOp_neg = ['Parameters.Beam.Fy'; 'Parameters.Beam.Fy'];
        fIInv_pos = ['Parameters.Beam.Fy'; 'Parameters.Beam.Fy'];
        fIInv_neg = ['Parameters.Beam.Fy'; 'Parameters.Beam.Fy'];
        
        Demand = ['Stress'; 'Stress'];
    end
    F1 = [0.95 1.0];
    F2 = [1.0 1.35];
    F3 = [1.30 1.75];
    F4 = [1.0 1.25];
    
    State = ['Sv2';'St1'];    
end

%% Dead Load
% Get results from root
DLR = Parameters.Rating.DLR;
DLStressP = max(abs(DLR.StrPos(:,:,:,1:2)),[],4);
DLMomP = DLR.ForcePos(:,:,:,4)-DLR.ForcePos(:,:,:,5)*(Parameters.Beam.d+Parameters.Deck.t)/2;
if Parameters.Spans~=1
DLStressN = max(abs(DLR.StrNeg(:,:,:,1:2)),[],4);
DLMomN = DLR.ForceNeg(:,:,:,4)-DLR.ForceNeg(:,:,:,5)*(Parameters.Beam.d+Parameters.Deck.t)/2;
end

% Add deck dead and superimposed dead loads and non-structural mass load for each girder
% Sum along the 2nd dimension (index of deadload type)
DLStress_Pos = permute(sum(DLStressP, 2),[1 3 2]);
DLMoment_Pos = permute(sum(DLMomP,2),[1 3 2]);
if Parameters.Spans~=1
    DLStress_Neg = permute(sum(DLStressN, 2),[1 3 2]);
    DLMoment_Neg = permute(sum(DLMomN,2),[1 3 2]);
end

%% Live Load
% Get results from root
LLR = Parameters.Rating.LLR;
[MaxLLStressP, IndStressP] = max(abs(LLR.StrPos(:,:,:,:,:,1:2)),[],6);
LLStressP = MaxLLStressP.*(IndStressP*2-3);
LLMomP = LLR.ForcePos(:,:,:,:,:,4)-LLR.ForcePos(:,:,:,:,:,5)*(Parameters.Beam.d+Parameters.Deck.t)/2;
if Parameters.Spans~=1
    [MaxLLStressN, IndStressN]  = max(abs(LLR.StrNeg(:,:,:,:,:,1:2)),[],6);
    LLStressN = MaxLLStressN.*(IndStressN*2-3);
    
    LLMomN = LLR.ForceNeg(:,:,:,:,:,4)-LLR.ForceNeg(:,:,:,:,:,5)*(Parameters.Beam.d+Parameters.Deck.t)/2;
end

if strcmp(Parameters.Rating.Code, 'LRFD')
    vect = 1:Parameters.Spans;
    vect = padarray(vect, [0,Parameters.Spans-1],'pre');
    LaneComb = unique(nchoosek(vect,Parameters.Spans),'rows');

    LaneLoadP = LLStressP(:,:,:,end-Parameters.Spans+1:end,:);
    LaneLoadMomP = LLMomP(:,:,:,end-Parameters.Spans+1:end,:);
    if Parameters.Spans~=1
        LaneLoadN = LLStressN(:,:,:,end-Parameters.Spans+1:end,:);
        LaneLoadMomN = LLMomN(:,:,:,end-Parameters.Spans+1:end,:);
    end
    
    LaneLoadStressP = [];
    LaneLoadMomentP = [];
    TruckLaneStressP = [];
    TruckLaneMomentP = [];
    if Parameters.Spans~=1
        LaneLoadStressN = [];
        LaneLoadMomentN = [];
        TruckLaneStressN = [];
        TruckLaneMomentN = [];
    end
    
    for k = 1:size(LaneComb, 1)
        spans = nonzeros(LaneComb(k,:));   

        % Sum stress and Moment for different spans corresponding to lane combo at each girder at each poi
        LaneLoadStressP = cat(5,LaneLoadStressP,permute(sum(LaneLoadP(:,:,:,spans,:),4),[1 2 3 5 4]));
        LaneLoadMomentP = cat(5,LaneLoadMomentP,permute(sum(LaneLoadMomP(:,:,:,spans,:),4),[1 2 3 5 4]));
        if Parameters.Spans~=1
            LaneLoadStressN = cat(5,LaneLoadStressN,permute(sum(LaneLoadN(:,:,:,spans,:),4),[1 2 3 5 4]));
            LaneLoadMomentN = cat(5,LaneLoadMomentN,permute(sum(LaneLoadMomN(:,:,:,spans,:),4),[1 2 3 5 4]));
        end
        % Add truck Loads to Lane Load Combos (any truck load + plus any lane load
        % per lane)
        for j=1:size(LLStressP,4)-Parameters.Spans
            TruckLaneStressP = cat(5,TruckLaneStressP,LaneLoadStressP(:,:,:,:,k)+permute(LLStressP(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
            TruckLaneMomentP = cat(5,TruckLaneMomentP,LaneLoadMomentP(:,:,:,:,k)+permute(LLMomP(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
            if Parameters.Spans~=1
                TruckLaneStressN = cat(5,TruckLaneStressN,LaneLoadStressN(:,:,:,:,k)+permute(LLStressN(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
                TruckLaneMomentN = cat(5,TruckLaneMomentN,LaneLoadMomentN(:,:,:,:,k)+permute(LLMomN(:,:,:,j,:),[1 2 3 5 4])*max(Parameters.Design.IMF));
            end
        end
    end
else
    TruckLaneStressP = permute(LLStressP,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
    TruckLaneMomentP = permute(LLMomP,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
    if Parameters.Spans~=1
        TruckLaneStressN = permute(LLStressN,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
        TruckLaneMomentN = permute(LLMomN,[1 2 3 5 4])*(1+max(Parameters.Design.Im));
    end
end

vect = 1:Parameters.NumLane;
vect = padarray(vect, [0,Parameters.NumLane-1],'pre');
MultiPresComb = unique(nchoosek(vect,Parameters.NumLane),'rows');
LLStress_TotP = [];
LLMoment_TotP = [];
if Parameters.Spans~=1
    LLStress_TotN = [];
    LLMoment_TotN = [];
end
for ii=1:size(MultiPresComb,1)
    lanes = nonzeros(MultiPresComb(ii,:));
    
    if strcmp(Parameters.Rating.Code, 'ASD')
        if length(lanes) <= 2
            redfact = 1;
        elseif length(lanes) == 3
            redfact = 0.9;
        else
            redfact = 0.75;
        end
    elseif strcmp(Parameters.Rating.Code, 'LRFD')
        if length(lanes) == 1
            redfact = 1.2;
        elseif length(lanes) == 2
            redfact = 1;
        elseif length(lanes) == 3
            redfact = 0.85;
        else
            redfact = 0.65;
        end
    end
    
    % Sum stress for different combinations of having multiple lanes loaded
    LLStress_TotP = cat(5,LLStress_TotP,permute(sum(TruckLaneStressP(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
    LLMoment_TotP = cat(5,LLMoment_TotP,permute(sum(TruckLaneMomentP(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
    if Parameters.Spans~=1
        LLStress_TotN = cat(5,LLStress_TotN,permute(sum(TruckLaneStressN(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
        LLMoment_TotN = cat(5,LLMoment_TotN,permute(sum(TruckLaneMomentN(:,lanes,:,:,:),2),[1 3 4 5 2])*redfact);
    end
end
    


LLStress_Pos = permute(max(max(LLStress_TotP,[],5),[],4),[2 3 1]);
LLMoment_Pos = permute(min(min(LLMoment_TotP,[],5),[],4),[2 3 1]);
if Parameters.Spans~=1
    LLStress_Neg = permute(max(max(abs(LLStress_TotN),[],5),[],4),[2 3 1]);
    LLMoment_Neg = permute(max(max(abs(LLMoment_TotN),[],5),[],4),[2 3 1]);
end

%% Compute Rating Factors
% Clear any previously stored rating data
for jj = 1:length(F2)
    
    
%% Service Rating
%Inventory Rating Factor
% Compute rating factors for all girders and all positve moment regions for
% all three lane positions
for ii=1:size(LLStress_Pos,3)
    RFInv_allP(:,:,ii) = (F1(jj)*eval(fIInv_pos(jj,:)) - F4(jj)*abs(eval(['DL' Demand(jj,:) '_Pos'])))./(F3(jj)*abs(eval(['LL' Demand(jj,:) '_Pos(:,:,ii)'])));
end
% Find lane position that creates lowest rating 
[RFInvLaneP, RFInvP_indL] = min(RFInv_allP,[],3);
% Find locations with minimum 
[RFInvLocP, RFInvP_ind] = min(RFInvLaneP,[],2);
% Find girder with minimum
[RFInvGirdP, RFInvP_ind2] = min(RFInvLocP);
% Organize Indices into vector (Girder, Location, Max or Min stress)
ind(1,:) = [RFInvP_ind2 RFInvP_ind(RFInvP_ind2) RFInvP_indL(RFInvP_ind(RFInvP_ind2))];

% Compute rating factors for all girders and all negative moment regions
if Parameters.Spans~=1
    for ii=1:size(LLStress_Neg,3)
        RFInv_allN(:,:,ii) = (F1(jj)*eval(fIInv_neg(jj,:)) - F4(jj)*eval(['DL' Demand(jj,:) '_Neg']))./(F3(jj)*eval(['LL' Demand(jj,:) '_Neg(:,:,ii)']));
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
    % If only a single span--only a positive moment region
    RFInv = RFInvGirdP;
    % Indexed location of minimum rating factor
    RFInv_ind = [1 ind(1,:)]; %Positive moment region, Girder, Location along bridge, max or min stress
end

%Operating Rating Factor
for ii=1:size(LLStress_Pos,3)
    % Compute rating factors for all girders and all positve moment regions and
    % all 3 lane positions
    RFOp_allP(:,:,ii) = (F1(jj)*eval(fIOp_pos(jj,:)) - F4(jj)*abs(eval(['DL' Demand(jj,:) '_Pos'])))./(F2(jj)*abs(eval(['LL' Demand(jj,:) '_Pos(:,:,ii)'])));
end
% Find lane position that creates lowest rating 
[RFOpLaneP, RFOpP_indL] = min(RFOp_allP,[],3);
% Find locations with minimum 
[RFOpLocP, RFOpP_ind] = min(RFOpLaneP,[],2);
% Find girder with minimum
[RFOpGirdP, RFOpP_ind2] = min(RFOpLocP);
% Organize Indices into vector (Girder, Location, Max or Min stress)
ind(1,:) = [RFOpP_ind2 RFOpP_ind(RFOpP_ind2) RFOpP_indL(RFOpP_ind(RFOpP_ind2))];

if Parameters.Spans~=1
    for ii=1:size(LLStress_Neg,3)
        % Compute rating factors for all girders and all negative moment regions
        RFOp_allN(:,:,ii) = (F1(jj)*eval(fIOp_neg(jj,:)) - F4(jj)*eval(['DL' Demand(jj,:) '_Neg']))./(F2(jj)*eval(['LL' Demand(jj,:) '_Neg(:,:,ii)']));
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
    % If only a single span--only a positive moment region
    RFOp = RFOpGirdP;
    % Indexed location of minimum rating factor
    RFOp_ind = [1 ind(1,:)];
end

%% Store Rating Factors in Parameters

% Minimum Factors
Parameters.Rating.(State(jj,:)).RFOp = RFOp;
Parameters.Rating.(State(jj,:)).RFInv = RFInv;
Parameters.Rating.(State(jj,:)).LocationOp = RFOp_ind;
Parameters.Rating.(State(jj,:)).LocationInv = RFInv_ind;

% All Factors
% Reorder factors to be coherant with bridge geometry
% Operating Factors
Parameters.Rating.(State(jj,:)).RatingFactors_Op(:,1:2:2*Parameters.Spans-1,:)  = RFOp_allP;

if exist('RFOp_allN','var')    
    Parameters.Rating.(State(jj,:)).RatingFactors_Op(:,2:2:end-1,:) = RFOp_allN;
end
%Inventory Ratings
Parameters.Rating.(State(jj,:)).RatingFactors_Inv(:,1:2:2*Parameters.Spans-1,:)  = RFInv_allP;
if exist('RFInv_allN','var')    
    Parameters.Rating.(State(jj,:)).RatingFactors_Inv(:,2:2:end-1,:) = RFInv_allN;
end
end

% Save Stresses and Moments
Parameters.Rating.DeadLoadStresses(:,1:2:2*Parameters.Spans-1) = DLStress_Pos;
Parameters.Rating.LiveLoadStresses(:,1:2:2*Parameters.Spans-1,:) = LLStress_Pos;
Parameters.Rating.DeadLoadMoments(:,1:2:2*Parameters.Spans-1) = DLMoment_Pos;
Parameters.Rating.LiveLoadMoments(:,1:2:2*Parameters.Spans-1,:) = LLMoment_Pos;
if exist('DLStress_Neg','var')    
    Parameters.Rating.DeadLoadStresses(:,2:2:end-1) = DLStress_Neg;
    Parameters.Rating.LiveLoadStresses(:,2:2:end-1,:) = LLStress_Neg;
    Parameters.Rating.DeadLoadMoments(:,2:2:end-1) = DLMoment_Neg;
    Parameters.Rating.LiveLoadMoments(:,2:2:end-1,:) = LLMoment_Neg;
end

end %RatingFactors()