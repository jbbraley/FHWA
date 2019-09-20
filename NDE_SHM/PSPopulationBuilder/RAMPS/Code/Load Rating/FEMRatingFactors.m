% 10.01.14 - jbb - Replaced Parameters.NumLane with Parameters.NumRatingLane

function [Parameters, Argout] = FEMRatingFactors(Parameters, Arg, Code)

switch Parameters.structureType
    case 'Steel'
        Section = {'Int' 'Ext'};
        % Set applicable parameters
        if strcmp(Code, 'ASD')
            fIOp_pos = {'FnOp'};
            fIInv_pos = {'FnInv'};
            F1 = 1;
            F2 = 1;
            F3 = 1;
            F4 = 1;
            F5 = 1;

            State = 'St1';
            Demand = {'Stress'};

        elseif strcmp(Code, 'LRFD')
            if Parameters.Beam.Int.SectionComp
                % Capacity Parameters for compact sections
                fIOp_pos = {'Fy'; 'Mn_pos'};
                fIOp_neg = {'Fy'; 'Fn_neg'};
                fIInv_pos = {'Fy'; 'Mn_pos'};
                fIInv_neg = {'Fy'; 'Fn_neg'};
                % Demand responses for positive moment regions
                Demand = {'Stress'; 'Moment'};
            else
                % Capacity Parameters for non-compact sections
                fIOp_pos = {'Fy'; 'Fn_pos'};
                fIOp_neg = {'Fy'; 'Fn_neg'};
                fIInv_pos = {'Fy'; 'Fn_pos'};
                fIInv_neg = {'Fy'; 'Fn_neg'};
                % Demand responses for positive moment regions
                Demand = {'Stress'; 'Stress'};
            end
            % Factors
            F1 = [0.95 1.0];
            F2 = [1.0 1.35];
            F3 = [1.30 1.75];
            F4 = [1.0 1.25];
            F5 = [1.0 1.5];
            % Limit States (Service II & Strength I for Steel Girder)
            State = ['Sv2';'St1'];    
        end
        
        
    case 'Prestressed'
        % Capacity Parameters for compact sections
        fIOp_pos = {''; 'Parameters.Beam.Mn_pos'};
        fIInv_pos = {'Parameters.Beam.Fn_pos'; 'Parameters.Beam.Mn_pos'};
        % Demand responses for positive moment regions
        Demand = {'Stress'; 'Moment'};

        % Factors
        F1 = [1.0 1.0];
        F2 = [1.0 1.35];
        F3 = [0.8 1.75];
        F4 = [1.0 1.25];
        F5 = [1.0 1.50];
        % Limit States (Service III & Strength I for Prestressed Girder)
        State = ['Sv3';'St1'];    

        % Check for variable
        if ~isfield(Parameters.Design, 'IMF')
            Parameters.Design.IMF = 1.33;
        end
        
        BeamA = Parameters.Beam.A;
        BeamS1 = Parameters.Beam.Sb;
        BeamS2_int = Parameters.Beam.I.Iy/Parameters.Beam.xb;        
end


%% Dead Load
% Get results from root
DLR = Arg.FEM.DLR;
% Combine DL results and compute stresses
Parameters.Demands = CombineDLR(DLR, Parameters, Parameters.Demands);
%% Live Load
% Get results from root
LLR = Arg.FEM.LLR;
% Combine LL results for different lane and truck loading scenarios
Parameters.Demands = CombineLLR(LLR, Parameters, Parameters.Demands);

%% Compute Rating Factors

