% (10/20/2014) NPR: Updated calculation of effective width to match AASHTO
% 2012

function Parameters = GetSectionForces(Parameters)
%% Calculate Composite Section Properties
% Calc Properties of Non-Composite Section
Parameters.Beam.STNc = Parameters.Beam.Ix/(Parameters.Beam.d/2);
Parameters.Beam.SBNc = Parameters.Beam.STNc;

if Parameters.Deck.CompositeDesign == 1
    % Calculate Properties of Long-Term Composite Section - Use with
    % Superimposed dead load
    % Creep - 3N is used in all calculations instead of N because 3N
    % controls for flexure.  Shear or other stresses may have different
    % effects
    
    % Determine Effective Width of Deck
    Parameters.Deck.beInt = Parameters.GirderSpacing;
%     A = sort([min(Parameters.EffectiveLength/4), Parameters.GirderSpacing, 12*Parameters.Deck.t]);
%     Parameters.Deck.beInt = A(1);

    Parameters.Deck.Ast = Parameters.Deck.t*Parameters.Deck.beInt/Parameters.Deck.N;
    Parameters.Deck.Alt = Parameters.Deck.t*Parameters.Deck.beInt/(3*Parameters.Deck.N);

    Parameters.Beam.yBlt = (Parameters.Deck.Alt*(Parameters.Deck.t/2 + Parameters.Beam.d) + Parameters.Beam.A*Parameters.Beam.d/2)/(Parameters.Deck.Alt+Parameters.Beam.A);
    Parameters.Beam.yTlt = (Parameters.Deck.t + Parameters.Beam.d) - Parameters.Beam.yBlt;
        
    Parameters.Beam.Ilt =  Parameters.Beam.Ix + Parameters.Beam.A*(Parameters.Beam.yBlt-Parameters.Beam.d/2)^2 +...
            Parameters.Deck.Alt*Parameters.Deck.t^2/12 + Parameters.Deck.Alt*(Parameters.Beam.yTlt - Parameters.Deck.t/2)^2;
    
    Parameters.Beam.SDlt = Parameters.Beam.Ilt/Parameters.Beam.yTlt;
    Parameters.Beam.STlt = Parameters.Beam.Ilt/(Parameters.Beam.yTlt-Parameters.Deck.t);
    Parameters.Beam.SBlt = Parameters.Beam.Ilt/Parameters.Beam.yBlt;
    
    % Calculate Properties of Short-Term Composite Section - Use with Live Load   
    Parameters.Deck.Ast = Parameters.Deck.t*Parameters.Deck.beInt/Parameters.Deck.N;
    
    Parameters.Beam.yBst = (Parameters.Deck.Ast*(Parameters.Deck.t/2 + Parameters.Beam.d) + Parameters.Beam.A*Parameters.Beam.d/2)/(Parameters.Deck.Ast+Parameters.Beam.A);
    Parameters.Beam.yTst = (Parameters.Deck.t + Parameters.Beam.d) - Parameters.Beam.yBst;
    
    Parameters.Beam.Ist = Parameters.Beam.Ix + Parameters.Beam.A*(Parameters.Beam.yBst-Parameters.Beam.d/2)^2 +...
        Parameters.Deck.Ast*Parameters.Deck.t^2/12 + Parameters.Deck.Ast*(Parameters.Beam.yTst - Parameters.Deck.t/2)^2;
    
    Parameters.Beam.SDst = Parameters.Beam.Ist/Parameters.Beam.yTst;
    Parameters.Beam.STst = Parameters.Beam.Ist/(Parameters.Beam.yTst-Parameters.Deck.t);
    Parameters.Beam.SBst = Parameters.Beam.Ist/Parameters.Beam.yBst;
else
    Parameters.Beam.Ist = Parameters.Beam.Ix;
    Parameters.Beam.Ilt = Parameters.Beam.Ix;
    Parameters.Beam.STlt = Parameters.Beam.STNc;
    Parameters.Beam.SBlt = Parameters.Beam.SBNc;
    Parameters.Beam.STst = Parameters.Beam.STNc;
    Parameters.Beam.SBst = Parameters.Beam.SBNc;
    Parameters.Deck.beInt = Parameters.GirderSpacing;
end

%% Dead Load
% Self weight 
DLdeck = Parameters.GirderSpacing*Parameters.Deck.t*Parameters.Deck.density; % lb/in.
DLstringer = Parameters.Beam.A*(490/12^3)*(1.06); % lb/in. includes 6 percent for connections

