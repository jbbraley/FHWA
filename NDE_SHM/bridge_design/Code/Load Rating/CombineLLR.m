function [ Arg ] = CombineLLR( LLR , Parameters, Arg )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Code = Parameters.Rating.Code;

LLMom1P = LLR.ForcePos(:,:,:,:,:,4);
LLMom2P = LLR.ForcePos(:,:,:,:,:,6);
LLAxialP = LLR.ForcePos(:,:,:,:,:,1);
LLCompMomP(:,:,[1 Parameters.NumGirder],:,:) = LLR.ForcePos(:,:,[1 end],:,:,4)-LLR.ForcePos(:,:,[1 end],:,:,1)*((Parameters.Beam.Ext.d+Parameters.Deck.t)/2+Parameters.Deck.Offset);
LLCompMomP(:,:,2:Parameters.NumGirder-1,:,:) = LLR.ForcePos(:,:,2:end-1,:,:,4)-LLR.ForcePos(:,:,2:end-1,:,:,1)*((Parameters.Beam.Int.d+Parameters.Deck.t)/2+Parameters.Deck.Offset);

LLCompMomN = zeros(1,5,11,10,2);

if Parameters.Spans~=1
    LLMom1N = LLR.ForceNeg(:,:,:,:,:,4);
    LLMom2N = LLR.ForceNeg(:,:,:,:,:,6);
    LLAxialN = LLR.ForceNeg(:,:,:,:,:,1);
    LLCompMomN = LLR.ForceNeg(:,:,:,:,:,4)-LLR.ForceNeg(:,:,:,:,:,1)*((Parameters.Beam.Int.d+Parameters.Deck.t)/2+Parameters.Deck.Offset);
%     LLCompMomN(:,:,[1 Parameters.NumGirder],:,:) = LLR.ForceNeg(:,:,[1 end],:,:,4)-LLR.ForceNeg(:,:,[1 end],:,:,1)*((Parameters.Beam.Ext.d+Parameters.Deck.t)/2+Parameters.Deck.Offset);
%     LLCompMomN(:,:,2:Parameters.NumGirder-1,:,:) = LLR.ForceNeg(:,:,2:end-1,:,:,4)-LLR.ForceNeg(:,:,2:end-1,:,:,1)*((Parameters.Beam.Int.d+Parameters.Deck.t)/2+Parameters.Deck.Offset);
end

if strcmp(Code, 'LRFD')
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
            TruckLaneMoment1P = cat(5,TruckLaneMoment1P,LaneLoadMoment1P(:,:,:,:,k)+permute(LLMom1P(:,:,:,j,:),[1 2 3 5 4]));
            TruckLaneMoment2P = cat(5,TruckLaneMoment2P,LaneLoadMoment2P(:,:,:,:,k)+permute(LLMom2P(:,:,:,j,:),[1 2 3 5 4]));
            TruckLaneAxialP = cat(5,TruckLaneAxialP,LaneLoadAxialP(:,:,:,:,k)+permute(LLAxialP(:,:,:,j,:),[1 2 3 5 4]));
            TruckLaneCompMomentP = cat(5,TruckLaneCompMomentP,LaneLoadCompMomentP(:,:,:,:,k)+permute(LLCompMomP(:,:,:,j,:),[1 2 3 5 4]));
            if Parameters.Spans~=1
                TruckLaneMoment1N = cat(5,TruckLaneMoment1N,LaneLoadMoment1N(:,:,:,:,k)+permute(LLMom1N(:,:,:,j,:),[1 2 3 5 4]));
                TruckLaneMoment2N = cat(5,TruckLaneMoment2N,LaneLoadMoment2N(:,:,:,:,k)+permute(LLMom2N(:,:,:,j,:),[1 2 3 5 4]));
                TruckLaneAxialN = cat(5,TruckLaneAxialN,LaneLoadAxialN(:,:,:,:,k)+permute(LLAxialN(:,:,:,j,:),[1 2 3 5 4]));
                TruckLaneCompMomentN = cat(5,TruckLaneCompMomentN,LaneLoadMomentN(:,:,:,:,k)+permute(LLCompMomN(:,:,:,j,:),[1 2 3 5 4]));
            end
        end
    end
