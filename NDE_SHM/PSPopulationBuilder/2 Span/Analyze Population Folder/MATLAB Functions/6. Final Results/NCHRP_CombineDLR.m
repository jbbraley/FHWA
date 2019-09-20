function [DLResults] = NCHRP_CombineDLR(DLResults,Parameters)

% Establish bounds of coverplate region
SpanLength = round(Parameters.Length/12)'; %[ft]
Fixed = zeros(Parameters.Spans, 1);
for f = 1:Parameters.Spans
    Fixed(f) = sum(SpanLength(1:f));
end
Fixed = [1; Fixed + 1];

lb = floor(Fixed(2:end-1)-(Parameters.Beam.Int.CoverPlate.Ratio*max(Parameters.Length/12)));
ub = ceil(Fixed(2:end-1)+(Parameters.Beam.Int.CoverPlate.Ratio*max(Parameters.Length/12))-1);

%% DEAD LOAD --------------------------------------------------------------

% Get M1(4), M2(6), and A(1) responses for DL1 and DL2
dl1_m1 = DLResults(1).BeamForce(:,:,:,4); % DL1 Moment Major Axis
dl1_m2 = DLResults(1).BeamForce(:,:,:,6); % DL1 Moment Minor Axis
dl1_a  = DLResults(1).BeamForce(:,:,:,1); % DL1 Axial
dl2_m1 = DLResults(2).BeamForce(:,:,:,4); % DL2 Moment Major Axis
dl2_m2 = DLResults(2).BeamForce(:,:,:,6); % DL2 Moment Minor Axis
dl2_a  = DLResults(2).BeamForce(:,:,:,1); % DL2 Axial

% Concatenate dimensions for spans
DL1_M1 = cat(1,dl1_m1(1:end-1,:,1),dl1_m1(1:end-1,:,2));
DL1_M2 = cat(1,dl1_m2(1:end-1,:,1),dl1_m2(1:end-1,:,2));
DL1_A  = cat(1,dl1_a(1:end-1,:,1),dl1_a(1:end-1,:,2));
DL2_M1 = cat(1,dl2_m1(1:end-1,:,1),dl2_m1(1:end-1,:,2));
DL2_M2 = cat(1,dl2_m2(1:end-1,:,1),dl2_m2(1:end-1,:,2));
DL2_A  = cat(1,dl2_a(1:end-1,:,1),dl2_a(1:end-1,:,2));

