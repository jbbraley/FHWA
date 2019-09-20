function ArgOut = GetRatingFactor(ArgIn1,ArgIn2,Parameters,Section)
% Parameters.Rating.(Code).SL = GetRatingFactor(Parameters.Beam.Int,Parameters.Demands.Int, Parameters, 'Interior');
if strcmp(Parameters.Rating.Code, 'ASD')
    fIInv = 0.55*Parameters.Beam.Fy; % psi - or 0.55fy
    fIOp = 0.75*Parameters.Beam.Fy; % psi - or 0.75fy
    
    % Positive
    maxDLnc = max(ArgIn2.DeadLoad.MDL_pos)/ArgIn1.S.SBnc;
    
    if Parameters.Deck.CompositeDesign == 1
        maxSDL = max(ArgIn2.DeadLoad.MSDL_pos)/ArgIn1.S.SBlt;
        maxLL = max(max(ArgIn2.LiveLoad.MLL_pos))/ArgIn1.S.SBst;
    else
        maxSDLnc = max(ArgIn2.DeadLoad.MSDL_pos)/ArgIn1.S.SBnc;
        maxLLnc = max(ArgIn2.LiveLoad.MLL_pos)/ArgIn1.S.SBnc;
    end
    
    % Negative
    if Parameters.Spans > 1
        if ArgIn1.CoverPlate.Length ~= 0
            minDLnc = max(abs(ArgIn2.DeadLoad.MDL_neg))/ArgIn1.CoverPlate.S.STnc;
            minSDLnc = max(abs(ArgIn2.DeadLoad.MSDL_neg))/ArgIn1.CoverPlate.S.STnc;
            minLLnc = max(max(abs(ArgIn2.LiveLoad.MLL_neg)))/ArgIn1.CoverPlate.S.STnc;
        else
            minDLnc = max(abs(ArgIn2.DeadLoad.MDL_neg))/ArgIn1.S.STnc;
            minSDLnc = max(abs(ArgIn2.DeadLoad.MSDL_neg))/ArgIn1.S.STnc;
            minLLnc = max(max(abs(ArgIn2.LiveLoad.MLL_neg)))/ArgIn1.S.STnc;
        end
    end
    
    % Positive
    if Parameters.Deck.CompositeDesign == 1
        ArgOut.St1.Op_pos = (fIOp - maxDLnc - maxSDL)/maxLL;
        ArgOut.St1.Inv_pos = (fIInv - maxDLnc - maxSDL)/maxLL;
    else
        ArgOut.St1.Op_pos = (fIOp - maxDLnc - maxSDLnc)/maxLLnc;
        ArgOut.St1.Inv_pos = (fIInv - maxDLnc - maxSDLnc)/maxLLnc;
    end
    
    % Negative
    if Parameters.Spans > 1
        ArgOut.St1.Op_neg = (fIOp - minDLnc - minSDLnc)/minLLnc;
        ArgOut.St1.Inv_neg = (fIInv - minDLnc - minSDLnc)/minLLnc;
    else
        ArgOut.St1.Op_neg = [];
        ArgOut.St1.Inv_neg = [];
    end
    ArgOut.St1.Inv = [ArgOut.St1.Inv_pos, ArgOut.St1.Inv_neg];
    ArgOut.St1.Op = [ArgOut.St1.Op_pos, ArgOut.St1.Op_neg];
    

