function ModelSpace = GetModelInfo_v2(Path)

% Get filenames of all parameter files
dirData = dir([Path '\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(8:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

% Get model info for all models
for ii = 1:length(fileList)   
% SAVE MODELSPACE ---------------------------------------------------------
 
modelName = fileList{ii}(1:end-4);
load([Path '\Parameters\' modelName '_Para.mat']);

if ~strcmp(Parameters.Beam.Type, 'None')
    ModelSpace(ii).modelName = Parameters.ModelName;
    ModelSpace(ii).Length = max(Parameters.Length);
    ModelSpace(ii).ExtWidth = Parameters.TotalWidth;
    ModelSpace(ii).Skew = Parameters.SkewNear;
    ModelSpace(ii).SpanDepth = Parameters.Design.MaxSpantoDepth;
    ModelSpace(ii).GirderSpacing = Parameters.GirderSpacing;
    ModelSpace(ii).NumGirder = Parameters.NumGirder;
    ModelSpace(ii).AdjustedWidth = Parameters.RoadWidth;
    ModelSpace(ii).Width = Parameters.Width;
    ModelSpace(ii).beamType = Parameters.Beam.Type;

    %%%%%%%%%%%%%%% INTERIOR %%%%%%%%%%%%%%%%

    % Section dimensions
    ModelSpace(ii).bf_int = Parameters.Beam.Int.bf;
    ModelSpace(ii).tf_int = Parameters.Beam.Int.tf;
    ModelSpace(ii).tw_int = Parameters.Beam.Int.tw;
    if Parameters.Spans > 1
        ModelSpace(ii).tcp_int = Parameters.Beam.Int.CoverPlate.t;
    end

    % Section capacities
    ModelSpace(ii).Mn_int = Parameters.Beam.Int.Mn_pos;
    if Parameters.Spans > 1
        ModelSpace(ii).Fn_int = Parameters.Beam.Int.Fn_neg;
    end

    % Section DF
    ModelSpace(ii).DF_int = Parameters.Design.DF.DFInt;

    % Compact/Non-compact
    ModelSpace(ii).IntSectComp = Parameters.Beam.Int.SectionComp;
    if Parameters.Spans > 1
        ModelSpace(ii).IntFlangeComp = Parameters.Beam.Int.FlangeComp;
        ModelSpace(ii).IntWebComp = Parameters.Beam.Int.WebComp;
    end

    % Design Time, Iterations, Constraints
    if strcmp(Parameters.Beam.Type, 'Plate')
        ModelSpace(ii).IntDesignTime = Parameters.Beam.Int.DesignTime;
        ModelSpace(ii).IntIterations = Parameters.Beam.Int.Iterations;
        ModelSpace(ii).IntConstraints = Parameters.Beam.Int.Constraints;
    elseif strcmp(Parameters.Beam.Type, 'Rolled')
        ModelSpace(ii).IntDesignTime = [];
        ModelSpace(ii).IntIterations = [];
        ModelSpace(ii).IntConstraints = [];
    end

    %Ratings
    ModelSpace(ii).St1Inv_int = Parameters.Rating.LRFD.SL.Int.St1.Inv ;
    ModelSpace(ii).St1Op_int = Parameters.Rating.LRFD.SL.Int.St1.Op;
    ModelSpace(ii).Sv2Inv_int = Parameters.Rating.LRFD.SL.Int.Sv2.Inv;
    ModelSpace(ii).Sv2Op_int = Parameters.Rating.LRFD.SL.Int.Sv2.Op;

    %%%%%%%%%%%%%%% EXTERIOR %%%%%%%%%%%%%%%%

    % Section dimensions
    ModelSpace(ii).bf_ext = Parameters.Beam.Ext.bf;
    ModelSpace(ii).tf_ext = Parameters.Beam.Ext.tf;
    ModelSpace(ii).tw_ext = Parameters.Beam.Ext.tw;
    if Parameters.Spans > 1
        ModelSpace(ii).tcp_ext = Parameters.Beam.Ext.CoverPlate.t;
    end

    % Section capacities
    ModelSpace(ii).Mn_ext = Parameters.Beam.Ext.Mn_pos;
    if Parameters.Spans > 1
        ModelSpace(ii).Fn_ext = Parameters.Beam.Ext.Fn_neg;
    end

    % Section DF
    ModelSpace(ii).DF_ext = Parameters.Design.DF.DFExt;

    % Compact/Non-compact
    ModelSpace(ii).ExtSectComp = Parameters.Beam.Int.SectionComp;
    if Parameters.Spans > 1
        ModelSpace(ii).ExtFlangeComp = Parameters.Beam.Int.FlangeComp;
        ModelSpace(ii).ExtWebComp = Parameters.Beam.Int.WebComp;
    end

    % Design Time, Iterations, Constraints
    if strcmp(Parameters.Beam.Type, 'Plate')
        ModelSpace(ii).ExtDesignTime = Parameters.Beam.Ext.DesignTime;
        ModelSpace(ii).ExtIterations = Parameters.Beam.Ext.Iterations;
        ModelSpace(ii).ExtConstraints = Parameters.Beam.Ext.Constraints;
    elseif strcmp(Parameters.Beam.Type, 'Rolled')
        ModelSpace(ii).ExtDesignTime = [];
        ModelSpace(ii).ExtIterations = [];
        ModelSpace(ii).ExtConstraints = [];
    end
    
    %Ratings
    ModelSpace(ii).St1Inv_ext = Parameters.Rating.LRFD.SL.Ext.St1.Inv;
    ModelSpace(ii).St1Op_ext = Parameters.Rating.LRFD.SL.Ext.St1.Op;
    ModelSpace(ii).Sv2Inv_ext = Parameters.Rating.LRFD.SL.Ext.Sv2.Inv;
    ModelSpace(ii).Sv2Op_ext = Parameters.Rating.LRFD.SL.Ext.Sv2.Op;
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

