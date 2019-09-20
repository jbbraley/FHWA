function [Parameters, exitflag] = RolledGirderDesignASD(Parameters, Options, WShapes, CShapes, LShapes)
Parameters.Design.Type = 'Rolled';

BestA = 100000; % arbitrarily high value
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
    Parameters.Beam.Type = 'Rolled';
    
    %% Depth Criteria
    if Parameters.Deck.CompositeDesign
        if Parameters.Length/30 > Parameters.Beam.d
            continue
        end
        
        if Parameters.Length/25 > Parameters.Beam.d+Parameters.Deck.t
            continue
        end
    else
        if Parameters.Length/30 > Parameters.Beam.d
            continue
        end
    end
    
    %% Version depth
    if MaxDepth < Parameters.Beam.d || MinDepth > Parameters.Beam.d
        continue
    end
    
    %% Call Functions to Determine Diaphragm and Forces Based on Current Section
    Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes);
    Parameters = GetSectionForces(Parameters);
    
    %% Neutral Axis Check - For Composite Design Only
    % Neutral axis check - Use short term composite deck area
    if Parameters.Deck.CompositeDesign == 1 && Parameters.Deck.Ast*Parameters.Deck.t/2 > Parameters.Beam.A*Parameters.Beam.d/2
        continue
    end
    
    %% Deflection criteria
    if Parameters.Deck.CompositeDesign == 1 && Parameters.Beam.IstDelta > Parameters.Beam.Ist
        continue
    elseif Parameters.Deck.CompositeDesign == 0 && Parameters.Beam.IstDelta > Parameters.Beam.Ix
        continue
    end        
    
    %% ASD Moment Criteria
    fI = 0.55*Parameters.Beam.Fy; % 0.55fy
    if (Parameters.Beam.fb5 > fI) || (Parameters.Beam.fb6 > fI)
        continue
    end
        
    if (Parameters.Beam.fb1 > fI) || (Parameters.Beam.fb2 > fI) || (Parameters.Beam.fb3 > fI) || (Parameters.Beam.fb4 > fI)
        continue
    end
    
%     %% Moment Criteria - Deck Compression
%     if Parameters.Deck.CompositeDesign == 1 && Parameters.Beam.fb5 <= 0.40*Parameters.Deck.fc;  
%         continue
%     end
    
    %% Store Best Value so Far
    if Parameters.Beam.A < BestA
        BestBeam = i;
        BestA = Parameters.Beam.A;
    end    
end 

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
        
    exitflag = 1;
else
    exitflag = 0;
end
end % RolledGirderDesign