% Rate for Interior or exterior section
for kk = 1:length(Section)
    % Rate for applicable limit states
    for jj = 1:length(F2)  
        %Inventory Rating Factor
        % Compute rating factors for all girders and all positve moment regions for
        % all three lane positions
        if ~isempty(fIInv_pos{jj})
            for ii=1:size(Parameters.Demands.Int.FEM.LiveLoad.Stress_Pos,3)
                RFInv_allP(:,:,ii) = (F1(jj)*Arg.Capacity.(Section{kk}).(fIInv_pos{jj}) - F4(jj)*abs(sum(Parameters.Demands.(Section{kk}).FEM.DeadLoad.([Demand{jj} '_Pos'])(:,:,1:2),3))...
                    -F5(jj)*abs(Parameters.Demands.(Section{kk}).FEM.DeadLoad.([Demand{jj} '_Pos'])(:,:,3)))./(F3(jj)*abs(Parameters.Demands.(Section{kk}).FEM.LiveLoad.([Demand{jj} '_Pos'])(:,:,ii)));
            end
            % Find lane position that creates lowest rating 
            [RFInvLaneP, RFInvP_indL] = min(RFInv_allP,[],3);
            % Find locations with minimum 
            [RFInvLocP, RFInvP_ind] = min(RFInvLaneP,[],2);
            % Find girder with minimum
            [RFInvGirdP, RFInvP_ind2] = min(RFInvLocP);
            % Organize Indices into vector (Girder, Location, Max or Min stress)
            ind(1,:) = [RFInvP_ind2 RFInvP_ind(RFInvP_ind2) RFInvP_indL(RFInvP_ind(RFInvP_ind2))];
        end
        % Compute rating factors for all girders and all negative moment regions
        if Parameters.Spans~=1 && ~isempty(fIInv_neg{jj})
            for ii=1:size(Parameters.Demands.Int.FEM.LiveLoad.Stress_Neg,3)
                RFInv_allN(:,:,ii) = (F1(jj)*Arg.Capacity.(Section{kk}).(fIInv_neg{jj}) - F4(jj)*abs(sum(Parameters.Demands.(Section{kk}).FEM.DeadLoad.([Demand{jj} '_Neg'])(:,:,1:2),3))...
                    -F5(jj)*abs(Parameters.Demands.(Section{kk}).FEM.DeadLoad.([Demand{jj} '_Neg'])(:,:,3)))./(F3(jj)*abs(Parameters.Demands.(Section{kk}).FEM.LiveLoad.([Demand{jj} '_Neg'])(:,:,ii)));
            end
            % Find lane position that creates lowest rating 
            [RFInvLaneN, RFInvN_indL] = min(RFInv_allN,[],3);
            % Find locations with minimum 
            [RFInvLocN, RFInvN_ind] = min(RFInvLaneN,[],2);
            % Find girder with minimum
            [RFInvGirdN, RFInvN_ind2] = min(RFInvLocN);
            % Organize Indices into vector (Girder, Location, Max or Min stress)
            ind(2,:) = [RFInvN_ind2 RFInvN_ind(RFInvN_ind2) RFInvN_indL(RFInvN_ind(RFInvN_ind2))];

            % Find overall minimum rating (positive or negative moment region)
            [RFInv, ind3] = min([RFInvGirdP,RFInvGirdN]);
            RFInv_ind = [ind3 ind(ind3,:)]; %Positive or Neg. moment region, Girder, Location along bridge, max or min stress
        else
            try
            % If only a single span--only a positive moment region
            RFInv = RFInvGirdP;
            % Indexed location of minimum rating factor
            RFInv_ind = [1 ind(1,:)]; %Positive moment region, Girder, Location along bridge, max or min stress
            catch
            end
        end

        %Operating Rating Factor
        if ~isempty(fIOp_pos{jj})
            for ii=1:size(Parameters.Demands.Int.FEM.LiveLoad.Stress_Pos,3)
                % Compute rating factors for all girders and all positve moment regions and
                % all 3 lane positions
                RFOp_allP(:,:,ii) = (F1(jj)*Arg.Capacity.(Section{kk}).(fIOp_pos{jj}) - F4(jj)*abs(sum(Parameters.Demands.(Section{kk}).FEM.DeadLoad.([Demand{jj} '_Pos'])(:,:,1:2),3))...
                    -F5(jj)*abs(Parameters.Demands.(Section{kk}).FEM.DeadLoad.([Demand{jj} '_Pos'])(:,:,3)))./(F2(jj)*abs(Parameters.Demands.(Section{kk}).FEM.LiveLoad.([Demand{jj} '_Pos'])(:,:,ii)));
            end
            % Find lane position that creates lowest rating 
            [RFOpLaneP, RFOpP_indL] = min(RFOp_allP,[],3);
            % Find locations with minimum 
            [RFOpLocP, RFOpP_ind] = min(RFOpLaneP,[],2);
            % Find girder with minimum
            [RFOpGirdP, RFOpP_ind2] = min(RFOpLocP);
            % Organize Indices into vector (Girder, Location, Max or Min stress)
            ind(1,:) = [RFOpP_ind2 RFOpP_ind(RFOpP_ind2) RFOpP_indL(RFOpP_ind(RFOpP_ind2))];
        end

        if Parameters.Spans~=1 && ~isempty(fIOp_neg{jj})
            for ii=1:size(Parameters.Demands.Int.FEM.LiveLoad.Stress_Neg,3)
                % Compute rating factors for all girders and all negative moment regions
                RFOp_allN(:,:,ii) = (F1(jj)*Arg.Capacity.(Section{kk}).(fIOp_neg{jj}) - F4(jj)*abs(sum(Parameters.Demands.(Section{kk}).FEM.DeadLoad.([Demand{jj} '_Neg'])(:,:,1:2),3))...
                    -F5(jj)*abs(Parameters.Demands.(Section{kk}).FEM.DeadLoad.([Demand{jj} '_Neg'])(:,:,3)))./(F2(jj)*abs(Parameters.Demands.(Section{kk}).FEM.LiveLoad.([Demand{jj} '_Neg'])(:,:,ii)));
            end
            % Find lane position that creates lowest rating 
            [RFOpLaneN, RFOpN_indL] = min(RFOp_allN,[],3);
            % Find locations with minimum 
            [RFOpLocN, RFOpN_ind] = min(RFOpLaneN,[],2);
            % Find girder with minimum
            [RFOpGirdN, RFOpN_ind2] = min(RFOpLocN);
            % Organize Indices into vector (Girder, Location, Lane Position)
            ind(2,:) = [RFOpN_ind2 RFOpN_ind(RFOpN_ind2) RFOpN_indL(RFOpN_ind(RFOpN_ind2))];


            % Find overall minimum rating (positive or negative moment region)
            [RFOp, ind3] = min([RFOpGirdP,RFOpGirdN]);
            % Indexed location of minimum rating factor
            RFOp_ind = [ind3 ind(ind3,:)]; %Positive or Neg. region, Girder, Location along bridge, Lane Position
        else
            try
                % If only a single span--only a positive moment region
                RFOp = RFOpGirdP;
                % Indexed location of minimum rating factor
                RFOp_ind = [1 ind(1,:)];
            catch
            end
        end

        %% Store Rating Factors in Parameters

        % Minimum Factors
        try
            Argout.(Section{kk}).(State(jj,:)).RFOp = RFOp;
            Argout.(Section{kk}).(State(jj,:)).LocationOp = RFOp_ind;
        catch
        end
        try
            Argout.(Section{kk}).(State(jj,:)).RFInv = RFInv;
            Argout.(Section{kk}).(State(jj,:)).LocationInv = RFInv_ind;
        catch
        end

        % All Factors
        % Reorder factors to be coherant with bridge geometry
        % Operating Factors
        if exist('RFOp_allP','var') 
            Argout.(Section{kk}).(State(jj,:)).RatingFactors_Op(:,1:2:2*Parameters.Spans-1,:)  = RFOp_allP;
            RFOp_allP = [];
        end

        if exist('RFOp_allN','var')    
            Argout.(Section{kk}).(State(jj,:)).RatingFactors_Op(:,2:2:end-1,:) = RFOp_allN;
            RFOp_allN = [];
        end
        %Inventory Ratings
        if exist('RFInv_allP','var') 
        Argout.(Section{kk}).(State(jj,:)).RatingFactors_Inv(:,1:2:2*Parameters.Spans-1,:)  = RFInv_allP;
        RFInv_allP = [];
        end
        if exist('RFInv_allN','var')    
            Argout.(Section{kk}).(State(jj,:)).RatingFactors_Inv(:,2:2:end-1,:) = RFInv_allN;
            RFInv_allN = [];
        end
    end
