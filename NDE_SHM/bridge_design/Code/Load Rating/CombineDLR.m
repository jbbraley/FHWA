function [ Arg ] = CombineDLR( DLR, Parameters, Arg )

ws_pad = 3 - size(DLR.ForcePos, 2);
DLR.ForcePos = padarray(DLR.ForcePos, [0 ws_pad], 'post');  
DLStressP = max(abs(DLR.StrPos(:,:,:,1:2)),[],4);
DLMom1P = DLR.ForcePos(:,:,:,4);
DLMom2P = DLR.ForcePos(:,:,:,6);
DLAxialP = DLR.ForcePos(:,:,:,1);
DLCompMomP([1 Parameters.NumGirder],:,:) = DLR.ForcePos([1 end],:,:,4)-DLR.ForcePos([1 end],:,:,1)*((Parameters.Beam.Ext.d+Parameters.Deck.t)/2+Parameters.Deck.Offset);
DLCompMomP(2:Parameters.NumGirder-1,:,:) = DLR.ForcePos(2:end-1,:,:,4)-DLR.ForcePos(2:end-1,:,:,1)*((Parameters.Beam.Int.d+Parameters.Deck.t)/2+Parameters.Deck.Offset);

if Parameters.Spans~=1
    if ~isfield(Parameters.Beam.Int.CoverPlate, 'd')
        Parameters.Beam.CoverPlate.d = Parameters.Beam.d;
    end
    ws_pad = 3 - size(DLR.ForceNeg, 2);
    DLR.ForceNeg = padarray(DLR.ForceNeg, [0 ws_pad], 'post'); 
    DLStressN = max(abs(DLR.StrNeg(:,:,:,1:2)),[],4);
    DLMom1N = DLR.ForceNeg(:,:,:,4);
    DLMom2N = DLR.ForceNeg(:,:,:,6);
    DLAxialN = DLR.ForceNeg(:,:,:,1);
    DLCompMomN([1 Parameters.NumGirder],:,:) = DLR.ForceNeg([1 end],:,:,4)-DLR.ForceNeg([1 end],:,:,1)*((Parameters.Beam.Ext.d+Parameters.Deck.t)/2+Parameters.Deck.Offset);
    DLCompMomN(2:Parameters.NumGirder-1,:,:) = DLR.ForceNeg(2:end-1,:,:,4)-DLR.ForceNeg(2:end-1,:,:,1)*((Parameters.Beam.Int.d+Parameters.Deck.t)/2+Parameters.Deck.Offset);

end

% Reorganize arrays with dead load type as last index
DLMoment1_Pos = permute(DLMom1P,[1 3 2]);
DLMoment2_Pos = permute(DLMom2P,[1 3 2]);
DLAxial_Pos = permute(DLAxialP,[1 3 2]);

Arg.Int.FEM.DeadLoad.Stress_Pos = Force2Stress(DLMoment1_Pos(2:end-1,:,:),DLMoment2_Pos(2:end-1,:,:), DLAxial_Pos(2:end-1,:,:), Parameters.Beam.Int);
Arg.Ext.FEM.DeadLoad.Stress_Pos = Force2Stress(DLMoment1_Pos([1 end],:,:),DLMoment2_Pos([1 end],:,:), DLAxial_Pos([1 end],:,:), Parameters.Beam.Ext);
Arg.Int.FEM.DeadLoad.Moment_Pos = permute(DLCompMomP(2:end-1,:,:),[1 3 2]);
Arg.Ext.FEM.DeadLoad.Moment_Pos = permute(DLCompMomP([1 end],:,:),[1 3 2]);
if Parameters.Spans~=1
    DLMoment1_Neg = permute(DLMom1N,[1 3 2]);
    DLMoment2_Neg = permute(DLMom2N,[1 3 2]);
    DLAxial_Neg = permute(DLAxialN,[1 3 2]);
    
    if Parameters.Beam.Int.CoverPlate.Length~=0
        Arg.Int.FEM.DeadLoad.Stress_Neg = Force2Stress(DLMoment1_Neg(2:end-1,:,:),DLMoment2_Neg(2:end-1,:,:), DLAxial_Neg(2:end-1,:,:), Parameters.Beam.Int.CoverPlate);
        Arg.Ext.FEM.DeadLoad.Stress_Neg = Force2Stress(DLMoment1_Neg([1 end],:,:),DLMoment2_Neg([1 end],:,:), DLAxial_Neg([1 end],:,:), Parameters.Beam.Ext.CoverPlate);
    else
        Arg.Int.FEM.DeadLoad.Stress_Neg = Force2Stress(DLMoment1_Neg(2:end-1,:,:),DLMoment2_Neg(2:end-1,:,:), DLAxial_Neg(2:end-1,:,:), Parameters.Beam.Int);
        Arg.Ext.FEM.DeadLoad.Stress_Neg = Force2Stress(DLMoment1_Neg([1 end],:,:),DLMoment2_Neg([1 end],:,:), DLAxial_Neg([1 end],:,:), Parameters.Beam.Ext);
    end
    Arg.Int.FEM.DeadLoad.Moment_Neg = permute(DLCompMomN(2:end-1,:,:),[1 3 2]);
    Arg.Ext.FEM.DeadLoad.Moment_Neg = permute(DLCompMomN([1 end],:,:),[1 3 2]);
end
end

