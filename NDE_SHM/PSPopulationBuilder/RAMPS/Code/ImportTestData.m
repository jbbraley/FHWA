function [ExpFreq, ExpDisp, ExpCoord] = ImportTestData(ModelPath, ModelName)

var = load([ModelPath ModelName 'TestData.mat']);
FreqDamp = [var.('FreqDamp')];
if isreal(FreqDamp(1))
    ExpFreq=FreqDamp;
else
    ExpFreq = imag(FreqDamp);
end

ExpDisp = [var.('ModeShape')];

ExpCoord = [var.('GeometryData').X, var.('GeometryData').Y];

end % ImportTestData()