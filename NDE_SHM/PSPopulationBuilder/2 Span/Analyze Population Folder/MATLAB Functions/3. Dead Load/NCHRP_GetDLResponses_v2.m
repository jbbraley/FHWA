% NCHRP_GetDLRespones
% Run DeadLoadSolver() and pull DL results
clc
clear

fprintf('Retrieving Dead Load Responses...\n');
h = waitbar(0,'Initializing Dead Load Solver...');

global rtBeamStress rtBeamForce rtNodeReact stBeamGlobal rtBeamDisp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SET-UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% USER INPUTS -------------------------------------------------------------
    
    % Directory
    tempPath = 'D:\Files\Documents\PSPopulationBuilder\Analyze Population Folder';
    externalPath = 'D:\Files\Documents\PSPopulationBuilder\Analyze Population Folder';

    % Function Options
    RunDLS = 1;
    RunDLR = 1;
    SaveExternal = 0;
    Start = 1;
    
    % Solver Options
    srBeamForce = 1; % Solve for Beam Reaction (bending)
    srNodeReaction = 1; % Solve for Node Reaction (shear)
    ShearRating = 1;
    srElementNodeForce = 1;
    spIncludeLinkReactions = 1; % Solver for Link Reactions
    
% Analysis Options --------------------------------------------------------

%     BoundCases = {'PA';'FA';'PP';'FP'}; % P = Pinned or Pier, F = Fixed, A = Abutment
    BoundCases = {'PA';'PP'};
%     BoundCases = {'PA'};
    