if Parameters.Spans > 1
    if ~isfield(Parameters.Design, 'CoverPlate')
        Parameters.Beam.CoverPlate.Ratio = Parameters.Beam.CoverPlate.Length/max(Parameters.Length);
    else
        Parameters.Beam.CoverPlate.Ratio = Parameters.Design.CoverPlate.Ratio;
    end

    if Parameters.Beam.CoverPlate.Length > 0
        DLstringer = (1-Parameters.Beam.CoverPlate.Ratio/2)*Parameters.Beam.A*(490/12^3)*(1.06)+(Parameters.Beam.CoverPlate.Ratio/2)*Parameters.Beam.CoverPlate.A*(490/12^3)*(1.06);
        % Add weight of coverplate if cover plate exists
    end
end

if ~strcmp(Parameters.Dia.Type, 'None') 
    if strcmp(Parameters.Dia.Type, 'Beam')
        DLdiaphragm = Parameters.Dia.A*Parameters.NumDia*Parameters.GirderSpacing*(490/12^3)*1.06./Parameters.Length; %lb/in.
    else
        DLdiaphragm = Parameters.Dia.A*Parameters.NumDia*(2*sqrt(Parameters.GirderSpacing^2+Parameters.Beam.d^2))*(490/12^3)*1.06./Parameters.Length; %lb/in.
    end
else
    DLdiaphragm = 0;
end

% Total Non-Superimposed Dead Load
Parameters.Design.Load.wDL = max(DLdeck+DLstringer+DLdiaphragm); %lb/in.

% Superimposed dead loads
DLcurb = ((Parameters.Sidewalk.Left+Parameters.Sidewalk.Right)*Parameters.Sidewalk.Height)*(Parameters.Sidewalk.density)/Parameters.NumGirder; %lb/in. per girder
DLparapet = Parameters.Barrier.Width*Parameters.Barrier.Height*2*Parameters.Barrier.density/Parameters.NumGirder; %lb/in. per girder

% Total Superimosed Dead Load
Parameters.Design.Load.wSDL = DLcurb + DLparapet;

% Dead Loads from wearing surface
Parameters.Design.Load.wSDW = Parameters.Deck.beInt*Parameters.Deck.WearingSurface*Parameters.Deck.density; % lb/in.

% Moments from dead load - multiply by DLM from unit dead load
% Non-superimposed
Parameters.Design.Load.MDL_pos = Parameters.Design.Load.wDL.*Parameters.Design.Load.maxDLM_POI;
Parameters.Design.Load.MDL_neg = min(Parameters.Design.Load.wDL.*Parameters.Design.Load.minDLM_POI,[],2);
% Superimposed (Sidewalk and Barriers)
Parameters.Design.Load.MSDL_pos = Parameters.Design.Load.wSDL*Parameters.Design.Load.maxDLM_POI;
Parameters.Design.Load.MSDL_neg = min(Parameters.Design.Load.wSDL*Parameters.Design.Load.minDLM_POI,[],2);
% Superimposed (Future wearing surface)
Parameters.Design.Load.MSDW_pos = Parameters.Design.Load.wSDW*Parameters.Design.Load.maxDLM_POI;
Parameters.Design.Load.MSDW_neg = min(Parameters.Design.Load.wSDW*Parameters.Design.Load.minDLM_POI,[],2);

% Shear from dead load
Parameters.Design.Load.VDL = max((Parameters.Design.Load.wDL+Parameters.Design.Load.wSDL)*Parameters.Design.Load.maxDLV_POI, [], 2);
Parameters.Design.Load.VDW = max(Parameters.Design.Load.wSDW*Parameters.Design.Load.maxDLV_POI, [], 2);

%% Live Load
% Live load moments and shears
Parameters.Design.Load.MLL_pos = Parameters.Design.Load.maxM_POI; %short term composite;
Parameters.Design.Load.MLL_neg = min(Parameters.Design.Load.minM_POI,[],2);
Parameters.Design.Load.VLL = max(Parameters.Design.Load.maxV_POI,[],2);

if strcmp(Parameters.Design.Code, 'ASD')
% Live Load Using Distribution Factors
Parameters.ASD.MLLIm_pos(1,:) = Parameters.Design.Load.MLL_pos.*(Parameters.Design.Im+1)*Parameters.Design.DF;
Parameters.ASD.MLLIm_pos(2,:) = Parameters.Design.Load.MLL_pos.*(Parameters.Design.Im+1)*Parameters.NumLane*Parameters.Design.MultiPres/Parameters.NumGirder;
Parameters.ASD.MLLIm_neg(1,:) = Parameters.Design.Load.MLL_neg.*(Parameters.Design.Im+1)*Parameters.Design.DF;
Parameters.ASD.MLLIm_neg(2,:) = Parameters.Design.Load.MLL_neg.*(Parameters.Design.Im+1)*Parameters.NumLane*Parameters.Design.MultiPres/Parameters.NumGirder;

