function [LNumCases, LCaseNames, FNumCases, FCaseNames, LCaseState] = St7GetLoadAndFreedomCaseInfo(uID)

LNumCases = 0;
[iErr, LNumCases] = calllib('St7API', 'St7GetNumLoadCase', uID, LNumCases);
HandleError(iErr);
FNumCases = 0;
[iErr, FNumCases] = calllib('St7API', 'St7GetNumFreedomCase', uID, FNumCases);
HandleError(iErr); 

LCaseState = zeros(LNumCases, FNumCases);

MaxStringLen = 64;
for i = 1:LNumCases
    caseName = strcat(num2str(ones(64,1)))';
    [iErr, caseName] = calllib('St7API', 'St7GetLoadCaseName', uID, i, caseName, MaxStringLen);
    HandleError(iErr);
    LCaseNames{i} = caseName;
end

MaxStringLen = 54;
for i = 1:FNumCases
    caseName = strcat(num2str(ones(64,1)))';
    [iErr, caseName] = calllib('St7API', 'St7GetFreedomCaseName', uID, i,caseName, MaxStringLen);
    HandleError(iErr);
    FCaseNames{i} = caseName;
end

for i = 1:LNumCases
    for j = 1:FNumCases
        state = false;
        [iErr, LCaseState(i,j)] = calllib('St7API', 'St7GetLSALoadCaseState', uID, i, j, state);
        HandleError(iErr);
    end
end

end %St7GetLoadAndFreedomeCaseInfo()