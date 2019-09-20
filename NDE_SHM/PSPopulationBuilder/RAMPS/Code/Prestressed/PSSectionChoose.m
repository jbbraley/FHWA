%           jbb - 7/14/14
%  Takes Section Name, returns structure and vector of dimensions of the following form
% Dimensions  = 
%                1   Total Depth (D)
%                2   Top Flange Thickness (at edge)
%                3   Vertical distance to end of top flange taper (primary taper)
%                4   Vertical distance to end of top flange taper (secondary taper)
%                5   Vertical distance to end of bottom flange taper
%                6   Thickness of bottom flange at edge
%                7   Width of Top Flange (bft)
%                8   Width of Bottom Flange (bfb)
%                9   Thickness of Web (tw)
%                10  Area of Section (A)
%                11  Distance from bottom to NA (yb)
%                12  Moment of Inertia (Ix)
%                13  Standard Max Number of Strands
%                14  Width of top flange secondary taper
%                15  Width of top flange priamry taper
%                16  Width of bottom flange taper

function [Beam, Dimensions] = PSSectionChoose(SectionName, Beam)
AASHTOdims = [28 36 45 54 63 72; 4 6 7 8 5 5; 0 0 0 0 3 3; 3 3 4.5 6 4 4; 5 6 7.5 9 10 10; 5 6 7 8 8 8; 12 12 16 20 42 42; 16 18 22 26 28 28; 6 6 7 8 8 8; 276 369 560 789 1013 1085; 12.59 15.83 20.27 24.73 31.96 36.38; 22750 50980 125390 260730 521180 733320; 22 32 54 76 92 96; 3 3 4.5 6 4 4; 0 0 0 0 13 13; 5 6 7.5 9 10 10; .287 .384 .583 .822 1.055 1.130; 8 9 11 13 14 14; 3352.33 5332.5 12216.5625 24373.5 61235.167 61619.167]';

BTdims = [54 63 72; 3.5 3.5 3.5; 2 2 2; 2 2 2; 4.5 4.5 4.5; 6 6 6; 42 42 42; 26 26 26; 6 6 6; 659 713 767; 27.63 32.12 36.60; 268077 392638 545894; 54 58 62; 2 2 2; 16 16 16; 10 10 10; .686 .743 .799; 13 13 13; 37310.33 37472.33 37634.33]';

switch SectionName
    case 'AASHTO Type I'
        Dimensions = AASHTOdims(1,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO1';
        DiaStart = 1;
    case 'AASHTO Type II'
        Dimensions = AASHTOdims(2,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO2';
        DiaStart = 1;
    case 'AASHTO Type III'
        Dimensions = AASHTOdims(3,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO3';
        DiaStart = 1;
    case 'AASHTO Type IV'
        Dimensions = AASHTOdims(4,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO4';
        DiaStart = 4;
    case 'AASHTO Type V'
        Dimensions = AASHTOdims(5,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO5';
        DiaStart = 4;
    case 'AASHTO Type VI'
        Dimensions = AASHTOdims(6,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO6';
        DiaStart = 5;
    case 'Bulb-Tee 54'
        Dimensions = BTdims(1,:)';
        Beam.Type = 'BulbTee';
        Beam.Name = 'BulbTee54';
        DiaStart = 4;
    case 'Bulb-Tee 63'
        Dimensions = BTdims(2,:)';
        Beam.Type = 'BulbTee';
        Beam.Name = 'BulbTee63';
        DiaStart = 5;       
    case 'Bulb-Tee 72'
        Dimensions = BTdims(3,:)';
        Beam.Type = 'BulbTee';
        Beam.Name = 'BulbTee72';
        DiaStart = 5;
        case 'AASHTO1'
        Dimensions = AASHTOdims(1,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO1';
        DiaStart = 1;
    case 'AASHTO2'
        Dimensions = AASHTOdims(2,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO2';
        DiaStart = 1;
    case 'AASHTO3'
        Dimensions = AASHTOdims(3,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO3';
        DiaStart = 1;
    case 'AASHTO4'
        Dimensions = AASHTOdims(4,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO4';
        DiaStart = 4;
    case 'AASHTO5'
        Dimensions = AASHTOdims(5,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO5';
        DiaStart = 4;
    case 'AASHTO6'
        Dimensions = AASHTOdims(6,:)';
        Beam.Type = 'AASHTO';
        Beam.Name = 'AASHTO6';
        DiaStart = 5;
    case 'BulbTee54'
        Dimensions = BTdims(1,:)';
        Beam.Type = 'BulbTee';
        Beam.Name = 'BulbTee54';
        DiaStart = 4;
    case 'BulbTee63'
        Dimensions = BTdims(2,:)';
        Beam.Type = 'BulbTee';
        Beam.Name = 'BulbTee63';
        DiaStart = 5;
    case 'BulbTee72'
        Dimensions = BTdims(3,:)';
        Beam.Type = 'BulbTee';
        Beam.Name = 'BulbTee72';
        DiaStart = 5;
end

Beam.d = Dimensions(1); %Depth
Beam.bft = Dimensions(7); %width top flange
Beam.tw = Dimensions(9); %thickness web
Beam.tft = [Dimensions(2) Dimensions(3)+Dimensions(4)]; %thickness top flange
Beam.tfb = [Dimensions(6) Dimensions(5)]; % thickness of bottom blange
Beam.bfb = Dimensions(8); % width of bottom flange
Beam.A = Dimensions(10); % total area
Beam.Weight = Dimensions(17)*1000; % Weight (lb/ft)
Beam.Ix = Dimensions(12); % Moment of inertia about principle axis
Beam.Iy = Dimensions(19); % Moment of Inertia about the weak axis
Beam.xb = Dimensions(18); % Distance from side to centroid
Beam.yb = Dimensions(11); % distance from bottom to NA
Beam.yt = Beam.d-Beam.yb; % distance from top to NA
Beam.Sb = Beam.Ix/Beam.yb; % Section modulus measure from bottom flange
Beam.St = Beam.Ix/Beam.yt; % Section modulus measured from top flange
Beam.MaxStrands = Dimensions(13); % Normal maximum number of strands used
Beam.DiaStart = DiaStart;

   