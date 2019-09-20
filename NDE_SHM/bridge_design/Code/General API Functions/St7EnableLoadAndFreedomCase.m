function St7EnableLoadAndFreedomCase(uID, LFCaseCombo)
% Nx2 Array of load and freedom case combinations...
% i.e. [1,2] is load case 1 under freedom case 2

for i = 1:size(LFCaseCombo,1)
    LCaseNum = LFCaseCombo(i,1);
    FCaseNum = LFCaseCombo(i,2);
    iErr = calllib('St7API', 'St7EnableLSALoadCase', uID, LCaseNum, FCaseNum);
    HandleError(iErr);
end

end % CreateLoadCase()