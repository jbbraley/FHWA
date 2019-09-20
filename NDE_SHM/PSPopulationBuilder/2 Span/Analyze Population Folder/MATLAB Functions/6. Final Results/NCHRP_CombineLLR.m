function [LLResults] = NCHRP_CombineLLR(LLResults,Parameters)

% Establish bounds of coverplate region
SpanLength = round(Parameters.Length/12)'; %[ft]
Fixed = zeros(Parameters.Spans, 1);
for f = 1:Parameters.Spans
    Fixed(f) = sum(SpanLength(1:f));
end
Fixed = [1; Fixed + 1];

lb = floor(Fixed(2:end-1)-(Parameters.Beam.Int.CoverPlate.Ratio*max(Parameters.Length/12)));
ub = ceil(Fixed(2:end-1)+(Parameters.Beam.Int.CoverPlate.Ratio*max(Parameters.Length/12))-1);

%% LIVE LOAD --------------------------------------------------------------

% Get envelope responses (max and min) of all LL combinations
maxLL_M1 = cat(1,max(max(max(LLResults.TotalCombinedLoads(1:end-1,:,1,:,:,:,2),[],4),[],5),[],6),...
    max(max(max(LLResults.TotalCombinedLoads(1:end-1,:,2,:,:,:,2),[],4),[],5),[],6));

maxLL_M2 = cat(1,max(max(max(LLResults.TotalCombinedLoads(1:end-1,:,1,:,:,:,3),[],4),[],5),[],6),...
    max(max(max(LLResults.TotalCombinedLoads(1:end-1,:,2,:,:,:,3),[],4),[],5),[],6));

maxLL_A = cat(1,max(max(max(LLResults.TotalCombinedLoads(1:end-1,:,1,:,:,:,1),[],4),[],5),[],6),...
    max(max(max(LLResults.TotalCombinedLoads(1:end-1,:,2,:,:,:,1),[],4),[],5),[],6));

minLL_M1 = cat(1,min(min(min(LLResults.TotalCombinedLoads(1:end-1,:,1,:,:,:,2),[],4),[],5),[],6),...
    min(min(min(LLResults.TotalCombinedLoads(1:end-1,:,2,:,:,:,2),[],4),[],5),[],6));

minLL_M2 = cat(1,min(min(min(LLResults.TotalCombinedLoads(1:end-1,:,1,:,:,:,3),[],4),[],5),[],6),...
    min(min(min(LLResults.TotalCombinedLoads(1:end-1,:,2,:,:,:,3),[],4),[],5),[],6));

minLL_A = cat(1,min(min(min(LLResults.TotalCombinedLoads(1:end-1,:,1,:,:,:,1),[],4),[],5),[],6),...
    min(min(min(LLResults.TotalCombinedLoads(1:end-1,:,2,:,:,:,1),[],4),[],5),[],6));

% Get absolute maximum response value for each beam element
for xx = 1:length(maxLL_M1)
    
    for yy = 1:Parameters.NumGirder
        
        % In-Plane Bending Moment
        if max(abs(maxLL_M1(xx,yy))) > max(abs(minLL_M1(xx,yy)))
            LL_M1(xx,yy) = maxLL_M1(xx,yy);       
        else
            LL_M1(xx,yy) = minLL_M1(xx,yy);
        end
        
        % Out-of-Plane Bending Moment
        if max(abs(maxLL_M2(xx,yy))) > max(abs(minLL_M2(xx,yy)))
            LL_M2(xx,yy) = maxLL_M2(xx,yy); 
        else
            LL_M2(xx,yy) = minLL_M2(xx,yy);
        end
        
        % Axial Force
        if max(abs(maxLL_A(xx,yy))) > max(abs(minLL_A(xx,yy)))
            LL_A(xx,yy) = maxLL_A(xx,yy);   
        else
            LL_A(xx,yy) = minLL_A(xx,yy); 
        end
        
    end
end

% Calculate extreme fiber stress
for kk = 1:length(LL_M1) % loop through individual elements
    
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
                
            % Extreme fiber stresses for LL and LL (top, bottom, deck)
            % retaining signs throughout
            LLs_t(kk,jj) = (((LL_M1(kk,jj)/-S1)/abs(LL_M1(kk,jj)/-S1))*(abs(LL_M1(kk,jj)/-S1)+abs(LL_M2(kk,jj)/S2))) - (LL_A(kk,jj)/A);
            
            LLs_b(kk,jj) = (((LL_M1(kk,jj)/S1)/abs(LL_M1(kk,jj)/S1))*(abs(LL_M1(kk,jj)/S1)+abs(LL_M2(kk,jj)/S2))) - (LL_A(kk,jj)/A);
            
            LLs_d(kk,jj) = (LLs_t(kk,jj)/Parameters.Beam.E)*(1+(2*Parameters.Deck.t/Parameters.Beam.Ext.CoverPlate.d))*Parameters.Deck.E;

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
                
            % Extreme fiber stresses for LL and LL (top, bottom, deck)
            LLs_t(kk,jj) = (((LL_M1(kk,jj)/-S1)/abs(LL_M1(kk,jj)/-S1))*(abs(LL_M1(kk,jj)/-S1)+abs(LL_M2(kk,jj)/S2))) - (LL_A(kk,jj)/A);

            LLs_b(kk,jj) = (((LL_M1(kk,jj)/S1)/abs(LL_M1(kk,jj)/S1))*(abs(LL_M1(kk,jj)/S1)+abs(LL_M2(kk,jj)/S2))) - (LL_A(kk,jj)/A);

            LLs_d(kk,jj) = (LLs_t(kk,jj)/Parameters.Beam.E)*(1+(2*Parameters.Deck.t/Parameters.Beam.Int.CoverPlate.d))*Parameters.Deck.E;

        end
    end
end

% Reactions
LL_Rxns = max(max(max(LLResults.TotalCombinedRxns(:,:,3,:,:,:),[],4),[],5),[],6);
LL_Rxns(2,:) = LL_Rxns(2,:)/2;
LL_Rxns(find(LL_Rxns < 0)) = 0;


% Save to LLResults
LLResults(1).LL_M1 = LL_M1;
LLResults(1).LL_M2 = LL_M2;
LLResults(1).LL_A  = LL_A;
LLResults(1).LLs_t  = LLs_t;
LLResults(1).LLs_b  = LLs_b;
LLResults(1).LLs_d  = LLs_d;
LLResults(1).LL_Rxns  = LL_Rxns;

end