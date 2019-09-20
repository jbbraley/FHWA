function St7SetWindowLoadAndFreedomCase(uID, LFCaseCombo)
    LCaseNum = LFCaseCombo(1,1);
    FCaseNum = LFCaseCombo(1,2);
    iErr = calllib('St7API', 'St7SetWindowLoadCase', uID, LCaseNum);
    HandleError(iErr);
    iErr = calllib('St7API', 'St7SetWindowFreedomCase', uID, FCaseNum);
    HandleError(iErr);
end % CreateLoadCase()