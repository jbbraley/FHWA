function meshData = NaturalFrequencyComparison(Options, meshData, testData)
% get data from root
if isempty(Options)
    Options = getappdata(0,'Options');
end
if isempty(meshData)
    meshData = getappdata(0,'meshData');
end
if isempty(testData)
    testData = getappdata(0,'testData');
end

if ~isempty(testData) && ~isempty(meshData)
    % Get MAC and COMAC Values
    % First pair coorsd
    expModes = Options.Correlation.expModes;
    meshData.pairedCoord = PairCoord(meshData, testData);
    meshData.MAC = GetMACValue(testData.U, meshData.U(meshData.pairedCoord,:));
    rePair = 1;
    meshData = PairModes(Options, meshData, rePair);
    meshData.COMAC = GetCOMACValue(testData.U(:,expModes),meshData.U(meshData.pairedCoord,meshData.pairedModes(:,2)));
    meshData.freqRes = (meshData.freq(meshData.pairedModes(:,2))-testData.freq(Options.Correlation.expModes))./testData.freq(Options.Correlation.expModes);
    
    % set data to root
    setappdata(0,'meshData', meshData);
end
end
        