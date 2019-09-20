function UpdateNatFreqTables()
try
% get data from root
Options = getappdata(0,'Options');
meshData = getappdata(0,'meshData');
testData = getappdata(0,'testData');

handles = Options.handles.ModelExperimentComparison_gui;

%% Variable Assignmnets
if ~isempty(testData)
    expFreq = testData.freq(:,1);
    corrFreq = Options.Correlation.expModes;
    numExpFreq = length(expFreq);
else
    numExpFreq = 0;
end
if ~isempty(meshData)
    anaFreq = meshData.freq(:,1);
    numAnaFreq = length(anaFreq);
else
    numAnaFreq = 0;
end

%% MAC table - max values for each exp mode
if ~isempty(meshData) && ~isempty(testData)
    pairedAnaModes = meshData.pairedModes(:,2);
    Data = cell(numExpFreq,5);
    Data(corrFreq,1) = num2cell(meshData.MAC(sub2ind(size(meshData.MAC), corrFreq', pairedAnaModes)));
    Data(:,2) = num2cell(expFreq);
    Data(corrFreq,3) =num2cell(anaFreq(pairedAnaModes));
    Data(corrFreq,4) = num2cell(pairedAnaModes);   
    Data(corrFreq,5) = num2cell(meshData.freqRes*100);
    
    set(handles.uitableNatFreqComparison, 'Data', Data);
end

%% Freq Table
if ~isempty(meshData) || ~isempty(testData)
    Data = cell(max([numAnaFreq numExpFreq]),3);
    if ~isempty(meshData) 
        Data(1:numAnaFreq,1) = num2cell(anaFreq);
    end
    if ~isempty(testData)
        Data(1:numExpFreq,2) = num2cell(expFreq);
    end
    Data(1:numExpFreq,3) = num2cell(true);
    Data(numExpFreq+1:numAnaFreq,3) = num2cell(false);
    set(handles.uitableAnaExpFreq, 'Data', Data);
end
catch
end
end