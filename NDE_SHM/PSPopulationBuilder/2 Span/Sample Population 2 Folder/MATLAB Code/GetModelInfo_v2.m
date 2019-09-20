function ModelSpace = GetModelInfo_v2(extDir)

% Get filenames of all parameter files
dirData = dir([extDir '\Models\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(10:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

% Get model info for all models
for ii = 1:length(fileList)   
% SAVE MODELSPACE ---------------------------------------------------------
 
modelName = fileList{ii}(1:end-4);
load([extDir '\Parameters\' modelName '_Para.mat']);

if ~strcmp(Parameters.Beam.Type, 'None')
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
    ModelSpace(ii).SectionName = Parameters.Beam.Name;
    ModelSpace(ii).BeamD = Parameters.Beam.d;
    ModelSpace(ii).Beamfc = Parameters.Beam.fc;
    ModelSpace(ii).NumStrands = Parameters.Beam.PSSteel.NumStrands;
    if Parameters.Spans > 1
        
    end

    % Section capacities
    ModelSpace(ii).Mn_pos = Parameters.Beam.Capacity.Mn_pos;
    if Parameters.Spans > 1
        ModelSpace(ii).Mn_neg = Parameters.Beam.Capacity.Mn_neg;
    end

    % Section DF
    ModelSpace(ii).DF = Parameters.Design.DF.DFInt;

    ModelSpace(ii).IntDesignTime = [];
    ModelSpace(ii).IntIterations = [];
    ModelSpace(ii).IntConstraints = [];

    %Ratings
    ModelSpace(ii).St1Inv_int = Parameters.Rating.LRFD.SL.Int.St1.Inv ;
    ModelSpace(ii).St1Op_int = Parameters.Rating.LRFD.SL.Int.St1.Op;
    ModelSpace(ii).Sv3Inv_int = Parameters.Rating.LRFD.SL.Int.Sv3.Inv;

    %%%%%%%%%%%%%%% EXTERIOR %%%%%%%%%%%%%%%%

    % Section DF
    ModelSpace(ii).DF_ext = Parameters.Design.DF.DFExt;

    ModelSpace(ii).ExtDesignTime = [];
    ModelSpace(ii).ExtIterations = [];
    ModelSpace(ii).ExtConstraints = [];
    
    %Ratings
    ModelSpace(ii).St1Inv_ext = Parameters.Rating.LRFD.SL.Ext.St1.Inv;
    ModelSpace(ii).St1Op_ext = Parameters.Rating.LRFD.SL.Ext.St1.Op;
    ModelSpace(ii).Sv3Inv_ext = Parameters.Rating.LRFD.SL.Ext.Sv3.Inv;
else
    ModelSpace(ii).modelName = [];
    ModelSpace(ii).Length = [];
    ModelSpace(ii).ExtWidth = [];
    ModelSpace(ii).Skew = [];
    ModelSpace(ii).SpanDepth = [];
    ModelSpace(ii).GirderSpacing = [];
    ModelSpace(ii).NumGirder = [];
    ModelSpace(ii).AdjustedWidth = [];
    ModelSpace(ii).Width = [];
    ModelSpace(ii).bf_int = [];
    ModelSpace(ii).tf_int = [];
    ModelSpace(ii).tw_int = [];
    ModelSpace(ii).tcp_int = [];
    ModelSpace(ii).Mn_int = [];
    ModelSpace(ii).Fn_int = [];
    ModelSpace(ii).DF_int = [];
    ModelSpace(ii).IntSectComp = [];
    ModelSpace(ii).IntFlangeComp = [];
    ModelSpace(ii).IntWebComp = [];
    ModelSpace(ii).IntDesignTime = [];
    ModelSpace(ii).IntIterations = [];
    ModelSpace(ii).IntConstraints = [];
    ModelSpace(ii).St1Inv_int = [] ;
    ModelSpace(ii).St1Op_int = [];
    ModelSpace(ii).Sv2Inv_int = [];
    ModelSpace(ii).Sv2Op_int = [];
    ModelSpace(ii).bf_ext = [];
    ModelSpace(ii).tf_ext = [];
    ModelSpace(ii).tw_ext = [];
    ModelSpace(ii).tcp_ext = [];
    ModelSpace(ii).Mn_ext = [];
    ModelSpace(ii).Fn_ext = [];
    ModelSpace(ii).DF_ext = [];
    ModelSpace(ii).ExtSectComp = [];
    ModelSpace(ii).ExtFlangeComp = [];
    ModelSpace(ii).ExtWebComp = [];
    ModelSpace(ii).ExtDesignTime = [];
    ModelSpace(ii).ExtIterations = [];
    ModelSpace(ii).ExtConstraints = [];
    ModelSpace(ii).St1Inv_ext = [];
    ModelSpace(ii).St1Op_ext = [];
    ModelSpace(ii).Sv2Inv_ext = [];
    ModelSpace(ii).Sv2Op_ext = [];
end
end

