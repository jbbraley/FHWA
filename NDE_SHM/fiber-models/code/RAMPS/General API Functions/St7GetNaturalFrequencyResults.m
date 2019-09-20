function [St7Mode, St7Disp] = St7GetNaturalFrequencyResults(uID,ModelPath,ModelName,ResultNodes)

global kNodeDisp

%% Open Results File
NumPrimary = 0;
NumSecondary = 0;
ModalResultPath = [ModelPath ModelName '.nfa']; 
[iErr, NumPrimary, NumSecondary] = calllib('St7API', 'St7OpenResultFile',...
                                        uID, ModalResultPath, '',...
                                        false, NumPrimary, NumSecondary);
HandleError(iErr);

%% Get number of results
NumModes=0;
[iErr, NumModes] = calllib('St7API','St7GetNFANumModes',uID,NumModes);
HandleError(iErr);

St7Mode = zeros(NumModes,10);
% St7Mode(:,1) - Freq
% St7Mode(:,2) - Mass
% St7Mode(:,3) - Stiffness
% St7Mode(:,4) - Damping
% St7Mode(:,5) - Trans. mass participation - first direction or total when
% not Global
% St7Mode(:,6) - Trans. mass participation - second direction or zero when
% not Global
% St7Mode(:,7) - Trans. mass participation - third direction or zero when
% not Global
% St7Mode(:,8) - Rot. mass participation - first direction or total when
% not Global
% St7Mode(:,9) - Rot. mass participation - second direction or zero when
% not Global
% St7Mode(:,10) - Rot. mass participation - third direction or zero when
% not Global

%% Get mass participation and frequency
for i=1:NumModes
    Mode = i;
    [iErr, St7Mode(i,:)] = calllib('St7API','St7GetModalResultsNFA',uID,Mode,St7Mode(i,:));
    HandleError(iErr);
end

%% Get Mode Shapes and Node Coords
if ~isempty(ResultNodes)
    result = zeros(6,1);
    St7Disp = zeros(length(ResultNodes),NumModes);
    for i=1:NumModes
        for j=1:length(ResultNodes)
            % Gets vert disp of each node
            [iErr, result] = calllib('St7API', 'St7GetNodeResult',...
                uID, kNodeDisp, ResultNodes(j), i, result);
            HandleError(iErr);
            St7Disp(j,i) = result(3);
        end
    end
else
    St7Disp = [];
end

%% Close Results Files
iErr = calllib('St7API', 'St7CloseResultFile', uID);
HandleError(iErr);

end      % ModalResults()