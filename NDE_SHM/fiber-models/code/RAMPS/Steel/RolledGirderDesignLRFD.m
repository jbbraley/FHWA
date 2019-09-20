function [Parameters, exitflag] = RolledGirderDesignLRFD(Parameters, Options, WShapes, CShapes, LShapes)
Parameters.Design.Type = 'Rolled';

BestA(1:2) = 100000; % arbitrarily high value
BestBeam = 0;

% Longest girder controls on spand to depth ratio
MinDepth = max(Parameters.Length/Parameters.Design.MaxSpantoDepth);
MaxDepth = MinDepth*(1+Options.RolledGirder.Var);

% Beam Section
for i=1:216   
    %% Get Beam Properties from AISC
    Parameters.Beam.A =  WShapes(i).A;
    Parameters.Beam.bf =  WShapes(i).bf;
    Parameters.Beam.tf =  WShapes(i).tf;
    Parameters.Beam.tw =  WShapes(i).tw;
    Parameters.Beam.d =  WShapes(i).d;
    Parameters.Beam.Ix =  WShapes(i).Ix;
    Parameters.Beam.Iy =  WShapes(i).Iy;
    Parameters.Beam.Sx =  WShapes(i).Sx;
    Parameters.Beam.ind = Parameters.Beam.d-2*Parameters.Beam.tf;
    Parameters.Beam.Type = 'Rolled';
    
    
    %% Call Functions to Determine Diaphragm and Forces Based on Current Section
    Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
    Parameters = GetSectionForces(Parameters);
    Parameters = GetLRFDResistance(Parameters);
    
    %% Beam compact requirements 1 = compact; 2 = noncompact
    if 2*Parameters.Beam.Dcp/Parameters.Beam.tw <= 3.76*sqrt(Parameters.Beam.E/Parameters.Beam.Fy) &&...
            Parameters.Beam.ind/Parameters.Beam.tw <= 150           
        Parameters.Beam.Comp = 1;
    else
        Parameters.Beam.Comp = 2;
    end

    %% Depth Criteria (2.5.2.6.3) 
    if max(Parameters.Length*.033) > Parameters.Beam.d
        continue
    end

    if max(Parameters.Length*.040) > Parameters.Beam.d+Parameters.Deck.t
        continue
    end   
    
    %     % OLD DEPTH CRITERIA
    %     if Parameters.Length/30 > Parameters.Beam.d
    %         continue
    %     end
    %     if Parameters.Length/25 > Parameters.Beam.d+Parameters.Deck.t
    %         continue
    %     end
    
    %% Version depth
    if MaxDepth < Parameters.Beam.d || MinDepth > Parameters.Beam.d
        continue
    end
    
    %% Ductility Requirements (6.10.7.3)
    if Parameters.Beam.Dpst >= 0.42*Parameters.Beam.D
        continue
    end
    
    %% Web Thickness Criteria (6.7.3)
    if Parameters.Beam.tw < 0.3125
        continue
    end
  
    %% NEUTRAL AXIS CHECK AND DEFLECTION CHECK NOT FOUND IN LRFD.

    %     %% Neutral Axis Check - For Composite Design Only
    %     % Neutral axis check - Use short term composite deck area
    %     if Parameters.Deck.Ast*Parameters.Deck.t/2 > Parameters.Beam.A*Parameters.Beam.d/2
    %         continue
    %     end
    %         
    %     %% Deflection criteria
    %     if Parameters.Beam.IstDelta > Parameters.Beam.Ist
    %         continue
    %     end

    %% Web and Flange Proportion Checks (6.10.2)
    % All rolled section satisfy web and flange proportion checks.
    
    %% Moment Criteria    
    if Parameters.Beam.Comp == 1
        % Strength Limit State I for Positive Flexure (6.10.6)
        c(1) = max(Parameters.LRFD.M_pos)-Parameters.Beam.Mn_pos; % % 6.10.7.1 for compact sections
       
        % Service Limit State II for Positive Flexure (6.10.4)
        c(2) = Parameters.Beam.fbc_pos(2,:)-0.95*Parameters.Beam.Fy;
        c(3) = Parameters.Beam.fbt_pos(2,:)-0.95*Parameters.Beam.Fy;    
        
    elseif Parameters.Beam.Comp == 2
        % Strength Limit State I for Positive Flexure (6.10.6)
        c(1) = Parameters.Beam.fbc_pos(1,:)-Parameters.Beam.Fn_pos; % 6.10.4.2.4
        c(2) = Parameters.Beam.fbt_pos(1,:)-Parameters.Beam.Fn_pos;
        
        % Service Limit State II for Positive Flexure (6.10.4)
        %Service limit state does not control and therefore does not need to be
        %checked for non-compact sections in positive flexure. (see Commentary
        %section C6.10.4.2.2)
        
    end
    
    if any(c>0)
        continue
    end
    
    %% Shear Criteria
    if max(max(Parameters.LRFD.V)) >= Parameters.Beam.Vn
        continue
    end     
   
    %% Store Best Value so Far
    if Parameters.Beam.A < BestA(Parameters.Beam.Comp)
        BestBeam(Parameters.Beam.Comp) = i;
        BestA(Parameters.Beam.Comp) = Parameters.Beam.A;
    end
end 

% Choose compact or noncompact based on smallest area
[A, I] = min(BestA);
BestBeam = BestBeam(I);

if BestBeam ~= 0
    %% Get Beam Properties from AISC
    Parameters.Beam.A =  WShapes(BestBeam).A; 
    Parameters.Beam.bf =  WShapes(BestBeam).bf;
    Parameters.Beam.tf =  WShapes(BestBeam).tf;
    Parameters.Beam.tw =  WShapes(BestBeam).tw;
    Parameters.Beam.d =  WShapes(BestBeam).d;
    Parameters.Beam.Ix =  WShapes(BestBeam).Ix;
    Parameters.Beam.Iy =  WShapes(BestBeam).Iy;
    Parameters.Beam.Sx =  WShapes(BestBeam).Sx;
    Parameters.Beam.SectionName = WShapes(BestBeam).AISCManualLabel;
    Parameters.Beam.Section = [Parameters.Beam.bf, Parameters.Beam.bf, Parameters.Beam.d, Parameters.Beam.tf, Parameters.Beam.tf, Parameters.Beam.tw];
    Parameters.Beam.Type = 'Rolled';
    
    %% Recalc Diaphragm and Forces Based on Best
    Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
    Parameters = GetSectionForces(Parameters); 
    Parameters = GetLRFDResistance(Parameters);

    exitflag = 1;
else
    exitflag = 0;
end
end % RolledGirderDesign