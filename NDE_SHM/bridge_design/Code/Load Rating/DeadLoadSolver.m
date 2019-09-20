function DeadLoadSolver(uID, ModelName, ModelPath, Parameters, DLCase, FCaseNum)
global kAccelerations
%% Static Solver Options
% Get Load & Freedom Cases
[LNumCases, LCaseName, FNumCases, FCaseName, LCaseState] = St7GetLoadAndFreedomCaseInfo(uID);

% Disable all load cases
for i = 1:LNumCases
    for j = 1:FNumCases
        if all(LCaseState(i,j))
            iErr = calllib('St7API', 'St7DisableLSALoadCase', uID, i, j);
            HandleError(iErr);
        end
    end
end

if LNumCases<DLCase
    for ii = 1:DLCase-LNumCases
        % Create Load Case
        iErr = calllib('St7API', 'St7NewLoadCase', uID, ['Load Case ' num2str(ii+LNumCases)]);
        HandleError(iErr);
    end
end

[~, LCaseNames, ~, ~, ~] = St7GetLoadAndFreedomCaseInfo(uID);

% Load Cases
LCaseNum = DLCase;
if ~strcmp(LCaseNames{LCaseNum}, 'Dead Load')
    LCaseName = 'Dead Load';
    iErr = calllib('St7API', 'St7SetLoadCaseName', uID, LCaseNum, LCaseName);
    HandleError(iErr);
end
 
LCaseType = kAccelerations;    
LCaseDefaults = [0, 0, 0, 0, 0, 0, -386.09, 0, 0, 0, 0, 0, 0];
LCaseMass = [true false];

iErr = calllib('St7API', 'St7SetLoadCaseType', uID, LCaseNum, LCaseType);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetLoadCaseDefaults', uID, LCaseNum, LCaseDefaults);
HandleError(iErr);
iErr = calllib('St7API', 'St7SetLoadCaseMassOption', uID, LCaseNum, LCaseMass(1), LCaseMass(2));
HandleError(iErr);
iErr = calllib('St7API', 'St7EnableLSALoadCase', uID, LCaseNum, FCaseNum);
HandleError(iErr);

%% Pull Existing Property Data
% Beams
Bmind = find(strcmp({Parameters.St7Prop(:).propType},'Beam'));
BmMatData_old = zeros(length(Bmind),9);
BmPropNum_all = zeros(length(Bmind),1);

Plind = find(strcmp({Parameters.St7Prop(:).propType},'Shell'));
PlMatData_old = zeros(length(Plind),8);
PlPropNum_all = zeros(length(Plind),1);

for ii = Bmind
    BmMatData_old(ii,:) = St7GetBeamMaterialData(uID, Parameters.St7Prop(ii).St7PropNum);
    BmPropNum_all(ii) = Parameters.St7Prop(ii).St7PropNum;
end

for ii = Plind
    PlMatData_old(ii,:) = St7GetPlateMaterial(uID, Parameters.St7Prop(ii).St7PropNum);
    PlPropNum_all(ii) = Parameters.St7Prop(ii).St7PropNum;
end

%% Specify Material Changes (Density & Stiffness off)
% Dead Load 1
BmPoff{1,:} = {'Right Barrier' 'Left Barrier' 'Girder Concrete'};
BmEoff{1,:} = {'Right Barrier' 'Left Barrier' 'Girder Concrete'};
PlPoff{1,:} = {'Sidewalk'};
PlEoff{1,:} = {'Sidewalk' 'Deck'};
% Dead Load 2 (Superimposed)
BmPoff{2,:} = {'Ext Girder' 'Int Girder' 'Ext Girder Coverplate' 'Int Girder Coverplate' 'End Diaphragm' 'Int Diaphragm'};
BmEoff{2,:} = {'Right Barrier' 'Left Barrier' 'Girder Concrete'};
PlPoff{2,:} = {'Deck'};
PlEoff{2,:} = {'Sidewalk'};
% Dead Load 3 (Wearing Surface)
if Parameters.Deck.WearingSurface ~=0
    BmPoff{3,:} = {'Ext Girder' 'Int Girder' 'Ext Girder Coverplate' 'Int Girder Coverplate' 'End Diaphragm' 'Int Diaphragm' 'Right Barrier' 'Left Barrier' 'Girder Concrete'};
    BmEoff{3,:} = {};
    PlPoff{3,:} = {'Deck' 'Sidewalk'};
    PlEoff{3,:} = {};
