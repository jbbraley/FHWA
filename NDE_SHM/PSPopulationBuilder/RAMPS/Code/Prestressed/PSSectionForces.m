function Parameters = PSSectionForces(Parameters)
%% Calculate Composite Section Properties
%% Effective Slab Width      
% Interior Girders
WF = [.25*min(Parameters.Length) 12*Parameters.Deck.t+max(Parameters.Beam.tw, .5*Parameters.Beam.bft) Parameters.GirderSpacing];
Parameters.Deck.beff(1) = min(WF);
% Exterior Girders
WF = [0.125*min(Parameters.Length) 6*Parameters.Deck.t+max(Parameters.Beam.tw/2, .25*Parameters.Beam.bft) Parameters.Overhang];
Parameters.Deck.beff(2) = Parameters.Deck.beff(1)/2+min(WF);

%% Haunch dimension
Parameters.Deck.dHaunch = 0; %in
Parameters.Deck.bHaunch = Parameters.Beam.bft;

%% Composite Section Properties
% Calculate Properties of Interior & Exterior Composite Section
Parameters.Deck.Ast = Parameters.Deck.t*Parameters.Deck.beff*Parameters.Deck.E/Parameters.Beam.E;

Parameters.Beam.yBst = (Parameters.Deck.Ast*(Parameters.Deck.t/2 + Parameters.Beam.d) + Parameters.Beam.A*Parameters.Beam.yb)/(Parameters.Deck.Ast+Parameters.Beam.A);
Parameters.Beam.yTst = (Parameters.Deck.t + Parameters.Beam.d) - Parameters.Beam.yBst;

Parameters.Beam.Ist = Parameters.Beam.Ix + Parameters.Beam.A*(Parameters.Beam.yBst-Parameters.Beam.yb)^2 +...
    Parameters.Deck.Ast*Parameters.Deck.t^2/12 + Parameters.Deck.Ast*(Parameters.Beam.yTst - Parameters.Deck.t/2)^2;

Parameters.Beam.SDst = Parameters.Beam.Ist/Parameters.Beam.yTst;
Parameters.Beam.STst = Parameters.Beam.Ist/(Parameters.Beam.yTst-Parameters.Deck.t);
Parameters.Beam.SBst = Parameters.Beam.Ist/Parameters.Beam.yBst;

%% Calculate Long term Properties of Interior & Exterior Composite Section - To be used with super imposed dead loads
Parameters.Deck.Alt = Parameters.Deck.t*Parameters.Deck.beff/(3)*Parameters.Deck.E/Parameters.Beam.E;

Parameters.Beam.yBlt = (Parameters.Deck.Alt*(Parameters.Deck.t/2 + Parameters.Beam.d) + Parameters.Beam.A*Parameters.Beam.yb)/(Parameters.Deck.Alt+Parameters.Beam.A);
Parameters.Beam.yTlt = (Parameters.Deck.t + Parameters.Beam.d) - Parameters.Beam.yBlt;

Parameters.Beam.Ilt = Parameters.Beam.Ix + Parameters.Beam.A*(Parameters.Beam.yBlt-Parameters.Beam.yb)^2 +...
    Parameters.Deck.Alt*Parameters.Deck.t^2/12 + Parameters.Deck.Alt*(Parameters.Beam.yTlt - Parameters.Deck.t/2)^2;

Parameters.Beam.SDlt = Parameters.Beam.Ilt/Parameters.Beam.yTlt;
Parameters.Beam.STlt = Parameters.Beam.Ilt/(Parameters.Beam.yTlt-Parameters.Deck.t);
Parameters.Beam.SBlt = Parameters.Beam.Ilt/Parameters.Beam.yBlt;

%% Dead Load
Parameters.Design.Load.DLdeck(1) = Parameters.GirderSpacing* Parameters.Deck.t*Parameters.Deck.density; % Interior
Parameters.Design.Load.DLdeck(2) = (Parameters.Overhang+Parameters.GirderSpacing/2)*Parameters.Deck.t*Parameters.Deck.density; % Exterior
Parameters.Design.Load.DLstringer = Parameters.Beam.A*Parameters.Beam.density; 
Parameters.Design.Load.DLhaunch = Parameters.Deck.dHaunch*Parameters.Deck.bHaunch*Parameters.Deck.density;

