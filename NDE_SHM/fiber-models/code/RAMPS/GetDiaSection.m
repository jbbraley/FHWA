function Parameters = GetDiaSection(Parameters, DiaShapes)
%% Diaphragm Section Property Assignment
switch Parameters.Dia.Type
    case 'Beam'
        %% Find Most Beam Efficient Section
        BestItemID = 0;
        BestBeamA = 1000000;
      
        % Beam Section
        for i=1:31
            CurrentBeamA = DiaShapes(i).A;
            CurrentBeamd = DiaShapes(i).d;
            
            if Parameters.Dia.Force/CurrentBeamA > 0.55*36000; % 0.55fy
                continue
            end
            
            if CurrentBeamd < Parameters.Dia.Req
                continue
            end
            
            if CurrentBeamA > BestBeamA
                continue
            end
            
            % Decides if last beam or current beam is better. Makes last beam the
            % current beam if it is not better so it can send it to the next
            % iteration
            BestItemID = i;
            BestBeamA = CurrentBeamA;            
        end

        Parameters.Dia.A = DiaShapes(BestItemID).A;
        Parameters.Dia.bf = DiaShapes(BestItemID).bf;
        Parameters.Dia.tf = DiaShapes(BestItemID).tf;
        Parameters.Dia.tw = DiaShapes(BestItemID).tw;
        Parameters.Dia.d = DiaShapes(BestItemID).d;
        Parameters.Dia.SectionName = DiaShapes(BestItemID).AISCManualLabel;
        Parameters.Dia.Section = [Parameters.Dia.bf, Parameters.Dia.d, 0, Parameters.Dia.tf, Parameters.Dia.tw, 0];  
    case 'Cross'
        %% Find Most Efficient Angle Section
        BestItemID = 0;
        BestBeamA = 1000000;
        
        % Angle Section
        for i=1:127
            CurrentBeamrx = DiaShapes(i).rx;
            CurrentBeamA = DiaShapes(i).A;
            
            if Parameters.Dia.Force/(CurrentBeamA*2 + CurrentBeamA*2*Parameters.GirderSpacing/sqrt(Parameters.GirderSpacing^2+Parameters.Beam.d^2)) > 0.55*36000; % 0.55fy
                continue
            end
            
            if CurrentBeamrx < Parameters.Dia.Req
                continue
            end
            
            if CurrentBeamA > BestBeamA
                continue
            end
            
            % Decides if last beam or current beam is better. Makes last beam the
            % current beam if it is not better so it can send it to the next
            % iteration
            BestItemID = i;
            BestBeamA = CurrentBeamA;           
        end
        
        if BestItemID == 0
            
        end
        
        Parameters.Dia.A = DiaShapes(BestItemID).A;
        Parameters.Dia.B = DiaShapes(BestItemID).B;
        Parameters.Dia.d = DiaShapes(BestItemID).d;
        Parameters.Dia.t = DiaShapes(BestItemID).t;
        Parameters.Dia.SectionName = DiaShapes(BestItemID).AISCManualLabel;
        Parameters.Dia.Section = [Parameters.Dia.B, Parameters.Dia.d, 0, Parameters.Dia.t, Parameters.Dia.t, 0];
end
end %GetDiaSection