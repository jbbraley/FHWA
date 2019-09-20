function SResults = NCHRP_SettlementSolver_v2(CaseName,barrCase,mPath,mName, pPath, oPath, nPath, ScratchPath)

    % Initialize
    global rtBeamStress rtBeamForce rtBeamDisp stBeamGlobal rtNodeReact
    Options = [];
    Parameters = [];
    ResultCase = 1;
    
    % Solver Options
    srBeamForce = 1; % Solve for Beam Reaction (bending)
    srNodeReaction = 1; % Solve for Node Reaction (shear)
    srElementNodeForce = 1; % Solve for Node Reaction (shear)
    spIncludeLinkReactions = 1; % Solver for Link Reactions
    ShearRating = 1;

    % Load in parameters, node, and options files
    load(pPath);
    load(nPath);
    load(oPath);

    % Sett Analysis Options
    Options.Solver.LSA.Entity.srBeamForce = srBeamForce; % Solve for Beam Reaction (bending)
    Options.Solver.LSA.Entity.srNodeReaction = srNodeReaction; % Solve for Node Reaction (shear)
    Options.Solver.LSA.Entity.srElementNodeForce = srElementNodeForce;
    Options.Solver.LSA.Defaults.spIncludeLinkReactions = spIncludeLinkReactions;

    % Load St7 Model files
    St7OpenModelFile(Options.St7.uID, mPath, Parameters.ModelName, ScratchPath);

    % Set solver options
    St7SetLSASolverOptions(Options.St7.uID, Parameters, Options);

    % Get freedom case number
    [LNumCases, LCaseName, FNumCases, FCaseName] = St7GetLoadAndFreedomCaseInfo(Options.St7.uID);
    [~, FCaseNum] = find(strcmp(FCaseName, CaseName));

    % Enable Freedom Case
    LoadCase_Sett = 1;
    LFCaseCombo = [LoadCase_Sett, FCaseNum];
    St7EnableLoadAndFreedomCase(Options.St7.uID, LFCaseCombo);

    % Barrier Stiffness
    switch barrCase
        case 'On'
            propList = [1,2];
            SetBeamStiffness(propList,'On',Parameters,Options.St7.uID)
        case 'Off'
            propList = [1,2]; 
            SetBeamStiffness(propList,'Off',Parameters,Options.St7.uID)
    end
    
    % Deck Stiffness
%     propList = 1;
%     SetShellStiffness(propList,'Off',Parameters,Options.St7.uID)

    % Run Static Solver
    SettResultPath = [ScratchPath mName '.lsa'];
    St7RunStaticSolver(Options.St7.uID, SettResultPath);

    % Disable Freedom Case
    St7DisableLoadAndFreedomCase(Options.St7.uID, LFCaseCombo);

    % Save 
    SaveModelFile(Options.St7.uID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% PULL SETTLEMENT RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%

    % Check for Result File    
%     if ~exist(st7Path ,'file')
%         continue
%     end

    % Open Result File
    St7OpenResultFile(Options.St7.uID, SettResultPath);

    % Find Results above supports
    % Set boundary restraints and deflections
    NumColumns = [6 18 6];
    BeamForce = zeros(NumColumns(1),1);
    BeamStress = zeros(NumColumns(2),1);
    BeamDisp = zeros(NumColumns(3),1);
    BeamRes{1} = zeros(size(nonzeros(Node(1).ID(:,1,1)),1)-1,Parameters.NumGirder,Parameters.Spans,6);
    BeamRes{2} = zeros(size(nonzeros(Node(1).ID(:,1,1)),1)-1,Parameters.NumGirder,Parameters.Spans,18);
    BeamRes{3} = zeros(size(nonzeros(Node(1).ID(:,1,1)),1)-1,Parameters.NumGirder,Parameters.Spans,6);
    ResultType = [rtBeamForce rtBeamStress rtBeamDisp];
    NodeResultType = rtNodeReact;
    SubType = stBeamGlobal;


    % Build array of beam nodes and beam numbers
    for kk = 1:Parameters.NumGirder

        for jj = 1:length(Node)

            y1 = find(any(Node(jj).ID(:,:,3)),1,'first');
            y2 = find(any(Node(jj).ID(:,:,3)),1,'last');
            y = (y2-y1)/(Parameters.NumGirder-1);

            row = y1+y*(kk-1);

            x1 = find(Node(jj).ID(:,row,3),1,'first');
            x2 = find(Node(jj).ID(:,row,3),1,'last');

            SupportNode1 = Node(jj).ID(x1,row,4);
            SupportNode2 = Node(jj).ID(x2,row,4);

            n = nonzeros(Node(jj).ID(:,row,3));

            beamNodes(1:length(n),kk,jj) = nonzeros(Node(jj).ID(:,row,3));

            for gg = 1:length(n)-1

                beamNums(gg,kk,jj) = Node(jj).ElementCon(beamNodes(gg,kk,jj),1);

                if beamNums(gg,kk,jj) == 0
                    BeamRes{1}(gg,kk,jj,:) = 0;
                    BeamRes{2}(gg,kk,jj,:) = 0;
                    BeamRes{3}(gg,kk,jj,:) = 0;
                else
                    % Get Beam Results from every beam
                    % Beam Forces
                     [iErr, NumColumns(1), BeamRes{1}(gg,kk,jj,:)] = calllib('St7API', 'St7GetBeamResultSinglePos', Options.St7.uID, ResultType(1), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(1), BeamForce);
                     HandleError(iErr);
                    % Beam Stresses
                     [iErr, NumColumns(2), BeamRes{2}(gg,kk,jj,:)] = calllib('St7API', 'St7GetBeamResultSinglePos', Options.St7.uID, ResultType(2), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(2), BeamStress);
                     HandleError(iErr);
                    % Beam end displacements 
                     [iErr, NumColumns(3), BeamRes{3}(gg,kk,jj,:)] = calllib('St7API', 'St7GetBeamResultSinglePos', Options.St7.uID, ResultType(3), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(3), BeamDisp);
                     HandleError(iErr);
                end

            end

            % Get Node Results from support nodes
            if jj == 1
                nRes = zeros(6,1);
                [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, NodeResultType , SupportNode1, ResultCase, nRes);
                HandleError(iErr);
                NodeRes(jj,kk,:) = nRes;

                nRes = zeros(6,1);
                [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, NodeResultType, SupportNode2, ResultCase, nRes);
                HandleError(iErr);
                NodeRes(jj+1,kk,:) = nRes;
            else
                nRes = zeros(6,1);
                [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, NodeResultType, SupportNode2, ResultCase, nRes);
                HandleError(iErr);
                NodeRes(jj+1,kk,:) = nRes;
            end
        end
    end

    SResults.BeamForce = BeamRes{1};
    SResults.BeamStress = BeamRes{1};
    SResults.BeamDisp = BeamRes{1};
    SResults.NodeRxn = NodeRes;
    SResults.beamNodes = beamNodes;
    SResults.beamNums = beamNums;

    St7CloseResultFile(Options.St7.uID);
    CloseModelFile(Options.St7.uID);
    
    % Delete St7 Result Files from ScratchPath
    delete([ScratchPath '\*.lsl']);
    delete([ScratchPath '\*.lsa']);
    
end