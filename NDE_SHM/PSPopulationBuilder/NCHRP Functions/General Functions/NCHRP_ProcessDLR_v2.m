function [DLResults] = NCHRP_ProcessDLR_v2(DLResults,Parameters)

% _v2: fixed issue with determination of cover plate location 



%% DEAD LOAD --------------------------------------------------------------

% Get M1(4), M2(6), and A(1) responses for DL1 and DL2
dl1_m1 = DLResults(1).BeamForce(:,:,:,4); % DL1 Moment Major Axis
dl1_m2 = DLResults(1).BeamForce(:,:,:,6); % DL1 Moment Minor Axis
dl1_a  = DLResults(1).BeamForce(:,:,:,1); % DL1 Axial
dl2_m1 = DLResults(2).BeamForce(:,:,:,4); % DL2 Moment Major Axis
dl2_m2 = DLResults(2).BeamForce(:,:,:,6); % DL2 Moment Minor Axis
dl2_a  = DLResults(2).BeamForce(:,:,:,1); % DL2 Axial

% Concatenate dimensions for spans
if Parameters.Spans == 2
    DL1_M1 = cat(1,dl1_m1(1:end-1,:,1),dl1_m1(1:end-1,:,2));
    DL1_M2 = cat(1,dl1_m2(1:end-1,:,1),dl1_m2(1:end-1,:,2));
    DL1_A  = cat(1,dl1_a(1:end-1,:,1),dl1_a(1:end-1,:,2));
    DL2_M1 = cat(1,dl2_m1(1:end-1,:,1),dl2_m1(1:end-1,:,2));
    DL2_M2 = cat(1,dl2_m2(1:end-1,:,1),dl2_m2(1:end-1,:,2));
    DL2_A  = cat(1,dl2_a(1:end-1,:,1),dl2_a(1:end-1,:,2));
elseif Parameters.Spans == 3
    DL1_M1 = cat(1,dl1_m1(1:end-1,:,1),dl1_m1(1:end-1,:,2),dl1_m1(1:end-1,:,3));
    DL1_M2 = cat(1,dl1_m2(1:end-1,:,1),dl1_m2(1:end-1,:,2),dl1_m2(1:end-1,:,3));
    DL1_A  = cat(1,dl1_a(1:end-1,:,1),dl1_a(1:end-1,:,2),dl1_a(1:end-1,:,3));
    DL2_M1 = cat(1,dl2_m1(1:end-1,:,1),dl2_m1(1:end-1,:,2),dl2_m1(1:end-1,:,3));
    DL2_M2 = cat(1,dl2_m2(1:end-1,:,1),dl2_m2(1:end-1,:,2),dl2_m2(1:end-1,:,3));
    DL2_A  = cat(1,dl2_a(1:end-1,:,1),dl2_a(1:end-1,:,2),dl2_a(1:end-1,:,3));
else
    DL1_M1 = dl1_m1;
    DL1_M2 = dl1_m2;
    DL1_A  = dl1_a;
    DL2_M1 = dl2_m1;
    DL2_M2 = dl2_m2;
    DL2_A  = dl2_a;
end

% Calculate extreme fiber stress
for kk = 1:length(DL1_M1) % loop through individual elements
    
    for jj = 1:Parameters.NumGirder % loop through girder locations
        
        % Determine if interior or exterior girder
        if jj == 1 || jj == Parameters.NumGirder % Exterior Girder
            
                S1 = Parameters.Beam.Ext.SBnc;
                SBlt = Parameters.Beam.Ext.SBlt;
                STlt = Parameters.Beam.Ext.STlt;
                y = (Parameters.Beam.Ext.d+Parameters.Deck.Offset + Parameters.Deck.t)/2;
                S2 = Parameters.Beam.Ext.S2;
                A  = Parameters.Beam.Ext.A;
                
            % Extreme fiber stresses for DL1 and DL2 (top, bottom, deck)
            % retaining signs throughout
            DL1s_t(kk,jj) = (((DL1_M1(kk,jj)/-S1)/abs(DL1_M1(kk,jj)/-S1))*(abs(DL1_M1(kk,jj)/-S1)+abs(DL1_M2(kk,jj)/S2))) - (DL1_A(kk,jj)/A);
            DL2s_t(kk,jj) = (DL2_M1(kk,jj) - (DL2_A(kk,jj)*y))/-STlt;
            
            DL1s_b(kk,jj) = (((DL1_M1(kk,jj)/S1)/abs(DL1_M1(kk,jj)/S1))*(abs(DL1_M1(kk,jj)/S1)+abs(DL1_M2(kk,jj)/S2))) - (DL1_A(kk,jj)/A);
            DL2s_b(kk,jj) = (DL2_M1(kk,jj) - (DL2_A(kk,jj)*y))/SBlt;
                
        else % Interior Girder
            
                S1 = Parameters.Beam.Int.SBnc;
                SBlt = Parameters.Beam.Int.SBlt;
                STlt = Parameters.Beam.Int.STlt;
                y = (Parameters.Beam.Int.d+Parameters.Deck.Offset + Parameters.Deck.t)/2;
                S2 = Parameters.Beam.Int.S2;
                A  = Parameters.Beam.Int.A;
                
            % Extreme fiber stresses for DL1 and DL2 (top, bottom, deck)
            DL1s_t(kk,jj) = (((DL1_M1(kk,jj)/-S1)/abs(DL1_M1(kk,jj)/-S1))*(abs(DL1_M1(kk,jj)/-S1)+abs(DL1_M2(kk,jj)/S2))) - (DL1_A(kk,jj)/A);
            DL2s_t(kk,jj) = (DL2_M1(kk,jj) - (DL2_A(kk,jj)*y))/-STlt;
            
            DL1s_b(kk,jj) = (((DL1_M1(kk,jj)/S1)/abs(DL1_M1(kk,jj)/S1))*(abs(DL1_M1(kk,jj)/S1)+abs(DL1_M2(kk,jj)/S2))) - (DL1_A(kk,jj)/A);
            DL2s_b(kk,jj) = (DL2_M1(kk,jj) - (DL2_A(kk,jj)*y))/SBlt;
            
            
        end
    end
end

% Reactions
DL1_Rxns = DLResults(1).NodeRxn(:,:,3);
DL2_Rxns = DLResults(2).NodeRxn(:,:,3);
DL1_Rxns(find(DL1_Rxns < 0)) = 0;
DL2_Rxns(find(DL2_Rxns < 0)) = 0;

for bb = 1:size(DL1_Rxns,1)
    if bb > 1 && bb < size(DL1_Rxns,1) % Interior supports, divide by 2
        DL1_Rxns(bb,:) = DL1_Rxns(bb,:)/2;
        DL2_Rxns(bb,:) = DL2_Rxns(bb,:)/2;
    end
end

% Save to DLResults
DLResults(1).DL_M1 = DL1_M1;
DLResults(1).DL_M2 = DL1_M2;
DLResults(1).DL_A  = DL1_A;
DLResults(2).DL_M1 = DL2_M1;
DLResults(2).DL_M2 = DL2_M2;
DLResults(2).DL_A  = DL2_A;
DLResults(1).DLs_t  = DL1s_t;
DLResults(2).DLs_t  = DL2s_t;
DLResults(1).DLs_b  = DL1s_b;
DLResults(2).DLs_b  = DL2s_b;
DLResults(1).DL_Rxns  = DL1_Rxns;
DLResults(2).DL_Rxns  = DL2_Rxns;


end