end

for jj=1:size(BmPoff,1)
    %% Deck Dead Load
    DeadLoadType = jj;
    BmMatData_new = BmMatData_old;
    PlMatData_new = PlMatData_old;

    %% Adjust material properties of apropriate elements by property number
    % Beams
    % Density off
    BmPoffind = [];
    for ii=1:length(BmPoff{jj,:})
    BmPoffind = [BmPoffind find(strcmp({Parameters.St7Prop(:).propName},BmPoff{jj}(ii)))];
    end
    BmMatData_new(BmPoffind,4) = 0;

    % Stiffness Negligeable
    BmEoffind = [];
    for ii=1:length(BmEoff{jj,:})
    BmEoffind = [BmEoffind find(strcmp({Parameters.St7Prop(:).propName},BmEoff{jj}(ii)))];
    end
    BmMatData_new(BmEoffind,1) = 5;

    % Plates
    % Density off
    PlPoffind = [];
    for ii=1:length(PlPoff{jj,:})
    PlPoffind = [PlPoffind find(strcmp({Parameters.St7Prop(:).propName},PlPoff{jj}(ii)))];
    end
    PlMatData_new(PlPoffind,3) = 0;

    % Stiffness Negligeable
    PlEoffind = [];
    for ii=1:length(PlEoff{jj,:})
    PlEoffind = [PlEoffind find(strcmp({Parameters.St7Prop(:).propName},PlEoff{jj}(ii)))];
    end
    PlMatData_new(PlEoffind,1) = 5;

    %% Apply revised material properties to model
    ChangeBmind = unique([BmPoffind BmEoffind]);
    BmPropNum = {Parameters.St7Prop(ChangeBmind).St7PropNum};
    BmData = BmMatData_new(ChangeBmind,:);

    St7SetMaterialData(uID, cell2mat(BmPropNum), BmData);

    ChangePlind = unique([PlPoffind PlEoffind]);
    PlPropNum = cell2mat({Parameters.St7Prop(ChangePlind).St7PropNum});
    PlData = PlMatData_new(ChangePlind,:);

    St7SetIsoPlateMaterialData(uID,PlPropNum,PlData);
    
    if jj==3
        LCaseMass = [false true]; % Note: Change to [true true] if structural mass is evaluated in this dead load type
        % Accelerations applied to non-structural mass
        iErr = calllib('St7API', 'St7SetLoadCaseMassOption', uID, LCaseNum, LCaseMass(1), LCaseMass(2));
        HandleError(iErr);
    end

    %% Run Solver
    DeadLoadResultPath = [ModelPath ModelName '_' num2str(DeadLoadType) '.lsa'];
    St7RunStaticSolver(uID, DeadLoadResultPath);
end

%% Set Material Properties Back to Original
Bmind = find(BmPropNum_all);
St7SetMaterialData(uID, BmPropNum_all(Bmind), BmMatData_old(Bmind,:));
Plind = find(PlPropNum_all);
St7SetIsoPlateMaterialData(uID,PlPropNum_all(Plind),PlMatData_old(Plind,:));

%% Disable all load cases
[LNumCases, ~, FNumCases, ~, LCaseState] = St7GetLoadAndFreedomCaseInfo(uID);

for i = 1:LNumCases
    for j = 1:FNumCases
        if all(LCaseState(i,j))
            iErr = calllib('St7API', 'St7DisableLSALoadCase', uID, i, j);
            HandleError(iErr);
        end
    end
end

% Save File
SaveModelFile(uID);

end % DeadLoadAnalysis()