% GET LIST OF MODEL FILES -------------------------------------------------

    dirData = dir([tempPath '\Model Files\*.st7']);
    for ii = 1:length(dirData)
        dirData(ii).ind = str2double(dirData(ii).name(8:end-4));
    end
    [~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
    fileList = {dirData(:).name}';

% LOOP THROUGH MODELS -----------------------------------------------------

for ii = Start:length(fileList)
    
    fprintf(['\t Bridge ' num2str(ii) ':\n']);

    % Model Name and paths
    mName = fileList{ii}(1:end-4);
    
    for aa = 1:length(BoundCases)
        
        % Define Solver Case
        SolverCase = BoundCases{aa};
        fprintf(['\t \t' SolverCase '...']);
        [~, ~, ~, boundCase, rPath, st7Path, mPath, pPath, oPath, nPath, rPathEXT, st7PathEXT] =...
            GetSolverCaseInfo(SolverCase,mName,tempPath,externalPath,'DL');
    
        % Load in parameters, node, and options files
        load(pPath);
        load(nPath);
        load(oPath); 

        % Load St7 API
        St7Start = 1;
        [~, Options] = InitializeRAMPS(Options, Parameters, St7Start); 

        % Assign Analysis options
        Options.Solver.LSA.Entity.srBeamForce = srBeamForce; % Solve for Beam Reaction (bending)
        Options.Solver.LSA.Entity.srNodeReaction = srNodeReaction; % Solve for Node Reaction (shear)
        Options.Solver.LSA.Entity.srElementNodeForce = srElementNodeForce;
        Options.LoadRating.ShearRating = ShearRating;
        Options.Solver.LSA.Defaults.spIncludeLinkReactions = spIncludeLinkReactions;

        % Load St7 Model
        St7OpenModelFile(Options.St7.uID, mPath, Parameters.ModelName, Options.St7.ScratchPath);

        % Set solver options
        St7SetLSASolverOptions(Options.St7.uID, Parameters, Options);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DL SOLVER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Get freedom case number
        [LNumCases, LCaseName, FNumCases, FCaseName] = St7GetLoadAndFreedomCaseInfo(Options.St7.uID);
        [~, FCaseNum] = find(strcmp(FCaseName, boundCase));

        % Run DeadLoadSolver()
        if RunDLS
            waitbar(ii/length(fileList), h, ['Running DL Solver for Bridge ' num2str(ii)]);
            DLCase = 2;
            DeadLoadSolver(Options.St7.uID, Parameters.ModelName, st7Path, Parameters, DLCase, FCaseNum);
        end

        % Run DeadLoadResults()
        if RunDLR
            ResultCase = 1;

            waitbar(ii/length(fileList), h, ['Retrieving DL Results for Bridge ' num2str(ii)]);

            % Preallocate for results storage
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

            % Apply loads
            DeadLoads = 1:2;
            for dd = DeadLoads
                DeadLoadType = dd;

                % Open Appropriate Result File
                DeadLoadResultPath = [st7Path mName '_' num2str(DeadLoadType) '.lsa'];
                St7OpenResultFile(Options.St7.uID,DeadLoadResultPath)

                % Pull Results along entire length of girder
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
                                 [iErr, NumColumns(1), BeamRes{1}(gg,kk,jj,:)] = calllib('St7API', 'St7GetBeamResultSinglePos', ...
                                     Options.St7.uID, ResultType(1), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(1), BeamForce);
                                 HandleError(iErr);
                                % Beam Stresses
                                 [iErr, NumColumns(2), BeamRes{2}(gg,kk,jj,:)] = calllib('St7API', 'St7GetBeamResultSinglePos', ...
                                     Options.St7.uID, ResultType(2), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(2), BeamStress);
                                 HandleError(iErr);
                                % Beam end displacements 
                                 [iErr, NumColumns(3), BeamRes{3}(gg,kk,jj,:)] = calllib('St7API', 'St7GetBeamResultSinglePos', ...
                                     Options.St7.uID, ResultType(3), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(3), BeamDisp);
                                 HandleError(iErr);
                            end

                        end

                        % Get Node Results from support nodes
                        if jj == 1
                            nRes = zeros(6,1);
                            [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, ...
                                NodeResultType , SupportNode1, ResultCase, nRes);
                            HandleError(iErr);
                            NodeRes(jj,kk,:) = nRes;

                            nRes = zeros(6,1);
                            [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, ...
                                NodeResultType, SupportNode2, ResultCase, nRes);
                            HandleError(iErr);
                            NodeRes(jj+1,kk,:) = nRes;

                        else
                            nRes = zeros(6,1);
                            [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, ...
                                NodeResultType, SupportNode2, ResultCase, nRes);
                            HandleError(iErr);
                            NodeRes(jj+1,kk,:) = nRes;

                        end               
                    end
                end

                St7CloseResultFile(Options.St7.uID);

                DLResults(dd).BeamForce = BeamRes{1};
                DLResults(dd).BeamStress = BeamRes{2};
                DLResults(dd).BeamDisp = BeamRes{3};
                DLResults(dd).NodeRxn = NodeRes;
                DLResults(dd).beamNodes = beamNodes;
                DLResults(dd).beamNums = beamNums;
                
                % Move files from local temp directory to external
                if SaveExternal
%                     fprintf('\t \t \t Moving St7 Result Files to External...');
                    movefile(DeadLoadResultPath, [st7PathEXT mName '_' num2str(DeadLoadType) '_' SolverCase '.lsa']); % LSA
                    movefile([DeadLoadResultPath(1:end-4) '.lsl'],[st7PathEXT mName '_' num2str(DeadLoadType) '_' SolverCase '.lsl']); % LSL
%                     fprintf('Done.\n');
                end
            end

            save(rPath,'DLResults');
            fprintf('Done.\n');
            
            % Move files from local temp directory to external
            if SaveExternal
                fprintf('\t \t \t Moving Result Files to External...');
                movefile(rPath,rPathEXT);
                fprintf('Done.\n');
            end

        end

        CloseModelFile(Options.St7.uID);
        CloseAndUnload(Options.St7.uID);
        clear DLResults NodeRes BeamRes beamNodes beamNums BeamForce BeamStress...
            BeamDisp DeadLoadResultPath
        
    end
 
end
fprintf('Done. \n');  
close(h);
    