%% Stresses
if Parameters.Deck.CompositeDesign == 1
    % Strength Limit State 1
    % Positive
    % Top Fibers
    Parameters.Beam.sigma1 = Parameters.Design.Load.MDL_pos/Parameters.Beam.STNc + Parameters.Design.Load.MSDL_pos/Parameters.Beam.STlt + max(Parameters.ASD.MLLIm_pos,[],1)'/Parameters.Beam.STst;
    Parameters.Beam.fb1 = max(Parameters.Beam.sigma1);
    % Bottom Fibers
    Parameters.Beam.sigma2 = Parameters.Design.Load.MDL_pos./Parameters.Beam.SBNc + Parameters.Design.Load.MSDL_pos/Parameters.Beam.SBlt + max(Parameters.ASD.MLLIm_pos,[],1)'/Parameters.Beam.SBst;
    Parameters.Beam.fb2 = max(Parameters.Beam.sigma2);
    
    % Strength Limit State 2
    % Positive
    % Top Fibers
    Parameters.Beam.sigma3 = (Parameters.Design.Load.MDL_pos/Parameters.Beam.STNc + Parameters.Design.Load.MSDL_pos/Parameters.Beam.STlt + 2*max(Parameters.ASD.MLLIm_pos,[],1)'/Parameters.Beam.STst)/1.5;
    Parameters.Beam.fb3 = max(Parameters.Beam.sigma3);
    % Bottom Fibers
    Parameters.Beam.sigma4 = (Parameters.Design.Load.MDL_pos/Parameters.Beam.SBNc + Parameters.Design.Load.MSDL_pos/Parameters.Beam.SBlt + 2*max(Parameters.ASD.MLLIm_pos,[],1)'/Parameters.Beam.SBst)/1.5;
    Parameters.Beam.fb4 = max(Parameters.Beam.sigma4);
    
    % Negative
    %Strength Limit State 1
    Parameters.Beam.sigma5 = abs(Parameters.Design.Load.MDL_neg)/Parameters.Beam.STNc + abs(Parameters.Design.Load.MSDL_neg)/Parameters.Beam.STNc + max(abs(Parameters.ASD.MLLIm_neg))'/Parameters.Beam.STNc;
    Parameters.Beam.fb5 = max(Parameters.Beam.sigma5);
    
    %Strength Limit State 2
    Parameters.Beam.sigma6 = (abs(Parameters.Design.Load.MDL_neg)/Parameters.Beam.STNc + abs(Parameters.Design.Load.MSDL_neg)/Parameters.Beam.STNc + 2*max(abs(Parameters.ASD.MLLIm_neg))'/Parameters.Beam.STNc)/1.5;
    Parameters.Beam.fb6 = max(Parameters.Beam.sigma6);
    % Deck Limits
%     Parameters.Beam.sigma5 = abs(Parameters.Design.Load.MSDL_neg)/Parameters.Beam.SDlt/(3*Parameters.Deck.N);    
%     Parameters.Beam.fb5 = max(Parameters.Beam.sigma5);
else
     % Strength Limit State 1
    % Positive
    % Top Fibers
    Parameters.Beam.sigma1 = Parameters.Design.Load.MDL_pos/Parameters.Beam.STNc + Parameters.Design.Load.MSDL_pos/Parameters.Beam.STNc + max(Parameters.ASD.MLLIm_pos,[],1)'/Parameters.Beam.STNc;
    Parameters.Beam.fb1 = max(Parameters.Beam.sigma1);
    % Bottom Fibers
    Parameters.Beam.sigma2 = Parameters.Design.Load.MDL_pos/Parameters.Beam.SBNc + Parameters.Design.Load.MSDL_pos/Parameters.Beam.SBNc + max(Parameters.ASD.MLLIm_pos,[],1)'/Parameters.Beam.SBNc;
    Parameters.Beam.fb2 = max(Parameters.Beam.sigma2);
    
    % Strength Limit State 2
    % Positive
    % Top Fibers
    Parameters.Beam.sigma3 = (Parameters.Design.Load.MDL_pos/Parameters.Beam.STNc + Parameters.Design.Load.MSDL_pos/Parameters.Beam.STNc + 2*max(Parameters.ASD.MLLIm_pos,[],1)'/Parameters.Beam.STNc)/1.5;
    Parameters.Beam.fb3 = max(Parameters.Beam.sigma3);
    % Positive
    Parameters.Beam.sigma4 = (Parameters.Design.Load.MDL_pos/Parameters.Beam.SBNc + Parameters.Design.Load.MSDL_pos/Parameters.Beam.SBNc + 2*max(Parameters.ASD.MLLIm_pos,[],1)'/Parameters.Beam.SBNc)/1.5;
    Parameters.Beam.fb4 = max(Parameters.Beam.sigma4);
    
    % Negative
    %Strength Limit State 1
    Parameters.Beam.sigma5 = abs(Parameters.Design.Load.MDL_neg)/Parameters.Beam.STNc + abs(Parameters.Design.Load.MSDL_neg)/Parameters.Beam.STNc + max(abs(Parameters.ASD.MLLIm_neg))'/Parameters.Beam.STNc;
    Parameters.Beam.fb5 = max(Parameters.Beam.sigma5);
    
    %Strength Limit State 2
    Parameters.Beam.sigma6 = (abs(Parameters.Design.Load.MDL_neg)/Parameters.Beam.STNc + abs(Parameters.Design.Load.MSDL_neg)/Parameters.Beam.STNc + 2*max(abs(Parameters.ASD.MLLIm_neg))'/Parameters.Beam.STNc)/1.5;
    Parameters.Beam.fb6 = max(Parameters.Beam.sigma6);
end

if Parameters.Design.CoverPlate.Ratio == 0
    Parameters.Beam.fbcmax = max([Parameters.Beam.fb1,Parameters.Beam.fb3, abs(Parameters.Beam.fb5), abs(Parameters.Beam.fb6)]);
else
    Parameters.Beam.fbcmax = max(Parameters.Beam.fb1,Parameters.Beam.fb3);
end

elseif strcmp(Parameters.Design.Code, 'LRFD')
    % Distribution Factors
    [Parameters.Design.DF, Parameters.Design.DFV] = LRFDDistFact(Parameters);
   
    % Live Load Using Distribution Factors and IMpact factor
    Parameters.LRFD.MLL_pos = Parameters.Design.Load.MLL_pos.*max(Parameters.Design.DF)*Parameters.Design.IMF;
    Parameters.LRFD.MLL_neg = min(Parameters.Design.Load.MLL_neg.*max(Parameters.Design.DF))*Parameters.Design.IMF;
    Parameters.LRFD.VLL = Parameters.Design.Load.VLL.*max(Parameters.Design.DFV)*Parameters.Design.IMF;
    
    %Flexural stresses in compression flange for computation of Dc
    % Reference commentary in Appendix D (CD6.3.1). For composite sections
    % in positive flexure, Dc is not needed for sections without
    % longitudinal sitffeners
    
%     Parameters.Beam.fdc1 = max(abs(Parameters.Design.Load.MDL_pos))/Parameters.Beam.STNc;
%     Parameters.Beam.fdc2 = max(abs(Parameters.Design.Load.MSDL_pos))/Parameters.Beam.STlt;
%     Parameters.Beam.fll = max(abs(Parameters.LRFD.MLL_pos))/Parameters.Beam.STst;
%     Parameters.Beam.fdc1_neg = max(abs(Parameters.Design.Load.MDL_neg))/Parameters.Beam.STNc;
%     Parameters.Beam.fdc2_neg = max(abs(Parameters.Design.Load.MSDL_neg))/Parameters.Beam.STlt;
%     Parameters.Beam.fll_neg = max(max(abs(Parameters.LRFD.MLL_neg)))/Parameters.Beam.STst;
    
    % Total Factored Moments & Stresses
    % Strength Limit State I
    % Strength I factors: DC = 1.25, DW = 1.5, LL = 1.75
    Parameters.LRFD.M_pos = 1.25*(Parameters.Design.Load.MDL_pos+Parameters.Design.Load.MSDL_pos)+1.50*(Parameters.Design.Load.MSDW_pos)+1.75*(Parameters.LRFD.MLL_pos);
    Parameters.LRFD.M_neg = abs(1.25*(Parameters.Design.Load.MDL_neg+Parameters.Design.Load.MSDL_neg)+1.50*(Parameters.Design.Load.MSDW_neg)+1.75*(Parameters.LRFD.MLL_neg));
    Parameters.LRFD.V = 1.25*(Parameters.Design.Load.VDL)+1.50*(Parameters.Design.Load.VDW)+1.75*(Parameters.LRFD.VLL);
    
    Parameters.Beam.fbc_pos(1,:) = max(1.25*(abs(Parameters.Design.Load.MDL_pos)/Parameters.Beam.STNc+abs(Parameters.Design.Load.MSDL_pos)/Parameters.Beam.STlt)+...
        1.50*(abs(Parameters.Design.Load.MSDW_pos)/Parameters.Beam.STlt)+...
        1.75*max(abs(Parameters.LRFD.MLL_pos))/Parameters.Beam.STst);
    Parameters.Beam.fbc_neg(1,:) = max(1.25*max((abs(Parameters.Design.Load.MDL_neg)/Parameters.Beam.SBNc+abs(Parameters.Design.Load.MSDL_neg)/Parameters.Beam.SBNc))+...
        1.50*max(abs(Parameters.Design.Load.MSDW_neg))/Parameters.Beam.SBNc+...
        1.75*max(abs(Parameters.LRFD.MLL_neg))/Parameters.Beam.SBNc);
    Parameters.Beam.fbt_pos(1,:) = max(1.25*(abs(Parameters.Design.Load.MDL_pos)/Parameters.Beam.SBNc+abs(Parameters.Design.Load.MSDL_pos)/Parameters.Beam.SBlt)+...
        1.50*(abs(Parameters.Design.Load.MSDW_pos)/Parameters.Beam.SBlt)+...
        1.75*max(abs(Parameters.LRFD.MLL_pos))/Parameters.Beam.SBst);
    Parameters.Beam.fbt_neg(1,:) = max(1.25*max((abs(Parameters.Design.Load.MDL_neg)/Parameters.Beam.STNc+abs(Parameters.Design.Load.MSDL_neg)/Parameters.Beam.STNc))+...
        1.50*max(abs(Parameters.Design.Load.MSDW_neg))/Parameters.Beam.STNc+...
        1.75*max(abs(Parameters.LRFD.MLL_neg))/Parameters.Beam.STNc);
    
    % Service Limit State II
    % Service II factors: DC = 1.0, DW = 1.0, LL = 1.3
    Parameters.Beam.fbc_pos(2,:) = max(1*(abs(Parameters.Design.Load.MDL_pos)/Parameters.Beam.STNc+...%Stress in compression flange
        abs(Parameters.Design.Load.MSDL_pos)/Parameters.Beam.STlt+abs(Parameters.Design.Load.MSDW_pos)/Parameters.Beam.STlt)+... 
        1.30*max(abs(Parameters.LRFD.MLL_pos))/Parameters.Beam.STst);
    Parameters.Beam.fbc_neg(2,:) = max(1*max((abs(Parameters.Design.Load.MDL_neg)/Parameters.Beam.SBNc+...
        abs(Parameters.Design.Load.MSDL_neg)/Parameters.Beam.SBNc)+abs(Parameters.Design.Load.MSDW_neg)/Parameters.Beam.SBNc)+...
        1.30*max(abs(Parameters.LRFD.MLL_neg))/Parameters.Beam.SBNc);
    Parameters.Beam.fbt_pos(2,:) = max(1*(abs(Parameters.Design.Load.MDL_pos)/Parameters.Beam.SBNc+...%Stress in tension flange
        abs(Parameters.Design.Load.MSDL_pos)/Parameters.Beam.SBlt+abs(Parameters.Design.Load.MSDW_pos)/Parameters.Beam.SBlt)+... 
        1.30*max(abs(Parameters.LRFD.MLL_pos))/Parameters.Beam.SBst);
    Parameters.Beam.fbt_neg(2,:) = max(1*max((abs(Parameters.Design.Load.MDL_neg)/Parameters.Beam.STNc+...
        abs(Parameters.Design.Load.MSDL_neg)/Parameters.Beam.STNc+abs(Parameters.Design.Load.MSDW_neg)/Parameters.Beam.STNc))+...
        1.30*max(abs(Parameters.LRFD.MLL_neg))/Parameters.Beam.STNc);
    
    % Maximum stress in compression flange
    if Parameters.Beam.CoverPlate.Length == 0
        Parameters.Beam.fbcmax = max(max(Parameters.Beam.fbc_pos),max(Parameters.Beam.fbc_neg));
    else
        Parameters.Beam.fbcmax = max(Parameters.Beam.fbc_pos);
    end

end

end % GetSectionParameters()