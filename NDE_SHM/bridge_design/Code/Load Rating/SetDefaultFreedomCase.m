function SetDefaultFreedomCase(uID, FCaseNum)
global kNormalFreedom

% Get Load & Freedom Cases
[~, ~, ~, FCaseNames, ~] = St7GetLoadAndFreedomCaseInfo(uID);

% Freedom Cases
% Set First freedom case as default
if all(~strcmp(FCaseNames, 'Default'))
    FCaseName = 'Default';
    FCaseType = kNormalFreedom;
    FCaseDefaults = [false, false, false, false, false, false];
    iErr = calllib('St7API', 'St7SetFreedomCaseName', uID, FCaseNum, FCaseName);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetFreedomCaseType', uID, FCaseNum, FCaseType);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetFreedomCaseDefaults', uID, FCaseNum, FCaseDefaults);
    HandleError(iErr);
end
end