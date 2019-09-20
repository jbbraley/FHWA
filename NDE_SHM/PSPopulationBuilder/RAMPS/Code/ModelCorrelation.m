function Parameters = ModelCorrelation(uID, Options, Node, Parameters, testData, meshData, handles)
%% Least Squares Non Linear Opt.
if strcmp(Options.Correlation.Method,'Least Squares')
    % Tolerances
    TolFun = Options.Correlation.TolFun; %0.0001;
    TolX = Options.Correlation.TolX; %0.0001;
    DiffMinChange = 0.001;
    
    %% Get Parameter and Alpha List
    % Get number of parameters to update and assign parameter indexes
    numPara = 0;
    if Parameters.Beam.Updating.Ix.Update
        numPara = numPara + 1;
        Parameters.Beam.Updating.Ix.Index = numPara;
        Parameters.CorrHistory.IndKey{numPara} = 'Beam I';
        CorrAlpha(numPara,:) = Parameters.Beam.Updating.Ix.Alpha;
    end
    if Parameters.Deck.Updating.fc.Update
        numPara = numPara + 1;
        Parameters.Deck.Updating.fc.Index = numPara;
        Parameters.CorrHistory.IndKey{numPara} = 'Deck Fc'; 
        CorrAlpha(numPara,:) = Parameters.Deck.Updating.fc.Alpha;
    end
    if Parameters.Dia.Updating.E.Update
        numPara = numPara + 1;
        Parameters.Dia.Updating.E.Index = numPara;
        Parameters.CorrHistory.IndKey{numPara} = 'E of Diaphragms';
        CorrAlpha(numPara,:) = Parameters.Dia.Updating.E.Alpha;
    end
    if Parameters.Barrier.Updating.fc.Update
        numPara = numPara + 1;
        Parameters.Barrier.Updating.fc.Index = numPara;
        Parameters.CorrHistory.IndKey{numPara} = 'Barrier Fc';
        CorrAlpha(numPara,:) = Parameters.Barrier.Updating.fc.Alpha;
    end
    if Parameters.Sidewalk.Updating.fc.Update
        numPara = numPara + 1;
        Parameters.Sidewalk.Updating.fc.Index = numPara;
        Parameters.CorrHistory.IndKey{numPara} = 'Sidewalk Fc';
        CorrAlpha(numPara,:) = Parameters.Sidewalk.Updating.fc.Alpha;
    end
     if Parameters.compAction.Updating.Ix.Update
        numPara = numPara + 1;
        Parameters.compAction.Updating.Ix.Index = numPara;
        Parameters.CorrHistory.IndKey{numPara} = 'Composite Ix';
        CorrAlpha(numPara,:) = Parameters.compAction.Updating.Ix.Alpha;
    end
    
    paraRange = numPara+1:numPara+length(nonzeros(Parameters.Bearing.Fixed.Update(1:7))); % find range of parameter indices
    doflabel = ['U1';'U2';'U3';'R1';'R2';'R3'];
    if ~isempty(paraRange)
        Parameters.Bearing.Fixed.Index(find(Parameters.Bearing.Fixed.Update)) =  paraRange; % apply index
        Parameters.CorrHistory.IndKey(paraRange) = mat2cell([padarray(['Fixed Bearing '],[length(paraRange)-1 0], 'replicate','post')...
            doflabel(find(Parameters.Bearing.Fixed.Update),:)],ones(length(paraRange),1));
        CorrAlpha(paraRange,:) = Parameters.Bearing.Fixed.Alpha(find(Parameters.Bearing.Fixed.Update),:); % apply alpha from parameters to master alpha list
        numPara = max(Parameters.Bearing.Fixed.Index); % update number of parameters
    end
    
    paraRange = numPara+1:numPara+length(nonzeros(Parameters.Bearing.Expansion.Update(1:7).*~Parameters.Bearing.Linked)); % find range of parameter indices
    if ~isempty(paraRange)
        Parameters.Bearing.Expansion.Index(find(Parameters.Bearing.Expansion.Update(1:7).*~Parameters.Bearing.Linked)) =  paraRange; % apply index
        Parameters.CorrHistory.IndKey(paraRange) = mat2cell([padarray(['Expansion Bearing '],[length(paraRange)-1 0], 'replicate','post')...
            doflabel(find(Parameters.Bearing.Expansion.Update(1:7).*~Parameters.Bearing.Linked),:)],ones(length(paraRange),1));
        CorrAlpha(paraRange,:) = Parameters.Bearing.Expansion.Alpha(find(Parameters.Bearing.Expansion.Update(1:7).*~Parameters.Bearing.Linked),:); % apply alpha from parameters to master alpha list
        numPara = max(Parameters.Bearing.Expansion.Index); % update number of parameters
    end
    
    Parameters.CorrAlpha = CorrAlpha;
    
    %% Initialize CorrHistory Variable to empty set
    Parameters.CorrHistory.FreqRes = [];
    Parameters.CorrHistory.MACRes = [];
    Parameters.CorrHistory.MAC = [];
    Parameters.CorrHistory.Alpha = [];
    Parameters.CorrHistory.ExpFreq = [];
    Parameters.CorrHistory.ExpDisp = [];
    Parameters.CorrHistory.AnaFreq = [];
    Parameters.CorrHistory.AnaDisp = [];
    Parameters.CorrHistory.COMAC = [];
    
    % Save Parameters to appdata
    setappdata(0,'Parameters', Parameters)
    
    %% Get Paired Coordinates
    pairedCoord = meshData.pairedCoord;
    
    ExpDisp = testData.U;
    ExpFreq = testData.freq;
    
    %% Set Options for Least Squares Non-Linear Optimization 
    outfun = @(x,optimValues,state)OutputFunction(x, optimValues, state, handles);
    
    options = optimset('Algorithm','trust-region-reflective','TolFun',TolFun,'TolX',TolX,...
        'Display','final','OutputFcn',outfun, 'DiffMinChange', DiffMinChange);
    
    Alpha = CorrAlpha(:,1);
    
    objfun = @(Alpha)SingleModelParameterEstimation(Alpha, uID, Options.St7.PathName, Options.St7.FileName,...
                                                        Options, Node,...
                                                        pairedCoord, ExpDisp, ExpFreq);
    
    [Alpha, resnorm, residual, exitflag, output, lambda]...
        = lsqnonlin(objfun, CorrAlpha(:,1), CorrAlpha(:,2), CorrAlpha(:,3), options);
    
    Parameters = getappdata(0,'Parameters');
    Parameters.CorrHistory.exitflag=exitflag;

    %% Apply New Alpha Values to Parameters and Adjust
    if Parameters.Beam.Updating.Ix.Update
        Parameters.Beam.Ix = Parameters.Beam.Ix*Alpha(Parameters.Beam.Updating.Ix.Index);
    end
    if Parameters.Deck.Updating.fc.Update
        Parameters.Deck.fc = Parameters.Deck.fc*Alpha(Parameters.Deck.Updating.fc.Index);
    end
    if Parameters.Dia.Updating.E.Update
        Parameters.Dia.E = Parameters.Dia.E*Alpha(Parameters.Dia.Updating.E.Index);
    end
    if Parameters.Barrier.Updating.fc.Update
        Parameters.Barrier.fc = Parameters.Barrier.fc*10^Alpha(Parameters.Barrier.Updating.fc.Index);
    end
    if Parameters.Sidewalk.Updating.fc.Update
        Parameters.Sidewalk.fc = Parameters.Sidewalk.fc*10^Alpha(Parameters.Sidewalk.Updating.fc.Index);
    end
     if Parameters.compAction.Updating.Ix.Update
        Parameters.compAction.Ix = Parameters.compAction.Ix*10^Alpha(Parameters.compAction.Updating.Ix.Index);
    end
    
    if any(Parameters.Bearing.Fixed.Update)
        Parameters.Bearing.Fixed.Spring(find(Parameters.Bearing.Fixed.Index)) = ...
            Parameters.Bearing.Fixed.Spring(find(Parameters.Bearing.Fixed.Index)).*...
            Parameters.Bearing.Fixed.Update(find(Parameters.Bearing.Fixed.Index)).*...
            10.^Alpha(nonzeros(Parameters.Bearing.Fixed.Index))';
    end
    if any(Parameters.Bearing.Expansion.Update)
        Parameters.Bearing.Expansion.Spring(find(Parameters.Bearing.Expansion.Index)) = ...
            Parameters.Bearing.Expansion.Spring(find(Parameters.Bearing.Expansion.Index)).*...
            Parameters.Bearing.Expansion.Update(find(Parameters.Bearing.Expansion.Index)).*...
            10.^Alpha(nonzeros(Parameters.Bearing.Expansion.Index))';
    end
    
    %% Reset Alpha Values
     % linear scale
    Parameters.Beam.Updating.Ix.Alpha = [1, 0.75, 1.25]; % 1x3 array - columns: [start alpha, min alpha, max alpha]
    Parameters.Deck.Updating.fc.Alpha = [1, 0.75, 1.25];
    Parameters.Dia.Updating.E.Alpha = [1, 0.75, 1.25];
    % log scale
    Parameters.compAction.Updating.Ix.Alpha = [0, -10, 0];
    Parameters.Barrier.Updating.fc.Alpha = [0, -10, 0];
    Parameters.Sidewalk.Updating.fc.Alpha = [0, -10, 0];
    Parameters.Bearing.Fixed.Alpha = bsxfun(@times, ones(7,3), [0, -5, 5]); % Nx3 array - columns: [start alpha, min alpha, max alpha]
    Parameters.Bearing.Expansion.Alpha = bsxfun(@times, ones(7,3), [0, -5, 5]);
end

end %ModelCorrelation


