%% GetSectionProperties: Calculates composite & non-composite, short-term & long-term section properties listed below:
    % 1. (y) Moment Arm [in]
    % 2. (I) Moment of Inertia [in^4]
    % 3. (S) Section Modulus [in^3]
    % 4. (A) Cross-section Area [in^2]
    % 4. (be) Effective Width of Deck [in]
    % 5. (A) Effective Area [in^2]
    % 6. (d) Beam depth [in]
    
function Arg = GetSectionProperties(Arg, Parameters, Section)
% Parameters.Beam.Int = GetSectionProperties(Parameters.Beam.Int,Parameters,'Interior')
% Parameters.Beam.Ext = GetSectionProperties(Parameters.Beam.Ext,Parameters,'Exterior')

%%%%%%%%%%%%%%%%%% NON-COMPOSITE SECTION PROPERTIES %%%%%%%%%%%%%%%%%%%%

% Depth of Web
Arg.ind = Arg.d-2*Arg.tf;

% Depth of web in compression in elastic range for non-composite section
Arg.DcNc = Arg.d/2-Arg.tf; %in 

% Moment Arm
Arg.y.yTnc = Arg.d/2;
Arg.y.yBnc = Arg.d/2;

% Moments of Intertia
Arg.I.Ix = 2*(Arg.bf*Arg.tf^3/12+Arg.bf*Arg.tf*(Arg.tf/2+Arg.ind/2)^2)+Arg.tw*Arg.ind^3/12;
Arg.I.Iyc = Arg.tf*Arg.bf^3/12; %Moment of Inertia of the compression flange
Arg.I.Iyt = Arg.I.Iyc; %Moment of Inertia of the Tension Flange (same as compression flange b/c symetrical cross section)
Arg.I.Iy = 2*Arg.tf*Arg.bf^3/12+(Arg.ind)*Arg.tw^3/12; %Moment of inertia of the entire steel section

% Section Modulus
Arg.S.STnc = Arg.I.Ix/Arg.y.yTnc;
Arg.S.SBnc = Arg.I.Ix/Arg.y.yBnc;
Arg.S.S2 = Arg.I.Iy/(Arg.bf/2);

% Section Area
Arg.A = 2*Arg.bf*Arg.tf + Arg.tw*Arg.ind;
    
% For multiple span continuous models    
if Parameters.Spans > 1
    if Arg.CoverPlate.Length > 0 % For models with a coverplate
        % Total Beam Depth
        Arg.CoverPlate.d = Arg.d + 2*Arg.CoverPlate.t;

        % Depth of Web
        Arg.CoverPlate.ind = Arg.CoverPlate.d-2*Arg.CoverPlate.tf;

        % Depth of web in compression in elastic range for non-composite section
        Arg.CoverPlate.DcNc = Arg.CoverPlate.d/2-Arg.CoverPlate.tf; %in 

        % Moment Arm
        Arg.CoverPlate.y.yTnc = Arg.CoverPlate.d/2;
        Arg.CoverPlate.y.yBnc = Arg.CoverPlate.d/2;

        % Moment of Interia
        Arg.CoverPlate.I.Ix = 2*(Arg.CoverPlate.bf*Arg.CoverPlate.tf^3/12+Arg.CoverPlate.bf*Arg.CoverPlate.tf*(Arg.CoverPlate.tf/2+...
            Arg.CoverPlate.ind/2)^2)+Arg.CoverPlate.tw*Arg.CoverPlate.ind^3/12;
        Arg.CoverPlate.I.Iyc = Arg.CoverPlate.tf*Arg.CoverPlate.bf^3/12; %Moment of Inertia of the compression flange
        Arg.CoverPlate.I.Iyt = Arg.CoverPlate.I.Iyc; %Moment of Inertia of the Tension Flange (same as compression flange b/c symetrical cross section)
        Arg.CoverPlate.I.Iy = 2*Arg.CoverPlate.tf*Arg.CoverPlate.bf^3/12+(Arg.CoverPlate.d...
            -2*Arg.CoverPlate.tf)*Arg.CoverPlate.tw^3/12; %Moment of inertia of the entire steel section

        % Section Modulus
        Arg.CoverPlate.S.STnc = Arg.CoverPlate.I.Ix/Arg.CoverPlate.y.yTnc;
        Arg.CoverPlate.S.SBnc = Arg.CoverPlate.I.Ix/Arg.CoverPlate.y.yBnc;
        Arg.CoverPlate.S.S2 = Arg.CoverPlate.I.Iy/(Arg.CoverPlate.bf/2);

        % Section Area
        Arg.CoverPlate.A = 2*Arg.CoverPlate.bf*Arg.CoverPlate.tf...
            +Arg.CoverPlate.tw*Arg.CoverPlate.ind;
    end
