%              jbb -  07/10/2014
%
% Creates St7 model files with plates defining the cross section of AASHTO and BulbTee Sections
% Model Files are saved in folder entitles 'Sections' in the working folder
% St7 API Library must first be loaded (InitializeSt7())
% Designation   -   'AASHTO' or 'BulbTee'

function CreateSections(Designation)
global luINCH fuPOUNDFORCE suPSI muPOUND tuFAHRENHEIT euBTU tyPLATE kBeamTypeBeam
Units = [luINCH, fuPOUNDFORCE, suPSI, muPOUND, tuFAHRENHEIT, euBTU];
if strcmp(Designation, 'AASHTO')
    MaxSpan(:,1) = 1:6;
    MaxSpan(:,2) = [48 70 100 120 145 167]';
elseif strcmp(Designation, 'BulbTee')
    MaxSpan(:,1) = [54 63 72]';
    MaxSpan(:,2) = [114 130 146]';
end

for ii=1:size(MaxSpan,1)
    Type = ii;
    Name = MaxSpan(ii,1);
    
%% Girder dimensions
if strcmp(Designation, 'AASHTO')
    Dims = [28 36 45 54 63 72; 4 6 7 8 5 5; 0 0 0 0 3 3; 3 3 4.5 6 4 4; 5 6 7.5 9 10 10; 5 6 7 8 8 8; 12 12 16 20 42 42; 16 18 22 26 28 28; 6 6 7 8 8 8; 276 369 560 789 1013 1085; 12.59 15.83 20.27 24.73 31.96 36.38; 22750 50980 125390 260730 521180 733320; 18 28 48 66 76 76; 3 3 4.5 6 4 4; 0 0 0 0 13 13; 5 6 7.5 9 10 10]';
elseif strcmp(Designation, 'BulbTee')
    Dims = [54 63 72; 3.5 3.5 3.5; 2 2 2; 2 2 2; 4.5 4.5 4.5; 6 6 6; 42 42 42; 26 26 26; 6 6 6; 659 713 767; 27.63 32.12 36.60; 268077 392638 545894; 36 36 36; 2 2 2; 16 16 16; 10 10 10]';
end 

Parameters.Beam.d = Dims(Type,1); %Depth
Parameters.Beam.bft = Dims(Type,7); %width top flange
Parameters.Beam.tw = Dims(Type,9); %thickness web
Parameters.Beam.tft = [Dims(Type,2) Dims(Type,3)+Dims(Type,4)]; %thickness top flange
Parameters.Beam.tfb = [Dims(Type,6) Dims(Type,5)]; % thickness of bottom blange
Parameters.Beam.bfb = Dims(Type,8); % width of bottom flange
Parameters.Beam.A = Dims(Type,10); % total area
Parameters.Beam.Ix = Dims(Type,12); % Moment of inertia
Parameters.Beam.yb = Dims(Type,11); % distance from bottom to NA
Parameters.Beam.yt = Parameters.Beam.d-Parameters.Beam.yb; % distance from top to NA
Parameters.Beam.Sb = Parameters.Beam.Ix/Parameters.Beam.yb; % Section modulus measure from bottom flange
Parameters.Beam.St = Parameters.Beam.Ix/Parameters.Beam.yt; % Section modulus measured from top flange
Parameters.Beam.MaxStrands = Dims(Type,13); % Normal maximum number of strands used

%% Create Cross Section
ModelPath = pwd;
ScratchPath = 'D:\Temp\';
dir = isdir([ModelPath '\Sections\']);
if dir == 0
    mkdir(ModelPath, 'Sections');
end

uID2 = 2;
ModelPathName = [ModelPath '\Sections\' Designation num2str(Name) '.st7']; 
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
Node(1).y(2)= Dims(Type,6);

Node(1).x(3) = Dims(Type,16);
Node(1).y(3) = sum(Parameters.Beam.tfb);

Node(1).x(4) = Node(1).x(3);
Node(1).y(4) = Parameters.Beam.d-sum(Parameters.Beam.tft);

Node(1).x(5) = Node(1).x(4)-Dims(Type,14);
Node(1).y(5) = Node(1).y(4)+Dims(Type,4);

Node(1).x(6) = Node(1).x(5)-Dims(Type,15);
Node(1).y(6) = Node(1).y(5)+Dims(Type,3);

Node(1).x(7) = Node(1).x(6);
Node(1).y(7) = Node(1).y(6)+Dims(Type,2);

Node(2).y = Node(1).y;

Node(2).x(1) = Dims(Type,8);
Node(2).x(2) = Node(2).x(1);
Node(2).x(3) = Node(1).x(3)+Dims(Type,9);
Node(2).x(4) = Node(2).x(3);
Node(2).x(5) = Node(2).x(4)+Dims(Type,14);
Node(2).x(6) = Node(2).x(5)+Dims(Type,15);
Node(2).x(7) = Node(1).x(7)+Dims(Type,7);

u=0;
for j=1:2
    for i=1:length(Node(1).x)
        u=u+1;
        iErr = calllib('St7API', 'St7SetNodeXYZ', uID2, u,[Node(j).x(i), Node(j).y(i), 0]);
        HandleError(iErr);
    end
end

% Create Elements
EltNum = 0;

for i=1:6
    if strcmp(Designation, 'AASHTO') && Type<5 && i==5
        continue
    end
    Connection(1) = 4; % square
    Connection(2) = i;
    Connection(3) = i+1;
    Connection(4) = 8+i;
    Connection(5) = 7+i;
    EltNum=EltNum+1;
    iErr = calllib('St7API', 'St7SetElementConnection', uID2, tyPLATE, EltNum, 1, Connection);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetEntityGroup', uID2, tyPLATE, EltNum, 1);
    HandleError(iErr);
end
% 
% iErr = calllib('St7API', 'St7NewBeamProperty', uID2, 1,kBeamTypeBeam,'test');
% HandleError(iErr);

SectionData = zeros(1,34);
BXSName = [Designation num2str(Name)];
[iErr, SectionData] = calllib('St7API', 'St7GenerateBXS', uID2, BXSName,SectionData);
HandleError(iErr);
% 
% iErr = calllib('St7API', 'St7AssignBXS', uID2, 1, BXSName);
% HandleError(iErr);

iErr = calllib('St7API', 'St7SaveFile', uID2);
HandleError(iErr);

try
    calllib('St7API','St7CloseFile',uID2);
catch
end

clear Node
end
end