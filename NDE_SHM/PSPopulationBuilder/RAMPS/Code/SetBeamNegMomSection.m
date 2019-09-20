function SetBeamNegMomSection(uID, Parameters)
global kISection
%% Section Property Assignment
if strcmp(Parameters.Beam.DesType, 'Interior/Exterior') == 1
    SetExteriorNegMomSection(uID,Parameters);
    SetInteriorNegMomSection(uID,Parameters);
else    
    % Assign section geometry
    BeamPropNum = Parameters.Beam.CoverPlate.St7PropNum(2);

    iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, BeamPropNum,...
                   kISection, Parameters.Beam.CoverPlate.Section);
    HandleError(iErr);

    Slices = 1;
    ipArea = Parameters.Beam.CoverPlate.A;
    ipI22 = Parameters.Beam.CoverPlate.I.Ix;
    ipI11 = Parameters.Beam.ind*Parameters.Beam.tw^3/12 + 2*(Parameters.Beam.tf+Parameters.Beam.CoverPlate.t)*Parameters.Beam.bf^3/12;
    % approximate torionsal constant
    ipJ = Parameters.Beam.tw^3*Parameters.Beam.ind/3 + 2*Parameters.Beam.bf*(Parameters.Beam.tf+Parameters.Beam.CoverPlate.t)^3/3;
    ipSL1 = 0;
    ipSL2 = 0;
    ipSA2 = 5/6*(2*Parameters.Beam.bf*(Parameters.Beam.tf+Parameters.Beam.CoverPlate.t));
    ipSA1 = (Parameters.Beam.d+2*Parameters.Beam.CoverPlate.t)*Parameters.Beam.tw;
    ipXBAR = Parameters.Beam.bf/2;
    ipYBAR = (Parameters.Beam.d+2*Parameters.Beam.CoverPlate.t)/2;
    ipANGLE = pi/2;
    Doubles = [ipArea, ipI11, ipI22, ipJ, ipSL1, ipSL2, ipSA1, ipSA2, ipXBAR,ipYBAR, ipANGLE]; 

    iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,...
                    BeamPropNum, Slices, Doubles);
    HandleError(iErr);
end

end %SetBeamNegMomSection

function SetInteriorNegMomSection(uID,Parameters)
% Assign section geometry
BeamPropNum = Parameters.Beam.CP.St7PropNum(2);

iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, BeamPropNum,...
               kISection, Parameters.Beam.Int.CoverPlate.Section);
HandleError(iErr);

Slices = 1;
ipArea = Parameters.Beam.Int.CoverPlate.A;
ipI22 = Parameters.Beam.Int.CoverPlate.I.Ix;
ipI11 = Parameters.Beam.Int.ind*Parameters.Beam.Int.tw^3/12 + 2*(Parameters.Beam.Int.tf+Parameters.Beam.Int.CoverPlate.t)*Parameters.Beam.Int.bf^3/12;
% approximate torionsal constant
ipJ = Parameters.Beam.Int.tw^3*Parameters.Beam.Int.ind/3 + 2*Parameters.Beam.Int.bf*(Parameters.Beam.Int.tf+Parameters.Beam.Int.CoverPlate.t)^3/3;
ipSL1 = 0;
ipSL2 = 0;
ipSA2 = 5/6*(2*Parameters.Beam.Int.bf*(Parameters.Beam.Int.tf+Parameters.Beam.Int.CoverPlate.t));
ipSA1 = (Parameters.Beam.Int.d+2*Parameters.Beam.Int.CoverPlate.t)*Parameters.Beam.Int.tw;
ipXBAR = Parameters.Beam.Int.bf/2;
ipYBAR = (Parameters.Beam.Int.d+2*Parameters.Beam.Int.CoverPlate.t)/2;
ipANGLE = pi/2;
Doubles = [ipArea, ipI11, ipI22, ipJ, ipSL1, ipSL2, ipSA1, ipSA2, ipXBAR,ipYBAR, ipANGLE]; 

iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,...
                BeamPropNum, Slices, Doubles);
HandleError(iErr);

end

function SetExteriorNegMomSection(uID,Parameters)
% Assign section geometry
BeamPropNum = Parameters.Beam.CP.St7PropNum(1);

iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, BeamPropNum,...
               kISection, Parameters.Beam.Ext.CoverPlate.Section);
HandleError(iErr);

Slices = 1;
ipArea = Parameters.Beam.Ext.CoverPlate.A;
ipI22 = Parameters.Beam.Ext.CoverPlate.I.Ix;
ipI11 = Parameters.Beam.Ext.CoverPlate.I.Iy;
% ipI11 = Parameters.Beam.ind*Parameters.Beam.tw^3/12 + 2*(Parameters.Beam.tf+Parameters.Beam.CoverPlate.t)*Parameters.Beam.bf^3/12;
% approximate torionsal constant
ipJ = Parameters.Beam.Ext.tw^3*Parameters.Beam.Ext.ind/3 + 2*Parameters.Beam.Ext.bf*(Parameters.Beam.Ext.tf+Parameters.Beam.Ext.CoverPlate.t)^3/3;
ipSL1 = 0;
ipSL2 = 0;
ipSA2 = 5/6*(2*Parameters.Beam.Ext.bf*(Parameters.Beam.Ext.tf+Parameters.Beam.Ext.CoverPlate.t));
ipSA1 = (Parameters.Beam.Ext.d+2*Parameters.Beam.Ext.CoverPlate.t)*Parameters.Ext.Beam.tw;
ipXBAR = Parameters.Beam.Ext.bf/2;
ipYBAR = (Parameters.Beam.Ext.d+2*Parameters.Beam.Ext.CoverPlate.t)/2;
ipANGLE = pi/2;
Doubles = [ipArea, ipI11, ipI22, ipJ, ipSL1, ipSL2, ipSA1, ipSA2, ipXBAR,ipYBAR, ipANGLE]; 

iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,...
                BeamPropNum, Slices, Doubles);
HandleError(iErr);

end