else
    TruckLaneMoment1P = permute(LLMom1P,[1 2 3 5 4]);
    TruckLaneMoment2P = permute(LLMom2P,[1 2 3 5 4]);
    TruckLaneAxialP = permute(LLAxialP,[1 2 3 5 4]);
    TruckLaneCompMomentP = permute(LLCompMomP,[1 2 3 5 4]);
    if Parameters.Spans~=1
        TruckLaneMoment1N = permute(LLMom1N,[1 2 3 5 4]);
        TruckLaneMoment2N = permute(LLMom2N,[1 2 3 5 4]);
        TruckLaneAxialN = permute(LLAxialN,[1 2 3 5 4]);
        TruckLaneCompMomentN = permute(LLCompMomN,[1 2 3 5 4]);
    end
end

vect = 1:Parameters.Rating.(Code).NumLane;
vect = padarray(vect, [0,Parameters.Rating.(Code).NumLane-1],'pre');
MultiPresComb = unique(nchoosek(vect,Parameters.Rating.(Code).NumLane),'rows');
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
        redfact = Parameters.Rating.(Code).MulPres(NumRatingLanes);
        
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
    
CompStress_PosInt = Force2Stress(LLMoment1_TotP(:,2:end-1,:,:,:), LLMoment2_TotP(:,2:end-1,:,:,:), LLAxial_TotP(:,2:end-1,:,:,:), Parameters.Beam.Int);
CompStress_PosExt = Force2Stress(LLMoment1_TotP(:,[1 end],:,:,:), LLMoment2_TotP(:,[1 end],:,:,:), LLAxial_TotP(:,[1 end],:,:,:), Parameters.Beam.Ext);

Arg.Int.FEM.LiveLoad.Stress_Pos = permute(max(max(CompStress_PosInt,[],5),[],4),[2 3 1]);
Arg.Int.FEM.LiveLoad.Moment_Pos = permute(max(max(LLCompMoment_TotP(:,2:end-1,:,:,:),[],5),[],4),[2 3 1]);
Arg.Ext.FEM.LiveLoad.Stress_Pos = permute(max(max(CompStress_PosExt,[],5),[],4),[2 3 1]);
Arg.Ext.FEM.LiveLoad.Moment_Pos = permute(max(max(LLCompMoment_TotP(:,[1 end],:,:,:),[],5),[],4),[2 3 1]);

if Parameters.Spans~=1
    if Parameters.Beam.Int.CoverPlate.Length~=0
        CompStress_NegInt = Force2Stress(LLMoment1_TotN(:,2:end-1,:,:,:), LLMoment2_TotN(:,2:end-1,:,:,:), LLAxial_TotN(:,2:end-1,:,:,:), Parameters.Beam.Int.CoverPlate);
        CompStress_NegExt = Force2Stress(LLMoment1_TotN(:,[1 end],:,:,:), LLMoment2_TotN(:,[1 end],:,:,:), LLAxial_TotN(:,[1 end],:,:,:), Parameters.Beam.Ext.CoverPlate);        
    else
        CompStress_NegInt = Force2Stress(LLMoment1_TotN(:,2:end-1,:,:,:), LLMoment2_TotN(:,2:end-1,:,:,:), LLAxial_TotN(:,2:end-1,:,:,:), Parameters.Beam.Int);
        CompStress_NegExt = Force2Stress(LLMoment1_TotN(:,[1 end],:,:,:), LLMoment2_TotN(:,[1 end],:,:,:), LLAxial_TotN(:,[1 end],:,:,:), Parameters.Beam.Ext);
    end
    Arg.Int.FEM.LiveLoad.Stress_Neg = permute(max(max(abs(CompStress_NegInt),[],5),[],4),[2 3 1]);
    Arg.Int.FEM.LiveLoad.Moment_Neg = permute(max(max(abs(LLCompMoment_TotN(:,2:end-1,:,:,:)),[],5),[],4),[2 3 1]);
    Arg.Ext.FEM.LiveLoad.Stress_Neg = permute(max(max(abs(CompStress_NegExt),[],5),[],4),[2 3 1]);
    Arg.Ext.FEM.LiveLoad.Moment_Neg = permute(max(max(abs(LLCompMoment_TotN(:,[1 end],:,:,:)),[],5),[],4),[2 3 1]);
end
end

