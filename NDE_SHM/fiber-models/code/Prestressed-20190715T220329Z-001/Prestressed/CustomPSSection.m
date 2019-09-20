%       jbb - 7/14/14
% For UserInputPrestressedSection_gui
% Creates custom cross section from user input dimensions
% handles -     handles structure for gui
% Parameters -  Parameters structure
%_________________________________________________________

function Parameters = CustomPSSection(Parameters, handles)
global luINCH fuPOUNDFORCE suPSI muPOUND tuFAHRENHEIT euBTU tyPLATE kBeamTypeBeam
Units = [luINCH, fuPOUNDFORCE, suPSI, muPOUND, tuFAHRENHEIT, euBTU];

%% Gather Dimensions from UI
Dims(1) = str2double(get(handles.editD,'string'));
Dims(7) = str2double(get(handles.editbf,'string'));
Dims(8) = str2double(get(handles.edit_bfb,'string'));
Dims(2) = str2double(get(handles.edit_tft,'string'));
Dims(6) = str2double(get(handles.edit_tfb,'string'));
Dims(9) = str2double(get(handles.edit_tw,'string'));
Dims(3) = str2double(get(handles.edit_d1,'string'));
Dims(4) = str2double(get(handles.edit_d2,'string'));
Dims(5) = str2double(get(handles.edit_d3,'string'));
Dims(14) = str2double(get(handles.edit_b1,'string'));
Dims(15) = str2double(get(handles.edit_b2,'string'));
Dims(16) = str2double(get(handles.edit_b3,'string'));


Parameters.Beam.d = Dims(1); %Depth
Parameters.Beam.bft = Dims(7); %width top flange
Parameters.Beam.tw = Dims(9); %thickness web
Parameters.Beam.tft = [Dims(2) Dims(3)+Dims(4)]; %thickness top flange
Parameters.Beam.tfb = [Dims(6) Dims(5)]; % thickness of bottom blange
Parameters.Beam.bfb = Dims(8); % width of bottom flange

%% Create Custom Section
% Initialize model file
ScratchPath = 'D:\Temp\';
dir = isdir([pwd '\Prestressed\Sections\']);
if dir == 0
    mkdir([pwd '\Prestressed'], 'Sections');
end
oldcd = pwd;
cd([oldcd '\Prestressed\Sections\']);

uID2 = 2;
ModelPathName = [pwd '\Custom' num2str(Dims(1)) 'x' num2str(Dims(7)) '.st7']; 
iErr = calllib('St7API','St7NewFile', uID2, ModelPathName, ScratchPath);
HandleError(iErr);
iErr = calllib('St7API', 'St7SaveFile', uID2);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetUnits', uID2, Units);
HandleError(iErr);

% Create Nodes
Node(1).x(1) = 0;
Node(1).y(1) = 0;

Node(1).x(2) = 0;
Node(1).y(2)= Dims(6);

Node(1).x(3) = Dims(16);
Node(1).y(3) = sum(Parameters.Beam.tfb);

Node(1).x(4) = Node(1).x(3);
Node(1).y(4) = Parameters.Beam.d-sum(Parameters.Beam.tft);

Node(1).x(5) = Node(1).x(4)-Dims(14);
Node(1).y(5) = Node(1).y(4)+Dims(4);

Node(1).x(6) = Node(1).x(5)-Dims(15);
Node(1).y(6) = Node(1).y(5)+Dims(3);

Node(1).x(7) = Node(1).x(6);
Node(1).y(7) = Node(1).y(6)+Dims(2);

Node(2).y = Node(1).y;

Node(2).x(1) = Dims(8);
Node(2).x(2) = Node(2).x(1);
Node(2).x(3) = Node(1).x(3)+Dims(9);
Node(2).x(4) = Node(2).x(3);
Node(2).x(5) = Node(2).x(4)+Dims(14);
Node(2).x(6) = Node(2).x(5)+Dims(15);
Node(2).x(7) = Node(1).x(7)+Dims(7);

u=0;
for j=1:2
    for i=1:length(Node(1).x)
        u=u+1;
        iErr = calllib('St7API', 'St7SetNodeXYZ', uID2, u,[Node(j).x(i), Node(j).y(i) 0]);
        HandleError(iErr);
    end
end

% Create Elements
EltNum = 0;

for ii=1:6
    if (~isnan(Dims(3)) || Dims(3)==0 || ~isnan(Dims(15)) || Dims(15)==0) && ii==5
        continue
    end
    Connection(1) = 4; % square
    Connection(2) = ii;
    Connection(3) = ii+1;
    Connection(4) = 8+ii;
    Connection(5) = 7+ii;
    EltNum=EltNum+1;
    iErr = calllib('St7API', 'St7SetElementConnection', uID2, tyPLATE, EltNum, 1, Connection);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetEntityGroup', uID2, tyPLATE, EltNum, 1);
    HandleError(iErr);
end

% Generate BXS
SectionData = zeros(1,34);
BXSName = ['Custom' num2str(Dims(1)) 'x' num2str(Dims(7))];
[iErr, BXSName, SectionData] = calllib('St7API', 'St7GenerateBXS', uID2, BXSName,SectionData);
HandleError(iErr);

% Save and close model file
iErr = calllib('St7API', 'St7SaveFile', uID2);
HandleError(iErr);

try
    calllib('St7API','St7CloseFile',uID2);
catch
end

% Reset working directory
cd(oldcd);

%% Assign Parameters
Parameters.Beam.A = SectionData(3); % total area
Parameters.Beam.Ix = SectionData(4); % Moment of inertia
Parameters.Beam.Iy = SectionData(5); % Moment of inertia about weak axis
Parameters.Beam.yb = SectionData(2); % distance from bottom to NA
Parameters.Beam.yt = Parameters.Beam.d-Parameters.Beam.yb; % distance from top to NA
Parameters.Beam.xb = SectionData(1); % distance from side to NA
Parameters.Beam.Sb = SectionData(8); % Section modulus measure from bottom flange
Parameters.Beam.St = SectionData(7); % Section modulus measured from top flange
Parameters.Beam.Weight = Parameters.Beam.A*Parameters.Beam.Density;
Parameters.Beam.Name = BXSName;
Parameters.Beam.Type = 'PSCustom';

Dims(10) = Parameters.Beam.A;
Dims(11) = Parameters.Beam.yb;
Dims(12) = Parameters.Beam.Ix;
Parameters.Beam.Section = Dims;

