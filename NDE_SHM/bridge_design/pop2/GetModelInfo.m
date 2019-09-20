user_dir = uigetdir();
% Get filenames of all parameter files
dirData = dir([user_dir '\*.mat']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(10:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

% Get model info for all models
for ii = 1:length(fileList)   
% SAVE MODELSPACE ---------------------------------------------------------
 
modelName = fileList{ii};
load([user_dir '\' modelName]);


ModelSpace(ii).modelName = Parameters.ModelName;
ModelSpace(ii).Length = max(Parameters.Length);
ModelSpace(ii).ExtWidth = Parameters.TotalWidth;
ModelSpace(ii).Skew = Parameters.SkewNear;
ModelSpace(ii).GirderSpacing = Parameters.GirderSpacing;
ModelSpace(ii).NumGirder = Parameters.NumGirder;
ModelSpace(ii).AdjustedWidth = Parameters.RoadWidth;
ModelSpace(ii).Width = Parameters.Width;
ModelSpace(ii).beamType = Parameters.Beam.Type;

%%%%%%%%%%%%%%% INTERIOR %%%%%%%%%%%%%%%%

% Section dimensions

ModelSpace(ii).BeamD = Parameters.Beam.Int.d;
if strcmp(Parameters.structureType, 'Prestressed')
    ModelSpace(ii).Beamfc = Parameters.Beam.fc;
    ModelSpace(ii).SectionName = Parameters.Beam.Name;
    ModelSpace(ii).Mn_pos = Parameters.Beam.Mn_pos;
%     ModelSpace(ii).NumStrands = Parameters.Beam.PSSteel.NumStrands;
else
    ModelSpace(ii).Beamfc = [];
    if strcmp(Parameters.Beam.Type, 'Rolled')
        ModelSpace(ii).SectionName = Parameters.Beam.Int.SectionName;
    else
        ModelSpace(ii).SectionName = [];
    end
    ModelSpace(ii).Mn_pos = Parameters.Beam.Int.Mn_pos;
%     ModelSpace(ii).NumStrands = [];
end

% Section capacities
if Parameters.Spans > 1
    ModelSpace(ii).Mn_neg = Parameters.Beam.Capacity.Mn_neg;
end

end

model_table = struct2table(ModelSpace)
writetable(model_table,[user_dir '\model_info.csv'])

