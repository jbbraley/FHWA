function [obj, currentValues] = SingleModelParameterEstimation(Alpha, uID,...
                                                ModelPath, ModelName,...
                                                Options, Node,...
                                                pairedCoord, ExpDisp, ExpFreq)
% Get appdata
Parameters = getappdata(0,'Parameters');

%% Set Alpha Values
if Parameters.Beam.Updating.Ix.Update
    Parameters.Beam.Updating.Ix.Alpha(1) = Alpha(nonzeros(Parameters.Beam.Updating.Ix.Index));
end
if Parameters.Deck.Updating.fc.Update
    Parameters.Deck.Updating.fc.Alpha(1) = Alpha(nonzeros(Parameters.Deck.Updating.fc.Index));
end
if Parameters.Dia.Updating.E.Update
    Parameters.Dia.Updating.E.Alpha(1) = Alpha(nonzeros(Parameters.Dia.Updating.E.Index));
end
if Parameters.Barrier.Updating.fc.Update
    Parameters.Barrier.Updating.fc.Alpha(1) = Alpha(nonzeros(Parameters.Barrier.Updating.fc.Index));
end
if Parameters.Sidewalk.Updating.fc.Update
    Parameters.Sidewalk.Updating.fc.Alpha(1) = Alpha(nonzeros(Parameters.Sidewalk.Updating.fc.Index));
end
if Parameters.compAction.Updating.Ix.Update
    Parameters.compAction.Updating.Ix.Alpha(1) = Alpha(nonzeros(Parameters.compAction.Updating.Ix.Index));
end

if any(Parameters.Bearing.Fixed.Update)
    Parameters.Bearing.Fixed.Alpha(find(Parameters.Bearing.Fixed.Update),1) = Alpha(nonzeros(Parameters.Bearing.Fixed.Index));
end
if any(Parameters.Bearing.Expansion.Update)
    if any(Parameters.Bearing.Linked)
        Parameters.Bearing.Expansion.Alpha(find(Parameters.Bearing.Linked),1) = Alpha(nonzeros(Parameters.Bearing.Fixed.Index));
    end
    Parameters.Bearing.Expansion.Alpha(find(Parameters.Bearing.Expansion.Update),1) = Alpha(nonzeros(Parameters.Bearing.Expansion.Index));
end

%% Update Model
fprintf('Updating Model...');
Parameters = UpdateModelParameters(uID, Parameters, Node);

fprintf('Done\n');

%% Obtain Frequencies and Modeshapes from St7 Model
fprintf('Getting Modal Analysis Data...');

% Run Natural Frequency Analysis
Options.Analysis.ModeParticipation = 1;
ResultNodes = pairedCoord;
St7RunNaturalFrequencySolver(uID, ModelPath, ModelName, Options);
[St7Mode, St7Disp] = St7GetNaturalFrequencyResults(uID, ModelPath, ModelName, ResultNodes);

% Normalize St7 Mode Shapes
largest_val = (-min(St7Disp) < max(St7Disp)).*(max(St7Disp)-min(St7Disp))+min(St7Disp); 
St7Disp = bsxfun(@rdivide,St7Disp,largest_val);

% Get frequencies
St7Freq = St7Mode(:,1);

fprintf('Done\n');

%% Pair Frequencies and Mode Shapes Based on MAC
fprintf('Calculating MAC and Objective Function...');

numCorrMode = length(Options.Correlation.expModes);
numAnaMode = length(St7Freq);
corrMode = Options.Correlation.expModes;

% Calculate MAC
MAC = GetMACValue(ExpDisp, St7Disp);

%%%%%%% Don't Enforce Mode Order %%%%%%
C = zeros(numCorrMode,1);
I = zeros(numCorrMode,1);
MACsearchindex=1:numAnaMode;

for i=1:numCorrMode
    % Find index of max MAC value for current experimental frequency
    % Use this to pair exp to analytical frequency
    [~,ind] = max(MAC(corrMode(i),MACsearchindex),[],2);
    I(i) = MACsearchindex(ind);
    C(i) = MAC(corrMode(i),MACsearchindex(ind));
    % Subtract out analytical mode vector from MAC search index so it cannot be
    % paired with any other experimental mode
    MACsearchindex(ind)=[];
end
meshData.pairedModes(:,1) = Options.Correlation.expModes;
meshData.pairedModes(:,2) = I;
meshData.pairedMAC = C;

%%%%%%% Modify MAC using max displacement f

%% Calculate the CoMAC
CM = GetCOMACValue(St7Disp(:,I),ExpDisp(:,corrMode));

%% Calculate the objective function
obj=zeros(numCorrMode*2,1);
for i=1:numCorrMode
    obj(2*i-1)=abs((ExpFreq(meshData.pairedModes(i,1))-St7Freq(meshData.pairedModes(i,2),1))/ExpFreq(i));
    obj(2*i)=(1-meshData.pairedMAC(i));
end

% obj=zeros(numCorrMode,1);
% for i=1:numCorrMode
%     obj(i)=abs((ExpFreq(meshData.pairedModes(i,1))-St7Freq(meshData.pairedModes(i,2),1))/ExpFreq(meshData.pairedModes(i,1)));
%     MACRes=(1-meshData.pairedMAC(i));
% end

% Check for frequency weighting
switch Options.Correlation.freqWeight
    case 'None'
        freqWeight = ones(numCorrMode,1);
    case 'Inverse Order'
        inverse = 1./(1:numCorrMode); % take inverse of order
        freqWeight = inverse./sum(inverse); % take fraction of sum of vector
        obj(1:2:end-1) = obj(1:2:end-1).*freqWeight';
end

%% Store Data
currentValues.FreqRes = obj(1:2:end-1);
currentValues.MACRes = obj(2:2:end);
% currentValues.FreqRes = obj;
% currentValues.MACRes = MACRes;
currentValues.MAC = MAC;
currentValues.Alpha = Alpha;
currentValues.ExpFreq = ExpFreq;
currentValues.ExpDisp = ExpDisp;
currentValues.AnaDisp = St7Disp;
currentValues.AnaFreq = St7Freq;
currentValues.COMAC = CM;
setappdata(0,'currentValues',currentValues);
setappdata(0,'Parameters',Parameters);
fprintf('Done\n');
end %SingleModelParameterEstimation