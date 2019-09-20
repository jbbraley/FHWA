function SetBeamSection(uID, Parameters)
% Section Property Assignment----------------------------------------------
% Assign section geometry
switch Parameters.structureType
    case 'Steel'
        Section = {'Ext';'Int'};
        for ii = 1:length(Section)
            % Find Property index for shell elements (Deck & Sidewalk)    
            ind = find(strcmp({Parameters.St7Prop(:).propName},[Section{ii} ' Girder']));
            SetSteelSection(uID,Parameters.Beam.(Section{ii}),...
                Parameters.St7Prop(ind).St7PropNum, Parameters.Beam.Updating.Ix.Update);
            if Parameters.Beam.(Section{ii}).CoverPlate.Length > 0
                ind = find(strcmp({Parameters.St7Prop(:).propName},[Section{ii} ' Girder Coverplate']));
                SetSteelSection(uID,Parameters.Beam.(Section{ii}).CoverPlate,...
                    Parameters.St7Prop(ind).St7PropNum, Parameters.Beam.Updating.Ix.Update);
            end
        end        
    case 'Prestressed'
        SetPSSection(uID,Parameters.Beam.Int); % Prestressed only uses Int field
end  
end     

% Subfunctions-------------------------------------------------------------
function SetSteelSection(uID,Beam,PropNum,Update)
% Beam handles variable input from either
% 1) Parameters.Beam.Ext
% 2) Parameters.Beam.Int

global kISection

% Check if beam is being updated
if Update
    Ix = Beam.I.Ix.*Beam.Updating.Ix.Alpha(1);
else
    Ix = Beam.I.Ix;
end

% Assign section geometry
iErr = calllib('St7API', 'St7SetBeamSectionGeometry', uID, PropNum,kISection, Beam.Section);
HandleError(iErr);

% Set Section Geometry
Slices = 1;
ipArea = Beam.A;
ipI22 = Ix;
ipI11 = Beam.I.Iy;
% approximate torionsal constant
ipJ = Beam.tw^3*Beam.ind/3 + 2*Beam.bf*Beam.tf^3/3;
ipSL1 = 0;
ipSL2 = 0;

% shear area
if isfield(Beam, 'ShearDefoff')
    if Beam.ShearDefoff
        ipSA2 = 1*10^9;
        ipSA1 = 1*10^9;
    else
        ipSA2 = 5/6*(2*Beam.bf*Beam.tf);
        ipSA1 = Beam.d*Beam.tw;
    end
else
    ipSA2 = 5/6*(2*Beam.bf*Beam.tf);
    ipSA1 = Beam.d*Beam.tw;
end

ipXBAR = Beam.bf/2;
ipYBAR = Beam.d/2;
ipANGLE = pi/2;
Doubles = [ipArea, ipI11, ipI22, ipJ, ipSL1, ipSL2, ipSA1, ipSA2, ipXBAR,ipYBAR, ipANGLE]; 

iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,PropNum, Slices, Doubles);
HandleError(iErr);

end

function SetPSSection(uID, Beam)
% Set Property Number
PropNum = Beam.St7PropNum;

oldcd = pwd;
cd([pwd '\Prestressed\Sections']);
iErr = calllib('St7API', 'St7AssignBXS', uID, PropNum, Beam.Name);
HandleError(iErr);
cd(oldcd);

SectionData = zeros(11,1);
Slices = 0;
[iErr, Slices, SectionData]  = calllib('St7API', 'St7GetBeamSectionPropertyData', uID,...
    PropNum, Slices, SectionData);
HandleError(iErr);

% shear area
if isfield(Beam, 'ShearDefoff') && Beam.ShearDefoff
    SectionData(7) = 1*10^9;
    SectionData(8) = 1*10^9;
else
    % Switch shear areas
    SectionData(7:8) = SectionData([8 7]);
end

%Switch I11 and I22
SectionData(2:3) = SectionData([3 2]);

%axis 1 angle
SectionData(11) = 3*pi/2;

% Set Property Section Data
iErr = calllib('St7API', 'St7SetBeamSectionPropertyData', uID,...
    PropNum, Slices, SectionData);
HandleError(iErr);
end
