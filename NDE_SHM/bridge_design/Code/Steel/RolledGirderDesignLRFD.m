function [Parameters, exitflag] = RolledGirderDesignLRFD(Parameters, Options, WShapes, CShapes, LShapes)
Parameters.Design.Type = 'Rolled';
Section = {'Int';'Ext'};

BestA(1:2) = 100000; % arbitrarily high value
BestBeam = 0;

% Longest girder controls on spand to depth ratio
MinDepth = max(Parameters.Length/Parameters.Design.MaxSpantoDepth);
MaxDepth = MinDepth*(1+Options.RolledGirder.Var);

% Beam Section
for jj = 1:2
    Parameters.Beam.(Section{jj}).Des = Section{jj};
    for i=1:216   
        %% Get Beam Properties from AISC
        Parameters.Beam.(Section{jj}).A =  WShapes(i).A;
        Parameters.Beam.(Section{jj}).bf =  WShapes(i).bf;
        Parameters.Beam.(Section{jj}).tf =  WShapes(i).tf;
        Parameters.Beam.(Section{jj}).tw =  WShapes(i).tw;
        Parameters.Beam.(Section{jj}).d =  WShapes(i).d;
        Parameters.Beam.(Section{jj}).I.Ix =  WShapes(i).Ix;
        Parameters.Beam.(Section{jj}).I.Iy =  WShapes(i).Iy;
        Parameters.Beam.(Section{jj}).S.Sx =  WShapes(i).Sx;
        Parameters.Beam.(Section{jj}).ind = Parameters.Beam.(Section{jj}).d-2*Parameters.Beam.(Section{jj}).tf;

        %% Call Functions to Determine Diaphragm and Forces Based on Current Section
        % Section Properties
        Parameters.Beam.(Section{jj}) = GetSectionProperties(Parameters.Beam.(Section{jj}), Parameters, Section{jj});
        % Diaphragm Requirement
        if jj == 1
            Parameters = GetDiaSection(Parameters, CShapes, LShapes, Parameters.Beam.(Section{jj}));
        end
        % Distribution Factors
        [Parameters.Design.DF.(['DF' (Section{jj})]), Parameters.Design.DF.(['DFV' (Section{jj})])] = LRFDDistFact(Parameters, Parameters.Beam.(Section{jj}));
        % Demands
        Parameters.Demands.(Section{jj}).SL = GetSectionForces(Parameters.Beam.(Section{jj}), Parameters, Parameters.Design.Code, Section{jj},1);
        % Capacity
        Parameters.Beam.(Section{jj})= GetLRFDResistance(Parameters.Beam.(Section{jj}),Parameters.Demands.(Section{jj}).SL, Parameters, Section{jj}, []);
        % Compactness
        Parameters.Beam.(Section{jj}) = CompactCheckLRFD(Parameters.Beam.(Section{jj}),Parameters);

        %% Depth Criteria (2.5.2.6.3) 
        if max(Parameters.Length*.033) > Parameters.Beam.(Section{jj}).d
            continue
        end

        if max(Parameters.Length*.040) > Parameters.Beam.(Section{jj}).d+Parameters.Deck.t
            continue
        end   

        %% Version depth
        if MaxDepth < Parameters.Beam.(Section{jj}).d || MinDepth > Parameters.Beam.(Section{jj}).d
            continue
        end

        %% Ductility Requirements (6.10.7.3)
        if Parameters.Beam.(Section{jj}).Dpst >= 0.42*Parameters.Beam.(Section{jj}).Dt
            continue
        end

        %% Web Thickness Criteria (6.7.3)
        if Parameters.Beam.(Section{jj}).tw < 0.3125
            continue
        end

        %% Moment Criteria    
        if Parameters.Beam.(Section{jj}).SectionComp == 1
            % Strength Limit State I for Positive Flexure (6.10.6)
            c(1) = max(Parameters.Demands.(Section{jj}).SL.LRFD.M_pos)-Parameters.Beam.(Section{jj}).Mn_pos; % % 6.10.7.1 for compact sections

            % Service Limit State II for Positive Flexure (6.10.4)
            c(2) = Parameters.Demands.(Section{jj}).SL.LRFD.fbc_pos(2,:)-0.95*Parameters.Beam.Fy;
            c(3) = Parameters.Demands.(Section{jj}).SL.LRFD.fbt_pos(2,:)-0.95*Parameters.Beam.Fy;    

        elseif Parameters.Beam.(Section{jj}).SectionComp == 0
            % Strength Limit State I for Positive Flexure (6.10.6)
            c(1) = Parameters.Demands.(Section{jj}).SL.LRFD.fbc_pos(1,:)-Parameters.Beam.(Section{jj}).Fn_pos; % 6.10.4.2.4
            c(2) = Parameters.Demands.(Section{jj}).SL.LRFD.fbt_pos(1,:)-Parameters.Beam.(Section{jj}).Fn_pos;

            % Service Limit State II for Positive Flexure (6.10.4)
            %Service limit state does not control and therefore does not need to be
            %checked for non-compact sections in positive flexure. (see Commentary
            %section C6.10.4.2.2)

        end

        if any(c>0)
            continue
        end

        %% Shear Criteria
        if max(max(Parameters.Demands.(Section{jj}).SL.LRFD.V)) >= Parameters.Beam.(Section{jj}).Vn
            continue
        end     

        %% Store Best Value so Far
        if Parameters.Beam.(Section{jj}).A < BestA(Parameters.Beam.(Section{jj}).SectionComp)
            BestBeam(Parameters.Beam.(Section{jj}).SectionComp) = i;
            BestA(Parameters.Beam.(Section{jj}).SectionComp) = Parameters.Beam.(Section{jj}).A;
        end
    end 

    % Choose compact or noncompact based on smallest area
    [A, I] = min(BestA);
    BestBeam = BestBeam(I);

    if BestBeam ~= 0
        %% Get Beam Properties from AISC
        Parameters.Beam.(Section{jj}).A =  WShapes(BestBeam).A; 
        Parameters.Beam.(Section{jj}).bf =  WShapes(BestBeam).bf;
        Parameters.Beam.(Section{jj}).tf =  WShapes(BestBeam).tf;
        Parameters.Beam.(Section{jj}).tw =  WShapes(BestBeam).tw;
        Parameters.Beam.(Section{jj}).d =  WShapes(BestBeam).d;
        Parameters.Beam.(Section{jj}).I.Ix =  WShapes(BestBeam).Ix;
        Parameters.Beam.(Section{jj}).I.Iy =  WShapes(BestBeam).Iy;
        Parameters.Beam.(Section{jj}).S.Sx =  WShapes(BestBeam).Sx;
        Parameters.Beam.(Section{jj}).SectionName = WShapes(BestBeam).AISCManualLabel;
        Parameters.Beam.(Section{jj}).Section = [Parameters.Beam.(Section{jj}).bf, Parameters.Beam.(Section{jj}).bf, Parameters.Beam.(Section{jj}).d, Parameters.Beam.(Section{jj}).tf, Parameters.Beam.(Section{jj}).tf, Parameters.Beam.(Section{jj}).tw];

        %% Recalc Diaphragm and Forces Based on Best
        % Section Properties
        Parameters.Beam.(Section{jj}) = GetSectionProperties(Parameters.Beam.(Section{jj}), Parameters, Section{jj});
        % Diaphragm Requirement
        Parameters = GetDiaSection(Parameters, CShapes, LShapes, Parameters.Beam.(Section{jj}));
        % Distribution Factors
        [Parameters.Design.DF.(['DF' (Section{jj})]), Parameters.Design.DF.(['DFV' (Section{jj})])] = LRFDDistFact(Parameters, Parameters.Beam.(Section{jj}));
        % Demands
        Parameters.Demands.(Section{jj}).SL = GetSectionForces(Parameters.Beam.(Section{jj}), Parameters, Parameters.Design.Code, Section{jj},1);
        % Capacity
        Parameters.Beam.(Section{jj})= GetLRFDResistance(Parameters.Beam.(Section{jj}),Parameters.Demands.(Section{jj}).SL, Parameters, Section{jj}, []);
        % Compactness
        Parameters.Beam.(Section{jj}) = CompactCheckLRFD(Parameters.Beam.(Section{jj}),Parameters);

        exitflag(jj) = 1;
    else
        exitflag(jj) = 0;
    end
end
end % RolledGirderDesign