% Calculate extreme fiber stress
for kk = 1:length(DL1_M1) % loop through individual elements
    
    for jj = 1:Parameters.NumGirder % loop through girder locations
        
        % Determine if interior or exterior girder
        if jj == 1 || jj == Parameters.NumGirder % Exterior Girder
            
            % define section properties dependent on location
            if kk<lb || kk>ub % Non-coverplate region
                S1 = Parameters.Beam.Ext.S.STnc;
                S2 = Parameters.Beam.Ext.S.S2;
                A  = Parameters.Beam.Ext.A; 
            else % Coverplate region
                S1 = Parameters.Beam.Ext.CoverPlate.S.STnc;
                S2 = Parameters.Beam.Ext.CoverPlate.S.S2;
                A  = Parameters.Beam.Ext.CoverPlate.A;
            end
                
            % Extreme fiber stresses for DL1 and DL2 (top, bottom, deck)
            % retaining signs throughout
            DL1s_t(kk,jj) = (((DL1_M1(kk,jj)/-S1)/abs(DL1_M1(kk,jj)/-S1))*(abs(DL1_M1(kk,jj)/-S1)+abs(DL1_M2(kk,jj)/S2))) - (DL1_A(kk,jj)/A);
            DL2s_t(kk,jj) = (((DL2_M1(kk,jj)/-S1)/abs(DL2_M1(kk,jj)/-S1))*(abs(DL2_M1(kk,jj)/-S1)+abs(DL2_M2(kk,jj)/S2))) - (DL2_A(kk,jj)/A);
            
            DL1s_b(kk,jj) = (((DL1_M1(kk,jj)/S1)/abs(DL1_M1(kk,jj)/S1))*(abs(DL1_M1(kk,jj)/S1)+abs(DL1_M2(kk,jj)/S2))) - (DL1_A(kk,jj)/A);
            DL2s_b(kk,jj) = (((DL2_M1(kk,jj)/S1)/abs(DL2_M1(kk,jj)/S1))*(abs(DL2_M1(kk,jj)/S1)+abs(DL2_M2(kk,jj)/S2))) - (DL2_A(kk,jj)/A);
            
            DL1s_d(kk,jj) = (DL1s_t(kk,jj)/Parameters.Beam.E)*(1+(2*Parameters.Deck.t/Parameters.Beam.Ext.CoverPlate.d))*Parameters.Deck.E;
            DL2s_d(kk,jj) = (DL2s_t(kk,jj)/Parameters.Beam.E)*(1+(2*Parameters.Deck.t/Parameters.Beam.Ext.CoverPlate.d))*Parameters.Deck.E;
                
        else % Interior Girder
            
            % define section properties dependent on location
            if kk<lb || kk>ub % Non-coverplate region
                S1 = Parameters.Beam.Int.S.STnc;
                S2 = Parameters.Beam.Int.S.S2;
                A  = Parameters.Beam.Int.A; 
            else % Coverplate region
                S1 = Parameters.Beam.Int.CoverPlate.S.STnc;
                S2 = Parameters.Beam.Int.CoverPlate.S.S2;
                A  = Parameters.Beam.Int.CoverPlate.A;
            end
                
            % Extreme fiber stresses for DL1 and DL2 (top, bottom, deck)
            DL1s_t(kk,jj) = (((DL1_M1(kk,jj)/-S1)/abs(DL1_M1(kk,jj)/-S1))*(abs(DL1_M1(kk,jj)/-S1)+abs(DL1_M2(kk,jj)/S2))) - (DL1_A(kk,jj)/A);
            DL2s_t(kk,jj) = (((DL2_M1(kk,jj)/-S1)/abs(DL2_M1(kk,jj)/-S1))*(abs(DL2_M1(kk,jj)/-S1)+abs(DL2_M2(kk,jj)/S2))) - (DL2_A(kk,jj)/A);
            
            DL1s_b(kk,jj) = (((DL1_M1(kk,jj)/S1)/abs(DL1_M1(kk,jj)/S1))*(abs(DL1_M1(kk,jj)/S1)+abs(DL1_M2(kk,jj)/S2))) - (DL1_A(kk,jj)/A);
            DL2s_b(kk,jj) = (((DL2_M1(kk,jj)/S1)/abs(DL2_M1(kk,jj)/S1))*(abs(DL2_M1(kk,jj)/S1)+abs(DL2_M2(kk,jj)/S2))) - (DL2_A(kk,jj)/A);
            
            DL1s_d(kk,jj) = (DL1s_t(kk,jj)/Parameters.Beam.E)*(1+(2*Parameters.Deck.t/Parameters.Beam.Int.CoverPlate.d))*Parameters.Deck.E;
            DL2s_d(kk,jj) = (DL2s_t(kk,jj)/Parameters.Beam.E)*(1+(2*Parameters.Deck.t/Parameters.Beam.Int.CoverPlate.d))*Parameters.Deck.E;
            
        end
    end
end

% Reactions
DL1_Rxns = DLResults(1).NodeRxn(:,:,3);
DL1_Rxns(2,:) = DL1_Rxns(2,:)/2;
DL1_Rxns(find(DL1_Rxns < 0)) = 0;
DL2_Rxns = DLResults(2).NodeRxn(:,:,3);
DL2_Rxns(2,:) = DL2_Rxns(2,:)/2;
DL2_Rxns(find(DL2_Rxns < 0)) = 0;

% Save to DLResults
DLResults(1).DL1_M1 = DL1_M1;
DLResults(1).DL1_M2 = DL1_M2;
DLResults(1).DL1_A  = DL1_A;
DLResults(2).DL2_M1 = DL2_M1;
DLResults(2).DL2_M2 = DL2_M2;
DLResults(2).DL2_A  = DL2_A;
DLResults(1).DL1s_t  = DL1s_t;
DLResults(2).DL2s_t  = DL2s_t;
DLResults(1).DL1s_b  = DL1s_b;
DLResults(2).DL2s_b  = DL2s_b;
DLResults(1).DL1s_d  = DL1s_d;
DLResults(2).DL2s_d  = DL2s_d;
DLResults(1).DL1_Rxns  = DL1_Rxns;
DLResults(2).DL2_Rxns  = DL2_Rxns;


end