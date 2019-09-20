function InitProperties(uID, Parameters)
global kBeamTypeBeam ptBEAMPROP ptPLATEPROP
global kSquareSolid
global kPlateTypePlateShell kMaterialTypeIsotropic

% If no concrete barriers (= 0)
if Parameters.Barrier.Width == -1
    Parameters.Barrier.Width = 1;
    Parameters.Barrier.Height = 2.5;
elseif Parameters.Barrier.Width == 0 || Parameters.Barrier.Height == 0
    Parameters.Barrier.Width = 0;
    Parameters.Barrier.Height = 0;
end

%% Beam, Diaphragm Properties
for ii = 1:length(Parameters.St7Prop)
    iErr = calllib('St7API', 'St7NewBeamProperty', uID, Parameters.Beam.St7PropNum, kBeamTypeBeam,...
               Parameters.St7Prop(ii).);
end
iErr = calllib('St7API', 'St7NewBeamProperty', uID, Parameters.Beam.St7PropNum, kBeamTypeBeam,...
               'Beam');
HandleError(iErr);
iErr = calllib('St7API', 'St7NewBeamProperty', uID, Parameters.Beam.CP.St7PropNum, kBeamTypeBeam,...
               'BeamNegMom');
HandleError(iErr);
iErr = calllib('St7API', 'St7NewBeamProperty', uID, Parameters.Dia.St7PropNum, kBeamTypeBeam,...
               'Diaphragm');
HandleError(iErr);
iErr = calllib('St7API', 'St7NewBeamProperty', uID, Parameters.compAction.St7PropNum, kBeamTypeBeam,...
               'Composite Action');
HandleError(iErr);

% Assign steel properties to beams and cross bracing
switch Parameters.structureType
    case 'Steel'
        Doubles = [Parameters.Beam.E 16030 0.25 490.061/(12^3) 6.5*10^(-6) 0 0 0.0086664 0.1111]; 
        iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Beam.St7PropNum, Doubles);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.Beam.St7PropNum, 'Girder Steel');
        HandleError(iErr);
        
        Doubles = [Parameters.Beam.E 16030 0.25 490.061/(12^3) 6.5*10^(-6) 0 0 0.0086664 0.1111]; 
        iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Beam.CP.St7PropNum, Doubles);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.Beam.CP.St7PropNum, 'Girder Steel w/ Cover Plate');
        HandleError(iErr);
        
        Doubles = [Parameters.Dia.E 16030 0.25 490.061/(12^3) 6.5*10^(-6) 0 0 0.0086664 0.1111]; 
        iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Dia.St7PropNum, Doubles);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.Dia.St7PropNum, 'Diaphragm Steel');
        HandleError(iErr);
    case 'Prestressed'
        Doubles = [Parameters.Beam.E 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881]; 
        iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Beam.St7PropNum, Doubles);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.Beam.St7PropNum, 'Girder Concrete');
        HandleError(iErr);
        
        Doubles = [Parameters.Dia.E 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
        iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Dia.St7PropNum, Doubles);
        HandleError(iErr);
        iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.Dia.St7PropNum, 'Diaphragm Concrete');
        HandleError(iErr);
end

Doubles = [Parameters.Dia.E 16030 0.25 490.061/(12^3) 6.5*10^(-6) 0 0 0.0086664 0.1111]; 
iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Dia.St7PropNum, Doubles);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.Dia.St7PropNum, 'Diaphragm Steel');
HandleError(iErr);

% Composite Action Links
Doubles = [Parameters.Beam.E 10000000 0 0 0 0 0 0 0]; %just make the E the same as the beam.
iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.compAction.St7PropNum, Doubles);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.compAction.St7PropNum, 'Girder/Deck Composite Action Link');
HandleError(iErr);

% if Parameters.WindBracing==1 
%     iErr = calllib('St7API', 'St7NewBeamProperty', uID, 7, kBeamTypeBeam,...
%                'Lateral Bracing');
%     HandleError(iErr);
%     iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, 7, Doubles);
%     HandleError(iErr);
%     iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, 7, 'Lateral Bracing Steel');
%     HandleError(iErr);
% end

%% Barrier Section Property Assignment
% Section
if Parameters.Sidewalk.Right > 0
    BarrierDim = [Parameters.Barrier.Width, Parameters.Barrier.Height, 0, 0, 0];
else
    BarrierDim = [Parameters.Barrier.Width, Parameters.Barrier.Height+Parameters.Sidewalk.Height, 0, 0, 0];
end

% convert fc to E
Parameters.Barrier.E = 57000*sqrt(Parameters.Barrier.fc);

