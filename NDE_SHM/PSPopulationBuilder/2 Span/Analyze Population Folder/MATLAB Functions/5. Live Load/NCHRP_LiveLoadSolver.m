function NCHRP_LiveLoadSolver(uID, ModelName, ModelPath, Node, Parameters, Options, ArgIn, LCStart, FCaseNum, rNum)
% uID       - Integer defining file id
% ModelName - String of model filename
% ModelPath - String of model filepath
% Node      - Structure containing FE model data
% Parameters- Structure containing structure info
% LCStart   - Number of 1st live load case
% FCaseNum  - Freedom case number

%% Disable load cases
% Get Load & Freedom Cases
[LNumCases, ~, FNumCases, ~, LCaseState] = St7GetLoadAndFreedomCaseInfo(uID);

for i = 1:LNumCases
    for j = 1:FNumCases
        if all(LCaseState(i,j))
            iErr = calllib('St7API', 'St7DisableLSALoadCase', uID, i, j);
            HandleError(iErr);
        end
    end
end

% If
if rNum == 1
    %% Delete Existing Live Load Cases
    NumCase = 0;
    [iErr, NumCase] = calllib('St7API', 'St7GetNumLoadCase', uID, NumCase);
    HandleError(iErr);

    if NumCase >= LCStart
        for ii=LCStart:NumCase
            j = LCStart;
            iErr = calllib('St7API', 'St7DeleteLoadCase', uID, j);
            HandleError(iErr);
        end
    elseif NumCase<LCStart-1 
        LCStart = NumCase+1;
    end

    %% Set Result Type to Save from Analysis 

    %% Create Load Cases
    LCaseNum = LCStart;
    LoadCase = CreateTruckLoadPath(uID, Parameters, Options, Node, ArgIn, LCaseNum);
else
    LoadCase = LNumCases+1;
end

%% Set Load Cases to Be Run
for ii = LCStart:LoadCase-1
    iErr = calllib('St7API', 'St7EnableLSALoadCase', uID, ii, FCaseNum);
    HandleError(iErr);
end

%% Call Solver
% Result File name
LiveLoadResultPath = [ModelPath ModelName '_LL.lsa'];
St7RunStaticSolver(uID, LiveLoadResultPath) 

%% Disable load cases
% Get Load & Freedom Cases
[LNumCases, ~, FNumCases, ~, LCaseState] = St7GetLoadAndFreedomCaseInfo(uID);

for i = 1:LNumCases
    for j = 1:FNumCases
        if all(LCaseState(i,j))
            iErr = calllib('St7API', 'St7DisableLSALoadCase', uID, i, j);
            HandleError(iErr);
        end
    end
end

%% Save
SaveModelFile(uID);

end % LiveLoadSolver()