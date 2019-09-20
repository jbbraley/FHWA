%NCHRP_CreateFreedomCases
clear
clc

h = waitbar(0,'Initializing...');
global kNormalFreedom

% USER INPUT --------------------------------------------------------------

Path = 'D:\Files\Documents\PSPopulationBuilder\Analyze Population Folder';

% -------------------------------------------------------------------------

% Get filenames of all model files
dirData = dir([Path '\Model Files\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(8:end-4));
    ind(ii) = dirData(ii).ind;
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 


for ii = 1:length(fileList)
    
    waitbar(ii/length(fileList),h,['Creating freedom cases for Bridge_ ' num2str(ii)]);
    
    if ~exist([Path '\Model Files\Nodes\PSBridge_' num2str(ii) '_Node.mat'],'file') 
        continue
    end

    % Load St7 API
    St7Start = 1;
    InitializeRAMPS([],[], St7Start);

    mName = fileList{ii}(1:end-4);
    ModelPathName = [Path '\Model Files\'];

    % Load in parameters, node, and options files
    load([Path '\Model Files\Nodes\' mName '_Node' '.mat']);
    load([Path '\Model Files\Parameters\' mName '_Para' '.mat']);
    load([Path '\Model Files\Options\' mName '_Options' '.mat']);
    
    uID = Options.St7.uID;
    
    % Support Conditions --------------------------------------------------
 
    % Fixity  = [DX DY DZ RX RY RZ Alignment Long.]
    
    % Pinned Fixity
    pinned_fixity = [0 0 1 0 0 0 1 1];
    
    % Fixed (for rotation) fixity
    fixed_fixity =  [0 0 1 0 1 0 1 1];
    
    % Expansion fixity and displacement
    exp_fixity = [0 0 1 0 0 0 0 0];
    exp_disp = [0 0 0 0 0 0]; %[inches, degrees]
    
    % Pinned/Fixed Location
    Spans = Parameters.Spans;
    if Spans == 1 % Pinned Near
        Type1 = [1;0];
    elseif Spans == 2
        Type1 = [1;0;0];
    elseif Spans == 3
        Type1 = [1;0;0;0];
    end

    if Spans == 1 % Pinned Far
        Type2 = [0;1];
    elseif Spans == 2
        Type2 = [0;1;0];
    elseif Spans == 3
        Type2 = [0;1;0;0];
    end
    
    % Vertical Displacement
    v_disp = -1*ones(1,Parameters.NumGirder); %[inches, degrees]
    
    % Rotational Displacement
    r_dispCCW = 0:-1/(Parameters.NumGirder-1):-1;
    r_dispCW = fliplr(r_dispCCW);   

    % Load St7 Model files ------------------------------------------------
    St7OpenModelFile(Options.St7.uID, ModelPathName, Parameters.ModelName, Options.St7.ScratchPath);
    
    
    % Create new freedom cases --------------------------------------------
    
    % Pinned Abutment
    FCaseNum = 1;
    FCaseName = 'Pinned Abutment';
    try
        iErr = calllib('St7API', 'St7SetFreedomCaseName', Options.St7.uID, FCaseNum, FCaseName);
        HandleError(iErr); % Rename freedom case
    catch
    end
    Parameters.Bearing.Type = Type1;
    Parameters.Bearing.Fixed.Fixity = pinned_fixity;
    Parameters.Bearing.Expansion.Fixity = exp_fixity;
    Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
    Parameters.Bearing.Expansion.Disp = [0 0 0 0 0 0];
    NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, zeros(1,Parameters.NumGirder), [0 0 0]);

%     % Fixed Abutment
%     FCaseNum = 2;
%     FCaseName = 'Fixed Abutment';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type1;
%     Parameters.Bearing.Fixed.Fixity = fixed_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = [0 0 0 0 0 0];
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, zeros(1,Parameters.NumGirder), [0 0 0]);
% 
%     % Pinned Pier
%     FCaseNum = 3;
% %     FCaseName = 'Pinned Pier';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type2;
%     Parameters.Bearing.Fixed.Fixity = pinned_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = [0 0 0 0 0 0];
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, zeros(1,Parameters.NumGirder), [0 0 0]);
%     
%     % Fixed Pier
%     FCaseNum = 4;
% %     FCaseName = 'Fixed Pier';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type2;
%     Parameters.Bearing.Fixed.Fixity = fixed_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = [0 0 0 0 0 0];
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, zeros(1,Parameters.NumGirder), [0 0 0]);
% 
%     % Pinned Abutment w/ Vertical Settlement
%     FCaseNum = 5;
% %     FCaseName = 'Vertical Settlement - Pinned Abutment';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type1;
%     Parameters.Bearing.Fixed.Fixity = pinned_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, v_disp, [1 0 0]);
%     
%     % Fixed Abutment w/ Veritcal Settlement
%     FCaseNum = 6;
% %     FCaseName = 'Vertical Settlement - Fixed Abutment';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type1;
%     Parameters.Bearing.Fixed.Fixity = fixed_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, v_disp, [1 0 0]);
%     
%     % Pinned Abutment, Rotational CW Settlement 
%     FCaseNum = 7;
% %     FCaseName = 'Rotational Settlement Positive - Pinned Abutment';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type1;
%     Parameters.Bearing.Fixed.Fixity = pinned_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, r_dispCW, [1 0 0]);
%     
%     % Pinned Abutment, Rotational CCW Settlement
%     FCaseNum = 8;
% %     FCaseName = 'Rotational Settlement Negative - Pinned Abutment';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type1;
%     Parameters.Bearing.Fixed.Fixity = pinned_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, r_dispCCW, [1 0 0]);
%     
%     % Fixed Abutment, Rotational CW Settlement
%     FCaseNum = 9;
% %     FCaseName = 'Rotational Settlement Positive - Fixed Abutment';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type1;
%     Parameters.Bearing.Fixed.Fixity = fixed_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, r_dispCW, [1 0 0]);
%     
%     % Fixed Abutment, Rotational CCW Settlement
%     FCaseNum = 10;
% %     FCaseName = 'Rotational Settlement Negative - Fixed Abutment';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type1;
%     Parameters.Bearing.Fixed.Fixity = fixed_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, r_dispCCW, [1 0 0]);
%     
%     % Pinned Pier, Vertical Settlement 
%     FCaseNum = 11;
% %     FCaseName = 'Vertical Settlement - Pinned Pier';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type2;
%     Parameters.Bearing.Fixed.Fixity = pinned_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, v_disp, [0 1 0]);
%         
%     % Fixed Pier, Vertical Settlement
%     FCaseNum = 12;
% %     FCaseName = 'Vertical Settlement - Fixed Pier';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type2;
%     Parameters.Bearing.Fixed.Fixity = fixed_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, v_disp, [0 1 0]);
% 
%     % Pinned Pier, Rotational CW Settlement
%     FCaseNum = 13;
% %     FCaseName = 'Rotational Settlement Positive - Pinned Pier';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type2;
%     Parameters.Bearing.Fixed.Fixity = pinned_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, r_dispCW, [0 1 0]);
%     
%     % Pinned Pier, Rotational CCW Settlement
%     FCaseNum = 14;
% %     FCaseName = 'Rotational Settlement Negative - Pinned Pier';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type2;
%     Parameters.Bearing.Fixed.Fixity = pinned_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, r_dispCCW, [0 1 0]);
%     
%     % Fixed Pier, Rotational CW Settlement
%     FCaseNum = 15;
% %     FCaseName = 'Rotational Settlement Positive - Fixed Pier';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type2;
%     Parameters.Bearing.Fixed.Fixity = fixed_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, r_dispCW, [0 1 0]);
%     
%     % Fixed Pier, Rotational CCW Settlement
%     FCaseNum = 16;
% %     FCaseName = 'Rotational Settlement Negative - Fixed Pier';
% %     FCaseType = kNormalFreedom;
% %     FCaseDefaults = [false, false, false, false, false, false];
% %     St7CreateFreedomCase(Options.St7.uID, FCaseName, FCaseNum, FCaseType, FCaseDefaults);
%     Parameters.Bearing.Type = Type2;
%     Parameters.Bearing.Fixed.Fixity = fixed_fixity;
%     Parameters.Bearing.Expansion.Fixity = exp_fixity;
%     Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
%     Parameters.Bearing.Expansion.Disp = exp_disp;
%     NCHRP_SetBoundaryConditions(uID, Node, Parameters, FCaseNum, r_dispCCW, [0 1 0]);
            
    SaveModelFile(Options.St7.uID);
    CloseModelFile(Options.St7.uID);
    CloseAndUnload(Options.St7.uID);
end

close(h);
fprintf('Freedom cases created. \n');