%Diaphragm Dead weight
Parameters.Design.Load.DLdiaphragm = Parameters.Dia.density*Parameters.Dia.A*Parameters.NumDia*(Parameters.GirderSpacing-Parameters.Beam.tw)./Parameters.Length;

% Curb and Parapet Dead weight
Parameters.Design.Load.DLcurb = (Parameters.Sidewalk.Left*Parameters.Sidewalk.Height+Parameters.Sidewalk.Right*Parameters.Sidewalk.Height)*(Parameters.Sidewalk.density)/Parameters.NumGirder;
Parameters.Design.Load.DLparapet = Parameters.Barrier.Width*Parameters.Barrier.Height*2*Parameters.Barrier.density/Parameters.NumGirder;

% %Wearing Surface
% Parameters.Design.Load.DWearing(1) = 144/(12^3)*Parameters.Overlay*Parameters.GirderSpacing; % Interior
% Parameters.Design.Load.DWearing(2) = 144/(12^3)*Parameters.Overlay*(Parameters.GirderSpacing/2+Parameters.Overhang-min(Parameters.Sidewalk.Right, Parameters.Sidewalk.Left)-Parameters.Barrier.Width);


%% Positive Moment
Parameters.Design.Load.wDL = max(Parameters.Design.Load.DLdeck+Parameters.Design.Load.DLstringer+Parameters.Design.Load.DLhaunch+Parameters.Design.Load.DLdiaphragm);

% Superimposed dead loads
Parameters.Design.Load.wSDL = Parameters.Design.Load.DLcurb + Parameters.Design.Load.DLparapet;

% Moments from dead load - multiply by DLM from unit dead load
Parameters.Design.Load.MDL_pos = (Parameters.Design.Load.wDL).*Parameters.Design.Load.maxDLM_POI;
Parameters.Design.Load.MDL_neg = min((Parameters.Design.Load.wDL).*Parameters.Design.Load.minDLM_POI);
Parameters.Design.Load.MSDL_pos = (Parameters.Design.Load.wSDL).*Parameters.Design.Load.maxDLM_POI;
Parameters.Design.Load.MSDL_neg = min((Parameters.Design.Load.wSDL).*Parameters.Design.Load.minDLM_POI);
% Parameters.Design.Load.MDW_pos = max(DWearing)*Parameters.Design.Load.maxDLM_POI;
% Parameters.Design.Load.MDW_neg = min(max(DWearing)*Parameters.Design.Load.minDLM_POI);
Parameters.Design.Load.VDL = max((Parameters.Design.Load.wDL+Parameters.Design.Load.wSDL)*Parameters.Design.Load.maxDLV_POI);

%% Live Load
% Live load moments and shears
Parameters.Design.Load.MLL_pos = Parameters.Design.Load.maxM_POI; %short term composite;
Parameters.Design.Load.MLL_neg = Parameters.Design.Load.minM_POI;
Parameters.Design.Load.VLL = max(Parameters.Design.Load.maxV_POI);

%% Distribution Factors
[Parameters.Design.DF, Parameters.Design.DFV] = LRFDDistFact(Parameters);

% Live Load Using Distribution Factors
Parameters.LRFD.MLL_pos = Parameters.Design.Load.MLL_pos.*max(Parameters.Design.DF);
Parameters.LRFD.MLL_neg = min(Parameters.Design.Load.MLL_neg.*max(Parameters.Design.DF));
Parameters.LRFD.VLL = Parameters.Design.Load.VLL.*max(Parameters.Design.DFV);

% Total Factored Moments
% Strength Limit State I
Parameters.LRFD.M_pos = 1.25*(Parameters.Design.Load.MDL_pos+Parameters.Design.Load.MSDL_pos)+1.75*(Parameters.LRFD.MLL_pos*Parameters.Design.IMF); %+1.5*Parameters.Design.Load.MDW_pos
% Parameters.LRFD.M_neg = abs(1.25*(Parameters.Design.Load.MDL_neg+Parameters.Design.Load.MSDL_neg)+1.75*(Parameters.LRFD.MLL_neg*Parameters.Design.IMF)); %+1.5*Parameters.Design.Load.MDW_neg
% Parameters.LRFD.V = 1.25*(Parameters.Design.Load.VDL)+1.75*(Parameters.LRFD.VLL);


end % PSSectionForces ()