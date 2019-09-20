function [TS] = NCHRP_GetTSFactors_v3(Parameters,DLResults,LLResults,SResults)

% Locations of Interest
numBeams = 2*length(LLResults.beamNums)-2;
pier_lb = round(0.45*numBeams);
pier_ub = round(0.55*numBeams);
pos_lb1 = round(0.15*numBeams);  % 0.3L Span 1
pos_ub1 = round(0.275*numBeams);   % 0.55L Span 1
pos_lb2 = round(0.75*numBeams);   % 0.55L Span 2
pos_ub2 = round(0.85*numBeams);  % 0.3L Span 2

% Define variables
DL1_M1 = DLResults(1).DL1_M1;
DL2_M1 = DLResults(2).DL2_M1;
LL_M1 = LLResults.LL_M1;
Sett_M1 = SResults.Sett_M1;
DL1s_b = DLResults(1).DL1s_b;
DL2s_b = DLResults(2).DL2s_b;
LLs_b = LLResults.LLs_b;
Setts_b = SResults.Setts_b;
DL1s_d = DLResults(1).DL1s_d;
DL2s_d = DLResults(2).DL2s_d;
LLs_d = LLResults.LLs_d;
Setts_d = SResults.Setts_d;
DL1_Rxns = DLResults(1).DL1_Rxns;
DL2_Rxns = DLResults(2).DL2_Rxns;
LL_Rxns = LLResults.LL_Rxns;
Sett_Rxns = SResults.Sett_Rxns;

    
% STRENGTH I --------------------------------------------------------------
    
for aa = 1:Parameters.NumGirder

% Capacity
if aa == 1 || aa == Parameters.NumGirder % Exterior
    PosCap = Parameters.Beam.Ext.Mn_pos;
    NegCap = Parameters.Beam.Ext.Fn_neg;
else % Interior
    PosCap = Parameters.Beam.Int.Mn_pos;
    NegCap = Parameters.Beam.Int.Fn_neg;
end

% Over Pier
TS.M_St1_pier(:,aa) = (NegCap - 1.25*abs(DL1s_b(pier_lb:pier_ub,aa)) - 1.25*abs(DL2s_b(pier_lb:pier_ub,aa))...
    - 1.75*abs(LLs_b(pier_lb:pier_ub,aa)))./abs(Setts_b(pier_lb:pier_ub,aa));

% Positive Region Span1
TS.M_St1_pos1(:,aa) = (PosCap - 1.25*abs(DL1_M1(pos_lb1:pos_ub1,aa))...
    - 1.25*abs(DL2_M1(pos_lb1:pos_ub1,aa)) - 1.75*abs(LL_M1(pos_lb1:pos_ub1,aa)))./...
    abs(Sett_M1(pos_lb1:pos_ub1,aa));

% Positive Region Span2
TS.M_St1_pos2(:,aa) = (PosCap - 1.25*abs(DL1_M1(pos_lb2:pos_ub2,aa))...
    - 1.25*abs(DL2_M1(pos_lb2:pos_ub2,aa)) - 1.75*abs(LL_M1(pos_lb2:pos_ub2,aa)))./...
    abs(Sett_M1(pos_lb2:pos_ub2,aa));

end

% SERVICE II --------------------------------------------------------------

% Capacity
NegCap = 0.8*Parameters.Beam.Fy;
PosCap = 0.95*Parameters.Beam.Fy;

% Over Pier
TS.M_Sv2_pier(:,:) = (NegCap - 1.0*abs(DL1s_b(pier_lb:pier_ub,:)) - 1.0*abs(DL2s_b(pier_lb:pier_ub,:))...
    - 1.3*abs(LLs_b(pier_lb:pier_ub,:)))./abs(Setts_b(pier_lb:pier_ub,:));

% Positive Region Span1
TS.M_Sv2_pos1(:,:) = (PosCap - 1.0*abs(DL1s_b(pos_lb1:pos_ub1,:))...
    - 1.0*abs(DL2s_b(pos_lb1:pos_ub1,:)) - 1.3*abs(LLs_b(pos_lb1:pos_ub1,:)))./...
    abs(Setts_b(pos_lb1:pos_ub1,:));

% Positive Region Span2
TS.M_Sv2_pos2(:,:) = (PosCap - 1.0*abs(DL1s_b(pos_lb2:pos_ub2,:))...
    - 1.0*abs(DL2s_b(pos_lb2:pos_ub2,:)) - 1.3*abs(LLs_b(pos_lb2:pos_ub2,:)))./...
    abs(Setts_b(pos_lb2:pos_ub2,:));

% SERVICE A ---------------------------------------------------------------

% Capacity
NegCap = 7.5*sqrt(Parameters.Deck.fc);
PosCap = Parameters.Deck.fc;

% Over Pier
TS.M_SvA_pier(:,:) = (NegCap - 1.0*abs(DL1s_d(pier_lb:pier_ub,:)) - 1.0*abs(DL2s_d(pier_lb:pier_ub,:))...
    - 1.0*abs(LLs_d(pier_lb:pier_ub,:)))./abs(Setts_d(pier_lb:pier_ub,:));

% Positive Region Span1
TS.M_SvA_pos1(:,:) = (PosCap - 1.0*abs(DL1s_d(pos_lb1:pos_ub1,:))...
    - 1.0*abs(DL2s_d(pos_lb1:pos_ub1,:)) - 1.0*abs(LLs_d(pos_lb1:pos_ub1,:)))./...
    abs(Setts_d(pos_lb1:pos_ub1,:));

% Positive Region Span2
TS.M_SvA_pos2(:,:) = (PosCap - 1.0*abs(DL1s_d(pos_lb2:pos_ub2,:))...
    - 1.0*abs(DL2s_d(pos_lb2:pos_ub2,:)) - 1.0*abs(LLs_d(pos_lb2:pos_ub2,:)))./...
    abs(Setts_d(pos_lb2:pos_ub2,:));


% SHEAR -------------------------------------------------------------------     
    
abt1 = 1;
pier = 2;
abt2 = 3;

for aa = 1:Parameters.NumGirder

    % Capacity
    if aa == 1 || aa == Parameters.NumGirder % Exterior
        Cap = Parameters.Beam.Ext.Vn;
    else % Interior
        Cap = Parameters.Beam.Int.Vn;
    end

    % Pier
    TS.V_St1_pier(1,aa) = (Cap - 1.25*DL1_Rxns(pier,aa) - 1.25*DL2_Rxns(pier,aa)...
        - 1.75*LL_Rxns(pier,aa))/Sett_Rxns(pier,aa);

    % Abt1
    TS.V_St1_abt1(1,aa) = (Cap - 1.25*DL1_Rxns(abt1,aa) - 1.25*DL2_Rxns(abt1,aa)...
        - 1.75*LL_Rxns(abt1,aa))/Sett_Rxns(abt1,aa);

    % Abt2
    TS.V_St1_abt2(1,aa) = (Cap - 1.25*DL1_Rxns(abt2,aa) - 1.25*DL2_Rxns(abt2,aa)...
        - 1.75*LL_Rxns(abt2,aa))/Sett_Rxns(abt2,aa);

end
   

end