end

% Save Stresses and Moments
for kk=1:length(Section)
    switch Section{kk}
        case 'Int'
            Sind = 2:Parameters.NumGirder-1;
        case 'Ext'
            Sind = [1 Parameters.NumGirder];
        otherwise
            Sind = 1:size(Parameters.Demands.(Section{kk}).FEM.DeadLoad.Stress_Pos,1);
    end
    Argout.DeadLoadStresses(Sind,1:2:2*Parameters.Spans-1,:) = Parameters.Demands.(Section{kk}).FEM.DeadLoad.Stress_Pos;
    Argout.DeadLoadStresses(Sind,1:2:2*Parameters.Spans-1,:) = Parameters.Demands.(Section{kk}).FEM.DeadLoad.Stress_Pos;
    Argout.LiveLoadStresses(Sind,1:2:2*Parameters.Spans-1,:) = Parameters.Demands.(Section{kk}).FEM.LiveLoad.Stress_Pos;
    Argout.DeadLoadMoments(Sind,1:2:2*Parameters.Spans-1,:) = Parameters.Demands.(Section{kk}).FEM.DeadLoad.Moment_Pos;
    Argout.LiveLoadMoments(Sind,1:2:2*Parameters.Spans-1,:) = Parameters.Demands.(Section{kk}).FEM.LiveLoad.Moment_Pos;
    if exist('DLStress_Neg','var')    
        Argout.DeadLoadStresses(Sind,2:2:end-1,:) = Parameters.Demands.(Section{kk}).FEM.DeadLoad.Stress_Neg;
        Argout.LiveLoadStresses(Sind,2:2:end-1,:) = Parameters.Demands.(Section{kk}).FEM.LiveLoad.Stress_Neg;
        Argout.DeadLoadMoments(Sind,2:2:end-1,:) = Parameters.Demands.(Section{kk}).FEM.DeadLoad.Moment_Neg;
        Argout.LiveLoadMoments(Sind,2:2:end-1,:) = Parameters.Demands.(Section{kk}).FEM.LiveLoad.Moment_neg;
    end
end

end %RatingFactors()