end

%%%%%%%%%%%%%%%%%%%% COMPOSITE SECTION PROPERTIES %%%%%%%%%%%%%%%%%%%%%%

if Parameters.Deck.CompositeDesign == 1
    
    % Total Depth of Composite Section
    Arg.Dt = Arg.d+Parameters.Deck.t+Parameters.Deck.Offset;

    switch Section
        case 'Int'
            Ast = Parameters.Deck.A.AInt_st;
            Alt = Parameters.Deck.A.AInt_lt;
        case 'Ext'
            Ast = Parameters.Deck.A.AExt_st;
            Alt = Parameters.Deck.A.AExt_lt;
        case 'Rolled'
            Ast = Parameters.Deck.A.AInt_st;
            Alt = Parameters.Deck.A.AInt_lt;
        case 'Manual Assign'
            Ast = Parameters.Deck.A.AInt_st;
            Alt = Parameters.Deck.A.AInt_lt;           
    end

    % Determine distances from centroid of composite short/long-term section to top, bottom
    % and deck(bottom of girder is reference axis). 

    % Short-term 
        yBst = (Ast*(Parameters.Deck.t/2 + Parameters.Deck.Offset + Arg.d) + Arg.A*Arg.y.yBnc)/(Ast+Arg.A); % formula to find centroid: y = sum(Ai*yi)/sum(Ai)
        if yBst > Arg.d % Elastic Neutral Axis is in the deck
            Arg.y.yBst = yBst; 
            Arg.y.yTst = yBst - Arg.d;
            Arg.y.yDst = Arg.Dt - yBst; 
        elseif yBst < Arg.d % Elastic Neutral Axis is in the steel
            Arg.y.yBst = yBst; 
            Arg.y.yTst = Arg.d - yBst;
            Arg.y.yDst = Arg.Dt - yBst; 
        end
    % Long-term
        yBlt = (Alt*(Parameters.Deck.t/2 + Parameters.Deck.Offset + Arg.d) + Arg.A*Arg.y.yBnc)/(Alt+Arg.A); % formula to find centroid: y = sum(Ai*yi)/sum(Ai)
        if yBlt > Arg.d % Elastic Neutral Axis is in the deck
            Arg.y.yBlt = yBlt;
            Arg.y.yTlt = yBlt - Arg.d;
            Arg.y.yDlt = Arg.Dt - yBlt; 
        elseif yBlt < Arg.d % Elastic Neutral Axis is in the steel
            Arg.y.yBlt = yBlt;
            Arg.y.yTlt = Arg.d - yBlt;
            Arg.y.yDlt = Arg.Dt - yBlt; 
        end

    % Caclulate short-term and long term moments of inertia 

    % Short-Term 
    Arg.I.Ist = Arg.I.Ix + Arg.A*(Arg.y.yBst-Arg.d/2)^2 +...
        Ast*Parameters.Deck.t^2/12 + Ast*(Arg.y.yDst - Parameters.Deck.t/2)^2;   
    % Long-Term 
    Arg.I.Ilt=  Arg.I.Ix + Arg.A*(Arg.y.yBlt-Arg.d/2)^2 +...
        Alt*Parameters.Deck.t^2/12 + Alt*(Arg.y.yDlt - Parameters.Deck.t/2)^2;

    % Caclulate short-term and long-term elastic section modulii 

    % Short-Term 
    Arg.S.SDst = Arg.I.Ist/Arg.y.yDst;
    Arg.S.STst = Arg.I.Ist/Arg.y.yTst;
    Arg.S.SBst = Arg.I.Ist/Arg.y.yBst;
    % Long-Term 
    Arg.S.SDlt = Arg.I.Ilt/Arg.y.yDlt;
    Arg.S.STlt = Arg.I.Ilt/Arg.y.yTlt;
    Arg.S.SBlt = Arg.I.Ilt/Arg.y.yBlt;

end
       
end




