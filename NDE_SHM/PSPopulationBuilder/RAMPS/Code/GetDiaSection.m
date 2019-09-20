function Parameters = GetDiaSection(Parameters, CShapes, LShapes, Beam)

if strcmp(Parameters.Dia.Assign, 'Auto')
    % Aspect Ratio
    ratio = Parameters.GirderSpacing/Beam.d;
    
    % Effective Length Factor
    K = 1.0;
    
    % Limiting Slenderness and Unbraced Length (of bracing)
    if Parameters.SkewNear < 20
        sLimit = 140;
        L = sqrt(Parameters.GirderSpacing^2+Beam.d^2);
    else
        sLimit = 120;
        L = sqrt((Parameters.GirderSpacing/cos(Parameters.SkewNear*pi()/180))^2+Beam.d^2);
    end
    
    % Assign Dia Types and calculate radius of gyration
    if Beam.d <= 30 % Use C-Beam Bracing
        Parameters.Dia.Type = 'Beam';
        Parameters.Dia.Req = Beam.d/2;
        DiaShapes = CShapes;
    elseif ratio > 1.5 % Use k-Type (Chevron) cross frame
        Parameters.Dia.Type = 'Chevron';
        DiaShapes = LShapes;
        if strcmp(Parameters.Dia.Config,'Normal') 
            Parameters.Dia.Req = K*L/sLimit; %Requirement is radius of gyration 
        elseif strcmp(Parameters.Dia.Config,'Parallel')
            Parameters.Dia.Req = K*L/sLimit;
        end
    else % Use X-type cross frame
        Parameters.Dia.Type = 'Cross';
        DiaShapes = LShapes;
        if strcmp(Parameters.Dia.Config,'Normal') 
            Parameters.Dia.Req = K*L/sLimit; %Requirement is radius of gyration 
        elseif strcmp(Parameters.Dia.Config,'Parallel')
            Parameters.Dia.Req = K*L/sLimit;
        end
    end
end

% Wind Force Calculatios
% Velocity Assumptions
Vo = 12.0; %MPH (largest for city) T3.8.1.1-1
Zo = 8.20; %ft (largest for city) T3.8.1.1-1
Z = 30; %ft, Assumed height of structure above low ground or water level
V30 = 100; %MPH, Assumed fastest wind speed at Z
Vb = V30; % Assumed in absence of better criterion 3.8.1.1

% Design wind velocity
Vdz = 2.5*Vo*(V30/Vb)*log(Z/Zo); %MPH

% Wind Pressure on Structure
Pb = 0.050; %ksf, Base pressure for beams
Pd = Pb*(Vdz^2)/10000; %ksf, design wind pressure

% Wind force per unit length
W = (1.40*Beam.d*Pd*1000)/(2*144); %lb/in

Parameters.Dia.Force = W*max(Parameters.Length)/(Parameters.NumDia + 1); %lbs

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
            
            if Parameters.Dia.Force/CurrentBeamA > 0.55*Parameters.Dia.Fy; % 0.55fy
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
            
            if Parameters.Dia.Force/(CurrentBeamA*2 + CurrentBeamA*2*Parameters.GirderSpacing/sqrt(Parameters.GirderSpacing^2+Beam.d^2)) > 0.55*Parameters.Dia.Fy; % 0.55fy
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
        case 'Chevron'
        %% Find Most Efficient Angle Section
        BestItemID = 0;
        BestBeamA = 1000000;
        
        % Angle Section
        for i=1:127
            CurrentBeamrx = DiaShapes(i).rx;
            CurrentBeamA = DiaShapes(i).A;
            
            if Parameters.Dia.Force/(CurrentBeamA*2 + CurrentBeamA*2*Parameters.GirderSpacing/sqrt(Parameters.GirderSpacing^2+Beam.d^2)) > 0.55*Parameters.Dia.Fy; % 0.55fy
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