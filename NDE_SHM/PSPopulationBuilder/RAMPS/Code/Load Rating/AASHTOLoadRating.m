function [Parameters, Arg] = AASHTOLoadRating(Arg, Parameters)

if ~isfield(Parameters.Demands.Int.SL.DeadLoad,'MDL_pos')
    Parameters.Demands.Int.SL = GetSectionForces(Parameters.Beam.Int, Parameters,'None','Int');
    Parameters.Demands.Ext.SL = GetSectionForces(Parameters.Beam.Ext, Parameters,'None','Ext');
end

if strcmp(Parameters.Rating.Code, 'ASD')
    Arg.Capacity.Int.FnOp = 0.75*Parameters.Beam.Fy;
    Arg.Capacity.Ext.FnOp = 0.75*Parameters.Beam.Fy;
    Arg.Capacity.Int.FnInv = 0.55*Parameters.Beam.Fy;
    Arg.Capacity.Ext.FnInv = 0.55*Parameters.Beam.Fy;
    
    Arg.IMF = 50./(Parameters.Length/12+125)+1;
    if Arg.IMF > 1.3
        Arg.IMF = 1.3;
    end
    
    % Lanes Manual for Bridge Evaluation 2011 6B.6.2.2 
    if Parameters.RoadWidth >= 18*12 && Parameters.RoadWidth <= 24*12
        Arg.NumLane = 2;
        Arg.LaneWidth = Parameters.RoadWidth/2;
    elseif Parameters.RoadWidth > 24*12
        Arg.NumLane = floor(Parameters.RoadWidth/144);
        Arg.LaneWidth = 12*12;
    else
        Arg.NumLane = 1;
        Arg.LaneWidth = min([12*12 Parameters.RoadWidth]);
    end
    
elseif strcmp(Parameters.Rating.Code, 'LRFD')
%     if isfield(Parameters.Beam.Int, 'Fn_pos') && ~Arg.useCB
%         Arg.Capacity.Int.Dcp = Parameters.Beam.Int.Dcp;
%         Arg.Capacity.Int.Mn_pos = Parameters.Beam.Int.Mn_pos;
%         Arg.Capacity.Int.Fn_pos = Parameters.Beam.Int.Fn_pos;
%         Arg.Capacity.Int.Vn = Parameters.Beam.Int.Vn;
%         Arg.Capacity.Ext.Dcp = Parameters.Beam.Ext.Dcp;
%         Arg.Capacity.Ext.Mn_pos = Parameters.Beam.Ext.Mn_pos;
%         Arg.Capacity.Ext.Fn_pos = Parameters.Beam.Ext.Fn_pos;
%         Arg.Capacity.Ext.Vn = Parameters.Beam.Ext.Vn;
%         if Parameters.Spans ~=1
%         Arg.Capacity.Int.Fcrw = Parameters.Beam.Int.Fcrw;
%         Arg.Capacity.Int.Fn_neg = Parameters.Beam.Int.Fn_neg;
%         Arg.Capacity.Ext.Fcrw = Parameters.Beam.Ext.Fcrw;
%         Arg.Capacity.Ext.Fn_neg = Parameters.Beam.Ext.Fn_neg;
%         end     
%     else
        
        if Arg.useCB
            Arg.Cb_int = GetMomentGradient(Parameters.Beam.Int,Parameters.Demands.Int.SL,Parameters);
            Arg.Cb_ext = GetMomentGradient(Parameters.Beam.Ext,Parameters.Demands.Ext.SL,Parameters);
        else
            Arg.Cb_int = 1;
            Arg.Cb_ext = 1;
        end
        Arg.Capacity.Int = GetLRFDResistance(Parameters.Beam.Int, Parameters.Demands.Int.SL, Parameters, 'Int',Arg.Cb_int);
        Arg.Capacity.Ext = GetLRFDResistance(Parameters.Beam.Ext, Parameters.Demands.Ext.SL, Parameters, 'Ext',Arg.Cb_ext);
%     end
    Arg.Capacity.Int.Fy = Parameters.Beam.Fy;
    Arg.Capacity.Ext.Fy = Parameters.Beam.Fy;
    
    
    Arg.IMF = 1.33;    
    
    %Multipresence factors - To be used only with Lever Rule
    Arg.MulPres(1) = 1.2;
    Arg.MulPres(2) = 1;
    Arg.MulPres(3) = 0.85;
    Arg.MulPres(4) = 0.65;
    
    % Lanes LRFD 2011 6A.2.3.2 
    if Parameters.RoadWidth >= 18*12 && Parameters.RoadWidth <= 24*12
        Arg.NumLane = 2;
        Arg.LaneWidth = Parameters.RoadWidth/2;
    elseif Parameters.RoadWidth > 24*12
        Arg.NumLane = floor(Parameters.RoadWidth/144);
        Arg.LaneWidth = 12*12;
    else
        Arg.NumLane = 1;
        Arg.LaneWidth = min([12*12 Parameters.RoadWidth]);
    end
    
    
end
% Shoulder
Arg.Shldr = (Parameters.RoadWidth - Arg.NumLane*Arg.LaneWidth)/2;

% Offset to move truck to within 2' of lane edge
Arg.LaneOffset = (Arg.LaneWidth-6*12)/2-24;
end