elseif strcmp(Parameters.Rating.Code, 'LRFD')  
   
    % Distribution Factor
    DF = Parameters.Design.DF.(['DF' (Section)]);
    
    % Positive
    % get contributional stresses in bottom flange
    ArgOut.ftDL_pos = max(abs(ArgIn2.DeadLoad.MDL_pos)/ArgIn1.S.SBnc+abs(ArgIn2.DeadLoad.MSDL_pos)/ArgIn1.S.SBlt);
    ArgOut.ftLL_pos = max(abs(ArgIn2.LiveLoad.MLL_pos)*max(DF))/ArgIn1.S.SBst;
    %Strength Limit State I
    ArgOut.St1.RFOp_pos = min((ArgIn1.Mn_pos-1.25*(ArgIn2.DeadLoad.MDL_pos+ArgIn2.DeadLoad.MSDL_pos))./(1.35*ArgIn2.LiveLoad.MLL_pos*max(DF)));
    ArgOut.St1.RFInv_pos = min((ArgIn1.Mn_pos-1.25*(ArgIn2.DeadLoad.MDL_pos+ArgIn2.DeadLoad.MSDL_pos))./(1.75*ArgIn2.LiveLoad.MLL_pos*max(DF)));
    %Service Limit State II
    ArgOut.Sv2.RFOp_pos = (0.95*ArgIn1.Fn_pos-1*(ArgOut.ftDL_pos))/(1.0*ArgOut.ftLL_pos);
    ArgOut.Sv2.RFInv_pos = (0.95*ArgIn1.Fn_pos-1*(ArgOut.ftDL_pos))/(1.3*ArgOut.ftLL_pos);
    
    % Negative
    if Parameters.Spans > 1
        if ArgIn1.CoverPlate.Length > 0
            % get contributional stresses in bottom flange
            ArgOut.fcDL_neg = max(abs(ArgIn2.DeadLoad.MDL_neg)/ArgIn1.CoverPlate.S.SBnc+abs(ArgIn2.DeadLoad.MSDL_neg)/ArgIn1.CoverPlate.S.SBnc);
            ArgOut.fcLL_neg = max(abs(ArgIn2.LiveLoad.MLL_neg*max(DF)))/ArgIn1.CoverPlate.S.SBnc;
            %Strength Limit State I
            ArgOut.St1.RFOp_neg = (ArgIn1.Fn_neg-1.25*max(abs(ArgOut.fcDL_neg)))/(1.35*max(abs(ArgOut.fcLL_neg)));
            ArgOut.St1.RFInv_neg = (ArgIn1.Fn_neg-1.25*max(abs(ArgOut.fcDL_neg)))/(1.75*max(abs(ArgOut.fcLL_neg)));
            %Service Limit State II
            ArgOut.Sv2.RFOp_neg = (0.95*ArgIn1.Fn_neg-1*ArgOut.fcDL_neg)/(1.0*ArgOut.fcLL_neg);
            ArgOut.Sv2.RFInv_neg = (0.95*ArgIn1.Fn_neg-1*ArgOut.fcDL_neg)/(1.3*ArgOut.fcLL_neg);
        else
            % get contributional stresses in bottom flange
            ArgOut.fcDL_neg = max(abs(ArgIn2.DeadLoad.MDL_neg)/ArgIn1.S.SBnc+abs(ArgIn2.DeadLoad.MSDL_neg)/ArgIn1.S.SBnc);
            ArgOut.fcLL_neg = max(abs(ArgIn2.LiveLoad.MLL_neg*max(DF)))/ArgIn1.S.SBnc;
            %Strength Limit State I
            ArgOut.St1.RFOp_neg = (ArgIn1.Fn_neg-1.25*max(abs(ArgOut.fcDL_neg)))/(1.35*max(abs(ArgOut.fcLL_neg)));
            ArgOut.St1.RFInv_neg = (ArgIn1.Fn_neg-1.25*max(abs(ArgOut.fcDL_neg)))/(1.75*max(abs(ArgOut.fcLL_neg)));
            %Service Limit State II
            ArgOut.Sv2.RFOp_neg = (0.95*ArgIn1.Fn_neg-1*ArgOut.fcDL_neg)/(1.0*ArgOut.fcLL_neg);
            ArgOut.Sv2.RFInv_neg = (0.95*ArgIn1.Fn_neg-1*ArgOut.fcDL_neg)/(1.3*ArgOut.fcLL_neg);
        end
    else
        ArgOut.St1.RFOp_neg = [];
        ArgOut.St1.RFInv_neg = [];
        ArgOut.Sv2.RFOp_neg = [];
        ArgOut.Sv2.RFInv_neg = [];
    end
    %Single Line rating facotrs [Inv_pos, Op_pos, Inv_neg, Op_neg]
    ArgOut.St1.Inv = [ArgOut.St1.RFInv_pos, ArgOut.St1.RFInv_neg];
    ArgOut.St1.Op = [ArgOut.St1.RFOp_pos, ArgOut.St1.RFOp_neg];
    ArgOut.Sv2.Inv = [ArgOut.Sv2.RFInv_pos,ArgOut.Sv2.RFInv_neg];
    ArgOut.Sv2.Op = [ArgOut.Sv2.RFOp_pos, ArgOut.Sv2.RFOp_neg];
end

    
end