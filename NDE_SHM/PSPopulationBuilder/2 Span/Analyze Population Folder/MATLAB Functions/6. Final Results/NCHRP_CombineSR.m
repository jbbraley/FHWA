function [SResults] = NCHRP_CombineSR(SResults,Parameters)

% Establish bounds of coverplate region
SpanLength = round(Parameters.Length/12)'; %[ft]
Fixed = zeros(Parameters.Spans, 1);
for f = 1:Parameters.Spans
    Fixed(f) = sum(SpanLength(1:f));
end
Fixed = [1; Fixed + 1];

lb = floor(Fixed(2:end-1)-(Parameters.Beam.Int.CoverPlate.Ratio*max(Parameters.Length/12)));
ub = ceil(Fixed(2:end-1)+(Parameters.Beam.Int.CoverPlate.Ratio*max(Parameters.Length/12))-1);

% SETTLEMENT --------------------------------------------------------------


% Get M1(4), M2(6), and A(1) responses
sett_m1 = SResults.BeamForce(:,:,:,4); % Sett Moment Major Axis
sett_m2 = SResults.BeamForce(:,:,:,6); % Sett Moment Minor Axis
sett_a  = SResults.BeamForce(:,:,:,1); % Sett Axial

% Concatenate dimensions for spans
Sett_M1 = cat(1,sett_m1(1:end-1,:,1),sett_m1(1:end-1,:,2));
Sett_M2 = cat(1,sett_m2(1:end-1,:,1),sett_m2(1:end-1,:,2));
Sett_A  = cat(1,sett_a(1:end-1,:,1),sett_a(1:end-1,:,2));

% Calculate extreme fiber stress
for kk = 1:length(Sett_M1) % loop through individual elements
    
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
            Setts_t(kk,jj) = (((Sett_M1(kk,jj)/-S1)/abs(Sett_M1(kk,jj)/-S1))*(abs(Sett_M1(kk,jj)/-S1)+abs(Sett_M2(kk,jj)/S2))) - (Sett_A(kk,jj)/A);

            Setts_b(kk,jj) = (((Sett_M1(kk,jj)/S1)/abs(Sett_M1(kk,jj)/S1))*(abs(Sett_M1(kk,jj)/S1)+abs(Sett_M2(kk,jj)/S2))) - (Sett_A(kk,jj)/A);

            Setts_d(kk,jj) = (Setts_t(kk,jj)/Parameters.Beam.E)*(1+(2*Parameters.Deck.t/Parameters.Beam.Ext.CoverPlate.d))*Parameters.Deck.E;

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
            Setts_t(kk,jj) = (((Sett_M1(kk,jj)/-S1)/abs(Sett_M1(kk,jj)/-S1))*(abs(Sett_M1(kk,jj)/-S1)+abs(Sett_M2(kk,jj)/S2))) - (Sett_A(kk,jj)/A);

            Setts_b(kk,jj) = (((Sett_M1(kk,jj)/S1)/abs(Sett_M1(kk,jj)/S1))*(abs(Sett_M1(kk,jj)/S1)+abs(Sett_M2(kk,jj)/S2))) - (Sett_A(kk,jj)/A);

            Setts_d(kk,jj) = (Setts_t(kk,jj)/Parameters.Beam.E)*(1+(2*Parameters.Deck.t/Parameters.Beam.Int.CoverPlate.d))*Parameters.Deck.E;

        end
    end
end

% Reactions
Sett_Rxns = SResults.NodeRxn(:,:,3);
Sett_Rxns(2,:) = Sett_Rxns(2,:)/2;
                    

% Save to DLResults
SResults(1).Sett_M1 = Sett_M1;
SResults(1).Sett_M2 = Sett_M2;
SResults(1).Sett_A  = Sett_A;
SResults(1).Setts_t  = Setts_t;
SResults(1).Setts_b  = Setts_b;
SResults(1).Setts_d  = Setts_d;
SResults(1).Sett_Rxns  = Sett_Rxns;

end