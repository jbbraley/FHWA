function [DF, DFV] = LRFDDistFact( Parameters )
%Distribution Factors

eg = Parameters.Beam.d/2+Parameters.Deck.t/2;

SpanLength = Parameters.Length/12;
DFLever = LeverRule(Parameters);

%Longitudinal stiffness parameter
Kg = Parameters.Beam.E/Parameters.Deck.E*(Parameters.Beam.Ix+Parameters.Beam.A*(eg)^2);

%% Distribution of Live Loads per Lane for Moment in Interior Longitudinal Beams
DFint1 = 0.06 + (Parameters.GirderSpacing/12/14)^(0.4)*(Parameters.GirderSpacing/12./SpanLength).^(0.2).*(Kg./(12*Parameters.Deck.t^3*SpanLength)).^(0.1);
DFint2 = 0.075 + (Parameters.GirderSpacing/12/9.5)^(0.6)*(Parameters.GirderSpacing/12./SpanLength).^(0.2).*(Kg./(12*Parameters.Deck.t^3*SpanLength)).^(0.1);

if min(Parameters.GirderSpacing)<3.5*12 || max(Parameters.GirderSpacing)>16*12
    DFint = DFLever;
    DFint(2) = DFint;
else
    if Parameters.NumGirder == 3
        DFint = min(DFint1, DFint2, DFLever);
        DFint(2) = DFint;
    else
        DFint = DFint1;
        DFint(2) = min(DFint2);
    end
end
%% Distribution of Live Loads per Lane for Moment in Exterior Longitudinal Beams

% Distance from exterior web of exterior beam and the interior edge of curb
% or traffic barrier
de = (max(Parameters.Sidewalk.Right, Parameters.Sidewalk.Left)+Parameters.Barrier.Width-Parameters.Overhang)/12;
e = 0.77 + de/9.1;

if Parameters.NumGirder == 3
    DFext = min(DFint*e,DFLever);
    DFext(2) = DFext;
else 
    DFext = DFint*e;
    DFext(2) = DFLever;
end

%% Reduction of Load Distribution Factors for skewed supports
if abs(Parameters.SkewNear-Parameters.SkewFar)<=10
    theta = abs(min(Parameters.SkewNear, Parameters.SkewFar));
    theta_temp = theta;
    if theta>60
        theta_temp = 60;
    end
    if theta<30
        c1 = 0;
    else
        c1 = 0.25*(Kg./(12*SpanLength*Parameters.Deck.t^3)).^(0.25).*(min(Parameters.GirderSpacing)/12./SpanLength).^(0.5);
    end
    DFskewRed = max(1-c1*(tan(theta_temp*pi/180))^(1.5));
else
    DFskewRed = 1;
end

DF = max(max(DFext,DFint)).*DFskewRed;

%% Distribution of Live Loads per Lane for Shear in Interior Longitudinal Beams
if Parameters.NumGirder == 3
    DFVint = DFLever;
    DFVint(2) = DFVint;
else
    DFVint = 0.36+min(Parameters.GirderSpacing)/12/25;
    DFVint(2) = 0.2+min(Parameters.GirderSpacing)/144-(min(Parameters.GirderSpacing)/12/35)^(2);
end

%% Distribution of Live Loads per Lane for Shear in Exterior Longitudinal Beams
DFVext = DFLever;
DFVext(2) = (0.6+de/10)*DFVint(2);

%% Correction Factor for support shear at obtuse corner
theta = abs(max(Parameters.SkewNear,Parameters.SkewFar));
if theta<=60
    DFVskew = max(1+.2*(12*SpanLength*(Parameters.Deck.t).^(3)/Kg).^(0.3)*tan(theta*pi/180));
else
    DFVskew = 1;
end

DFV = DFVskew.*max(max(DFVint,DFVext));

end

