function stop = OutputFunction(x,optimValues,state,handles)
stop = false;
Parameters = getappdata(0,'Parameters');

switch state
    case 'init'
        currentValues = getappdata(0,'currentValues');
        Parameters.CorrHistory.FreqRes(:,1) = currentValues.FreqRes;
        Parameters.CorrHistory.MACRes(:,1) = currentValues.MACRes;
        Parameters.CorrHistory.MAC(:,:,1) = currentValues.MAC;
        Parameters.CorrHistory.Alpha(:,1) = currentValues.Alpha;
        Parameters.CorrHistory.ExpFreq(:,1) = currentValues.ExpFreq;
        Parameters.CorrHistory.ExpDisp(:,:,1) = currentValues.ExpDisp;
        Parameters.CorrHistory.AnaDisp(:,:,1) = currentValues.AnaDisp;
        Parameters.CorrHistory.AnaFreq(:,1) = currentValues.AnaFreq; 
        Parameters.CorrHistory.COMAC(:,1) = currentValues.COMAC;
    case 'iter'
        currentValues = getappdata(0,'currentValues');
        Parameters.CorrHistory.FreqRes(:,end+1) = currentValues.FreqRes;
        Parameters.CorrHistory.MACRes(:,end+1) = currentValues.MACRes;
        Parameters.CorrHistory.MAC(:,:,end+1) = currentValues.MAC;
        Parameters.CorrHistory.Alpha(:,end+1) = currentValues.Alpha;
        Parameters.CorrHistory.ExpFreq(:,end+1) = currentValues.ExpFreq;
        Parameters.CorrHistory.ExpDisp(:,:,end+1) = currentValues.ExpDisp;
        Parameters.CorrHistory.AnaDisp(:,:,end+1) = currentValues.AnaDisp;
        Parameters.CorrHistory.AnaFreq(:,end+1) = currentValues.AnaFreq;  
        Parameters.CorrHistory.COMAC(:,end+1) = currentValues.COMAC;
    case 'done'
        currentValues = getappdata(0,'currentValues');
        Parameters.CorrHistory.FreqRes(:,end+1) = currentValues.FreqRes;
        Parameters.CorrHistory.MACRes(:,end+1) = currentValues.MACRes;
        Parameters.CorrHistory.MAC(:,:,end+1) = currentValues.MAC;
        Parameters.CorrHistory.Alpha(:,end+1) = currentValues.Alpha;
        Parameters.CorrHistory.ExpFreq(:,end+1) = currentValues.ExpFreq;
        Parameters.CorrHistory.ExpDisp(:,:,end+1) = currentValues.ExpDisp;
        Parameters.CorrHistory.AnaDisp(:,:,end+1) = currentValues.AnaDisp;
        Parameters.CorrHistory.AnaFreq(:,end+1) = currentValues.AnaFreq;  
        Parameters.CorrHistory.COMAC(:,end+1) = currentValues.COMAC;
        rmappdata(0,'currentValues');
end

% Call Plot function
setappdata(0,'Parameters', Parameters);
OptPlot(x,state,Parameters,handles);

end %OptStatus