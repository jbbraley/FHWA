function [SResults] = NCHRP_ProcessSR_v2(SResults,Parameters)

% _v2: fixed issue with determination of cover plate location 

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
if Parameters.Spans == 2
    Sett_M1 = cat(1,sett_m1(1:end-1,:,1),sett_m1(1:end-1,:,2));
    Sett_M2 = cat(1,sett_m2(1:end-1,:,1),sett_m2(1:end-1,:,2));
    Sett_A  = cat(1,sett_a(1:end-1,:,1),sett_a(1:end-1,:,2));
elseif Parameters.Spans == 3
    Sett_M1 = cat(1,sett_m1(1:end-1,:,1),sett_m1(1:end-1,:,2),sett_m1(1:end-1,:,3));
    Sett_M2 = cat(1,sett_m2(1:end-1,:,1),sett_m2(1:end-1,:,2),sett_m2(1:end-1,:,3));
    Sett_A  = cat(1,sett_a(1:end-1,:,1),sett_a(1:end-1,:,2),sett_a(1:end-1,:,3));
else
    Sett_M1 = sett_m1(1:end,:,1);
    Sett_M2 = sett_m2(1:end,:,1);
    Sett_A  = sett_a(1:end,:,1);
end

% Calculate extreme fiber stress
for kk = 1:length(Sett_M1) % loop through individual elements
    
    for jj = 1:Parameters.NumGirder % loop through girder locations
        
        % Determine if interior or exterior girder
        if jj == 1 || jj == Parameters.NumGirder % Exterior Girder
            
            % define section properties dependent on location
            if find(kk >= lb & kk <= ub) % Coverplate region
                S1 = Parameters.Beam.Ext.CoverPlate.S.STnc;
                S2 = Parameters.Beam.Ext.CoverPlate.S.S2;
                A  = Parameters.Beam.Ext.CoverPlate.A;
            else % Non-coverplate region, Positive moment region considered composite
                S1 = Parameters.Beam.Ext.S.SBlt;
                S2 = Parameters.Beam.Ext.S.S2;
                A  = Parameters.Beam.Ext.A;
            end
                
            % Extreme fiber stresses for DL1 and DL2 (top, bottom, deck)
            % retaining signs throughout
            Setts_t(kk,jj) = (((Sett_M1(kk,jj)/-S1)/abs(Sett_M1(kk,jj)/-S1))*(abs(Sett_M1(kk,jj)/-S1)+abs(Sett_M2(kk,jj)/S2))) - (Sett_A(kk,jj)/A);

            Setts_b(kk,jj) = (((Sett_M1(kk,jj)/S1)/abs(Sett_M1(kk,jj)/S1))*(abs(Sett_M1(kk,jj)/S1)+abs(Sett_M2(kk,jj)/S2))) - (Sett_A(kk,jj)/A);

        else % Interior Girder
            
            % define section properties dependent on location
            if find(kk >= lb & kk <= ub) % Coverplate region
                S1 = Parameters.Beam.Int.CoverPlate.S.STnc;
                S2 = Parameters.Beam.Int.CoverPlate.S.S2;
                A  = Parameters.Beam.Int.CoverPlate.A;
            else % Non-coverplate region, Positive moment region considered composite
                S1 = Parameters.Beam.Int.S.SBlt;
                S2 = Parameters.Beam.Int.S.S2;
                A  = Parameters.Beam.Int.A;
            end
                
            % Extreme fiber stresses for DL1 and DL2 (top, bottom, deck)
            Setts_t(kk,jj) = (((Sett_M1(kk,jj)/-S1)/abs(Sett_M1(kk,jj)/-S1))*(abs(Sett_M1(kk,jj)/-S1)+abs(Sett_M2(kk,jj)/S2))) - (Sett_A(kk,jj)/A);

            Setts_b(kk,jj) = (((Sett_M1(kk,jj)/S1)/abs(Sett_M1(kk,jj)/S1))*(abs(Sett_M1(kk,jj)/S1)+abs(Sett_M2(kk,jj)/S2))) - (Sett_A(kk,jj)/A);

        end
    end
end

% Reactions
Sett_Rxns = SResults.NodeRxn(:,:,3);

for bb = 1:size(Sett_Rxns,1)
    if bb > 1 || bb < size(Sett_Rxns,1) % Interior supports, divide by 2
        Sett_Rxns(bb,:) = Sett_Rxns(bb,:)/2;
    end
end

                    

% Save to DLResults
SResults(1).Sett_M1 = Sett_M1;
SResults(1).Sett_M2 = Sett_M2;
SResults(1).Sett_A  = Sett_A;
SResults(1).Setts_t  = Setts_t;
SResults(1).Setts_b  = Setts_b;
SResults(1).Sett_Rxns  = Sett_Rxns;

end