if Parameters.Barrier.Width ~= 0
    % Assign
    iErr = calllib('St7API', 'St7NewBeamProperty', uID, Parameters.Barrier.St7PropNum(1), kBeamTypeBeam,...
        'Right Barrier');
    HandleError(iErr);
    Doubles = [Parameters.Barrier.E 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
    iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Barrier.St7PropNum(1), Doubles);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.Barrier.St7PropNum(1), 'Right Barrier Concrete');
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, Parameters.Barrier.St7PropNum(1),...
        kSquareSolid, BarrierDim);
    HandleError(iErr);
    
    Slices = 1;
    ipArea = BarrierDim(2)*Parameters.Barrier.Width;
    ipI11 = BarrierDim(2)^3*Parameters.Barrier.Width/12;
    ipI22 = BarrierDim(2)*Parameters.Barrier.Width^3/12;
    % approximate torionsal constant
    ipJ = BarrierDim(2)*Parameters.Barrier.Width^3*(1/3 - 0.21*Parameters.Barrier.Width/BarrierDim(2)*(1-Parameters.Barrier.Width^4/(12*BarrierDim(2)^4)));
    ipSL1 = 0;
    ipSL2 = 0;
    ipSA1 = 5/6*(BarrierDim(2)*Parameters.Barrier.Width);
    ipSA2 = 5/6*(BarrierDim(2)*Parameters.Barrier.Width);
    ipXBAR = Parameters.Barrier.Width;
    ipYBAR =  BarrierDim(2)/2; 
    ipANGLE = pi/2;
    Doubles = [ipArea, ipI11, ipI22, ipJ, ipSL1, ipSL2, ipSA1, ipSA2, ipXBAR,ipYBAR, ipANGLE];
    
    iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,...
        Parameters.Barrier.St7PropNum(1), Slices, Doubles);
    HandleError(iErr);
    
    % Left Barrier Section Property Assignment
    if Parameters.Sidewalk.Left > 0
        BarrierDim = [Parameters.Barrier.Width, Parameters.Barrier.Height, 0, 0, 0];
    else
        BarrierDim = [Parameters.Barrier.Width, Parameters.Barrier.Height+Parameters.Sidewalk.Height, 0, 0, 0];
    end
    
    % Assign
    iErr = calllib('St7API', 'St7NewBeamProperty', uID, Parameters.Barrier.St7PropNum(2), kBeamTypeBeam,...
        'Left Barrier');
    HandleError(iErr);
    Doubles = [Parameters.Barrier.E 1659.52 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
    iErr = calllib('St7API', 'St7SetBeamMaterialData', uID, Parameters.Barrier.St7PropNum(2), Doubles);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetMaterialName', uID, ptBEAMPROP, Parameters.Barrier.St7PropNum(2), 'Left Barrier Concrete');
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, Parameters.Barrier.St7PropNum(2),...
        kSquareSolid, BarrierDim);
    HandleError(iErr);
    iErr  = calllib('St7API', 'St7CalculateBeamSectionProperties', uID, Parameters.Barrier.St7PropNum(2), 1, 1);
    HandleError(iErr);
    
    Slices = 1;
    ipArea = BarrierDim(2)*Parameters.Barrier.Width;
    ipI11 = BarrierDim(2)^3*Parameters.Barrier.Width/12;
    ipI22 = BarrierDim(2)*Parameters.Barrier.Width^3/12;
    % approximate torionsal constant
    ipJ = BarrierDim(2)*Parameters.Barrier.Width^3*(1/3 - 0.21*Parameters.Barrier.Width/BarrierDim(2)*(1-Parameters.Barrier.Width^4/(12*BarrierDim(2)^4)));
    ipSL1 = 0;
    ipSL2 = 0;
    ipSA1 = 5/6*(BarrierDim(2)*Parameters.Barrier.Width);
    ipSA2 = 5/6*(BarrierDim(2)*Parameters.Barrier.Width);
    ipXBAR = 0;
    ipYBAR = BarrierDim(2)/2;
    ipANGLE = pi/2;
    Doubles = [ipArea, ipI11, ipI22, ipJ, ipSL1, ipSL2, ipSA1, ipSA2, ipXBAR,ipYBAR, ipANGLE];
    
    iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,...
        Parameters.Barrier.St7PropNum(2), Slices, Doubles);
    HandleError(iErr);
end

%% Deck Section Property Assignment
Parameters.Deck.E = 57000*sqrt(Parameters.Deck.fc);

iErr = calllib('St7API', 'St7NewPlateProperty', uID, 1,...
                kPlateTypePlateShell, kMaterialTypeIsotropic, 'Deck');
HandleError(iErr);
Doubles = [Parameters.Deck.E 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 1, Doubles);
HandleError(iErr);
iErr=calllib('St7API','St7SetPlateThickness',uID,1,[Parameters.Deck.t, Parameters.Deck.t]);              
HandleError(iErr);
iErr = calllib('St7API', 'St7SetMaterialName', uID, ptPLATEPROP, 1, 'Deck Concrete');
HandleError(iErr);


%% Sidewalk Section Property Assignment
% convert fc to E
Parameters.Sidewalk.E = 57000*sqrt(Parameters.Sidewalk.fc);

iErr = calllib('St7API', 'St7NewPlateProperty', uID, 2,...
                kPlateTypePlateShell, kMaterialTypeIsotropic, 'Sidewalk');
HandleError(iErr);
Doubles = [Parameters.Sidewalk.E 0.2 149.827/(12^3) 5.55556*10^(-6) 0 0 0.210184 0.000219881];
iErr = calllib('St7API', 'St7SetPlateIsotropicMaterial', uID, 2, Doubles);
HandleError(iErr);
iErr=calllib('St7API','St7SetPlateThickness',uID,2,[Parameters.Sidewalk.Height, Parameters.Sidewalk.Height]);              
HandleError(iErr);
iErr = calllib('St7API', 'St7SetMaterialName', uID, ptPLATEPROP, 2, 'Sidewalk Concrete');
HandleError(iErr);

end %InitProperties