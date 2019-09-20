function Parameters = GetRatingFactor(Parameters)
if strcmp(Parameters.Design.Code, 'ASD')
    fIInv = 0.55*Parameters.Beam.Fy; % psi - or 0.55fy
    fIOp = 0.75*Parameters.Beam.Fy; % psi - or 0.75fy
    
    % Positive
    maxDLnc = max(Parameters.Design.Load.MDL_pos)/Parameters.Beam.SBNc;
    
    if Parameters.Deck.CompositeDesign == 1
        maxSDL = max(Parameters.Design.Load.MSDL_pos)/Parameters.Beam.SBlt;
        maxLL = max(max(Parameters.ASD.MLLIm_pos))/Parameters.Beam.SBst;
    else
        maxSDLnc = max(Parameters.Design.Load.MSDL_pos)/Parameters.Beam.SBNc;
        maxLLnc = max(Parameters.ASD.MLLIm_pos)/Parameters.Beam.SBNc;
    end
    
    % Negative
    if Parameters.Spans > 1
        if Parameters.Beam.CoverPlate.Length ~= 0
            minDLnc = max(abs(Parameters.Design.Load.MDL_neg))/Parameters.Beam.CoverPlate.STNc;
            minSDLnc = max(abs(Parameters.Design.Load.MSDL_neg))/Parameters.Beam.CoverPlate.STNc;
            minLLnc = max(max(abs(Parameters.ASD.MLLIm_neg)))/Parameters.Beam.CoverPlate.STNc;
        else
            minDLnc = max(abs(Parameters.Design.Load.MDL_neg))/Parameters.Beam.STNc;
            minSDLnc = max(abs(Parameters.Design.Load.MSDL_neg))/Parameters.Beam.STNc;
            minLLnc = max(max(abs(Parameters.ASD.MLLIm_neg)))/Parameters.Beam.STNc;
        end
    end
    
    % Positive
    if Parameters.Deck.CompositeDesign == 1
        Parameters.ASD.Rating.Op_pos = (fIOp - maxDLnc - maxSDL)/maxLL;
        Parameters.ASD.Rating.Inv_pos = (fIInv - maxDLnc - maxSDL)/maxLL;
    else
        Parameters.ASD.Rating.Op_pos = (fIOp - maxDLnc - maxSDLnc)/maxLLnc;
        Parameters.ASD.Rating.Inv_pos = (fIInv - maxDLnc - maxSDLnc)/maxLLnc;
    end
    
    % Negative
    if Parameters.Spans > 1
        Parameters.ASD.Rating.Op_neg = (fIOp - minDLnc - minSDLnc)/minLLnc;
        Parameters.ASD.Rating.Inv_neg = (fIInv - minDLnc - minSDLnc)/minLLnc;
    else
        Parameters.ASD.Rating.Op_neg = [];
        Parameters.ASD.Rating.Inv_neg = [];
    end

elseif strcmp(Parameters.Design.Code, 'LRFD')
    
    % get contributional stresses in bottom flange
    Parameters.LRFD.ftDL_pos = max(abs(Parameters.Design.Load.MDL_pos)/Parameters.Beam.SBNc+abs(Parameters.Design.Load.MSDL_pos)/Parameters.Beam.SBlt);
    Parameters.LRFD.ftLL_pos = max(abs(Parameters.LRFD.MLL_pos))/Parameters.Beam.SBst;
    
    
    
    
    % Positive
    %Strength Limit State I
    Parameters.LRFD.Rating.S1Op_pos = min((Parameters.Beam.Mn_pos-1.25*(Parameters.Design.Load.MDL_pos+Parameters.Design.Load.MSDL_pos))./(1.35*Parameters.LRFD.MLL_pos));
    Parameters.LRFD.Rating.S1Inv_pos = min((Parameters.Beam.Mn_pos-1.25*(Parameters.Design.Load.MDL_pos+Parameters.Design.Load.MSDL_pos))./(1.75*Parameters.LRFD.MLL_pos));
    %Service Limit State II
    Parameters.LRFD.Rating.S2Op_pos = (0.95*Parameters.Beam.Fn_pos-1*(Parameters.LRFD.ftDL_pos))/(1.0*Parameters.LRFD.ftLL_pos);
    Parameters.LRFD.Rating.S2Inv_pos = (0.95*Parameters.Beam.Fn_pos-1*(Parameters.LRFD.ftDL_pos))/(1.3*Parameters.LRFD.ftLL_pos);
    % Negative
    if Parameters.Spans > 1
        
        % get contributional stresses in bottom flange
        Parameters.LRFD.fcDL_neg = max(abs(Parameters.Design.Load.MDL_neg)/Parameters.Beam.SBNc+abs(Parameters.Design.Load.MSDL_neg)/Parameters.Beam.SBNc);
        Parameters.LRFD.fcLL_neg = max(abs(Parameters.LRFD.MLL_neg))/Parameters.Beam.SBNc;
    
        %Strength Limit State I
        Parameters.LRFD.Rating.S1Op_neg = (Parameters.Beam.Fn_neg-1.25*max(abs(Parameters.LRFD.fcDL_neg)))/(1.35*max(abs(Parameters.LRFD.fcLL_neg)));
        Parameters.LRFD.Rating.S1Inv_neg = (Parameters.Beam.Fn_neg-1.25*max(abs(Parameters.LRFD.fcDL_neg)))/(1.75*max(abs(Parameters.LRFD.fcLL_neg)));
        %Service Limit State II
        Parameters.LRFD.Rating.S2Op_neg = (0.95*Parameters.Beam.Fn_neg-1*Parameters.LRFD.fcDL_neg)/(1.0*Parameters.LRFD.fcLL_neg);
        Parameters.LRFD.Rating.S2Inv_neg = (0.95*Parameters.Beam.Fn_neg-1*Parameters.LRFD.fcDL_neg)/(1.3*Parameters.LRFD.fcLL_neg);
    else
        Parameters.LRFD.Rating.S1Op_neg = [];
        Parameters.LRFD.Rating.S1Inv_neg = [];
        Parameters.LRFD.Rating.S2Op_neg = [];
        Parameters.LRFD.Rating.S2Inv_neg = [];
    end

end
end