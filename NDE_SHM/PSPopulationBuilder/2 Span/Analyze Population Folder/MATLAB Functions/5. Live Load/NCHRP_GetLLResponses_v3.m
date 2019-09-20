% NCHRP_GetLLResponses
% Run LiveLoadSolver() and pull results
clc
clear

fprintf('Running LL and DL Solvers...\n');
h = waitbar(0,'Initializing Load Solvers...');

global rtBeamStress rtBeamForce stBeamGlobal rtBeamDisp rtNodeReact

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SET-UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% USER INPUTS -------------------------------------------------------------
    
    % Directory
    tempPath = 'C:\Users\Nick\Documents\Projects\NCHRP - Phase II\Settlement Study\2-Span\Suite 1 Local';
    externalPath = 'G:\NCHRP\Settlement Study\2-Span\Suite 1';
    
    % Function Options
    RunLLS = 1;
    RunLLR = 1;
    Start = 1;
    SaveExternal = 1; % Option to store locally or move files to external
    
    % Solver Options
    LoadPathDivisions = 3;
    LoadPathLength = 0.1;
    CrawlSteps = 1;
    srBeamForce = 1; % Solve for Beam Reaction (bending)
    srNodeReaction = 1; % Solve for Node Reaction (shear)
    ShearRating = 1;
    srElementNodeForce = 1;
    spIncludeLinkReactions = 1; % Solver for Link Reactions
    
% ANALYSIS OPTIONS --------------------------------------------------------

    BoundCases = {'PA';'FA';'PP';'FP'}; % P = Pinned or Pier, F = Fixed, A = Abutment
%     BoundCases = {'PA'};
    BarrCases = {'On';'Off'};
%     BarrCases = {'Off'};
    
% GET LIST OF MODEL FILES -------------------------------------------------

dirData = dir([tempPath '\Model Files\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(8:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

% LOOP THROUGH MODELS -----------------------------------------------------

for aa = Start:length(fileList)
 
    fprintf(['\t Bridge ' num2str(aa) ':\n']);
    rNum = 0;
    
    % Model Name and paths
    mName = fileList{aa}(1:end-4);
    
    for bb = 1:length(BoundCases)
        
        for cc = 1:length(BarrCases)
            
            % Define Solver Case
            SolverCase = [BoundCases{bb} '_' BarrCases{cc}];
            fprintf(['\t \t' SolverCase '...']);
            [~, ~, barrCase, boundCase, rPath, st7Path, mPath, pPath, oPath, nPath, rPathEXT, st7PathEXT] =...
                GetSolverCaseInfo(SolverCase,mName,tempPath,externalPath,'LL');
    
            % Load in parameters, node, and options files
            load(pPath);
            load(nPath);
            load(oPath);

            % Load St7 API
            St7Start = 1;
            [~, Options] = InitializeRAMPS(Options, Parameters, St7Start);
            ScratchPath = 'C:\Temp'; 

            % Assign solver options
            Options.LoadPath.Divisions = LoadPathDivisions;
            Options.LoadPath.Length = LoadPathLength;
            Options.LoadPath.CrawlSteps = CrawlSteps;
            Options.Solver.LSA.Entity.srBeamForce = srBeamForce; % Solve for Beam Reaction (bending)
            Options.Solver.LSA.Entity.srNodeReaction = srNodeReaction; % Solve for Node Reaction (shear)
            Options.Solver.LSA.Entity.srElementNodeForce = srElementNodeForce;
            Options.LoadRating.ShearRating = ShearRating;
            Options.Solver.LSA.Defaults.spIncludeLinkReactions = spIncludeLinkReactions;

            % Load St7 Model
            St7OpenModelFile(Options.St7.uID, mPath, mName, ScratchPath);

            % Set solver options
            St7SetLSASolverOptions(Options.St7.uID, Parameters, Options); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LL SOLVER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Get freedom case number
            [LNumCases, LCaseName, FNumCases, FCaseName] = St7GetLoadAndFreedomCaseInfo(Options.St7.uID);
            [~, FCaseNum] = find(strcmp(FCaseName, boundCase));

            % Run LiveLoadSolver() with or without Barrier stiffness
            if RunLLS
                try
                    LLCase = 3;
                    mData = [];
                    rNum = rNum+1;
                    switch barrCase
                        case 'Barriers On'
                            propList = [1,2];
                            SetBeamStiffness(propList,'On',Parameters,Options.St7.uID)
                            waitbar(aa/length(fileList), h, ['Running LL Solver for Bridge ' num2str(aa)]);
                            NCHRP_LiveLoadSolver(Options.St7.uID, mName, st7Path, Node,...
                                Parameters, Options, Parameters.Rating.LRFD, LLCase, FCaseNum, rNum);
                        case 'Barriers Off'
                            propList = [1,2]; 
                            SetBeamStiffness(propList,'Off',Parameters,Options.St7.uID)
                            waitbar(aa/length(fileList), h, ['Running LL Solver for Bridge ' num2str(aa)]);
                            NCHRP_LiveLoadSolver(Options.St7.uID, mName, st7Path, Node,...
                                Parameters, Options, Parameters.Rating.LRFD, LLCase, FCaseNum, rNum);
                    end
                catch
                    close(h);
                    CloseModelFile(Options.St7.uID);
                    CloseAndUnload(Options.St7.uID);
                    return
                end
            end

            % Get Live Load Results
            if RunLLR
                try
                    waitbar(aa/length(fileList), h, ['Retrieving LL Results for Bridge ' num2str(aa)]);

                    LLCaseStart = 3;

                    % Open LL result file
                    LiveLoadResultPath = [st7Path mName '_LL.lsa'];
                    St7OpenResultFile(Options.St7.uID,LiveLoadResultPath);

                    % Get Number of load Cases
                    NumLoadCases = 0;
                    [iErr, NumLoadCases] = calllib('St7API', 'St7GetNumLoadCase', Options.St7.uID, NumLoadCases);
                    HandleError(iErr);

                    % Find number of truck and lane load cases
                    NumLaneDivisions = Options.LoadPath.Divisions;
                    NumLaneLoadCases = Parameters.Rating.LRFD.NumLane*Parameters.Spans*NumLaneDivisions;
                    NumTruckLoadCases = NumLoadCases - 2 - NumLaneLoadCases;
                    Trucks = (NumLoadCases-LLCaseStart+1)/NumLaneDivisions/Parameters.Rating.LRFD.NumLane-1*Parameters.Spans; % Truck loads per lane per lane position

                    % Preallocate for results storage
                    NumColumns = [6 18 6];
                    Spans = Parameters.Spans;
                    BeamElements = size(nonzeros(Node(1).ID(:,1,1)),1)-1;
                    NumGirder = Parameters.NumGirder;
                    NumLane = Parameters.Rating.LRFD.NumLane;
                    BeamForce = zeros(NumColumns(1),1);
                    BeamStress = zeros(NumColumns(2),1);
                    BeamDisp = zeros(NumColumns(3),1);
                    TruckLBeamRes{1} = zeros(BeamElements,NumGirder,Spans,NumLane,Trucks,NumLaneDivisions,6);
                    TruckLBeamRes{2} = zeros(BeamElements,NumGirder,Spans,NumLane,Trucks,NumLaneDivisions,18);
                    TruckLBeamRes{3} = zeros(BeamElements,NumGirder,Spans,NumLane,Trucks,NumLaneDivisions,6);
                    TruckNodeRes = zeros(Spans+1,NumGirder,NumLane, Trucks, NumLaneDivisions, 6);
                    LaneLBeamRes{1} = zeros(BeamElements,NumGirder,Spans,NumLane,Spans,NumLaneDivisions,6);
                    LaneLBeamRes{2} = zeros(BeamElements,NumGirder,Spans,NumLane,Spans,NumLaneDivisions,18);
                    LaneLBeamRes{3} = zeros(BeamElements,NumGirder,Spans,NumLane,Spans,NumLaneDivisions,6);
                    LaneNodeRes = zeros(Spans+1,NumGirder,NumLane, Spans, NumLaneDivisions, 6);
                    ResultType = [rtBeamForce rtBeamStress rtBeamDisp];
                    NodeResultType = rtNodeReact;
                    SubType = stBeamGlobal;

                    % Pull Results along entire length of girder
                    % gg = Beam Elements
                    % kk = Girders
                    % jj = Spans
                    % ii = Lane of interest
                    % hh = Result Cases 
                    % rr = Lane positions
                    % : = Global Resultants [FX MX FY MY FZ MZ]

                    % Loop through girders
                    for kk = 1:Parameters.NumGirder

                        % Loop though spans
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

                            % Pull resutls from all beam elements

                            % Loop through beam elements
                            for gg = 1:length(n)-1

                                beamNums(gg,kk,jj) = Node(jj).ElementCon(beamNodes(gg,kk,jj),1);

                                % Loop through lane divisions
                                for rr = 1:NumLaneDivisions

                                    % Loop through l ane position
                                    for ii = 1:Parameters.Rating.LRFD.NumLane

                                        % Loop through load cases
                                        for hh = 1:Trucks+Parameters.Spans

                                            % Pull results for truck load cases
                                            if hh <= Trucks

                                                % Get result case number
                                                ResultCase = Parameters.Rating.LRFD.NumLane*(Trucks)*(rr-1)+(ii-1)*Trucks+hh;

                                                if beamNums(gg,kk,jj) == 0
                                                    TruckLBeamRes{1}(gg,kk,jj,:) = 0;
                                                    TruckLBeamRes{2}(gg,kk,jj,:) = 0;
                                                    TruckLBeamRes{3}(gg,kk,jj,:) = 0;
                                                else
                                                    % Get Beam Results from every beam
                                                    % Beam Forces
                                                    [iErr, NumColumns(1), TruckLBeamRes{1}(gg,kk,jj,ii,hh,rr,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                                                        Options.St7.uID, ResultType(1), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(1), BeamForce);
                                                    HandleError(iErr);
                                                    % Beam Stresses
                                                    [iErr, NumColumns(2), TruckLBeamRes{2}(gg,kk,jj,ii,hh,rr,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                                                        Options.St7.uID, ResultType(2), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(2), BeamStress);
                                                    HandleError(iErr);
                                                    % Beam end displacements 
                                                    [iErr, NumColumns(3), TruckLBeamRes{3}(gg,kk,jj,ii,hh,rr,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                                                        Options.St7.uID, ResultType(3), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(3), BeamDisp);
                                                    HandleError(iErr);
                                                end

                                            else
                                            % Pull results for lane load cases 

                                                % Get result case number
                                                ResultCase = Parameters.Rating.LRFD.NumLane*Parameters.Spans*(rr-1) + ... % Lane load number
                                                    NumLaneDivisions*Parameters.Rating.LRFD.NumLane*Trucks + ... % Number of truck positions
                                                    (hh-Trucks-1)*Parameters.Rating.LRFD.NumLane + ii;

                                                if beamNums(gg,kk,jj) == 0
                                                    LaneLBeamRes{1}(gg,kk,jj,:) = 0;
                                                    LaneLBeamRes{2}(gg,kk,jj,:) = 0;
                                                    LaneLBeamRes{3}(gg,kk,jj,:) = 0;
                                                else
                                                    % Get Beam Results from every beam
                                                    % Beam Forces
                                                    [iErr, NumColumns(1), LaneLBeamRes{1}(gg,kk,jj,ii,hh-Trucks,rr,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                                                        Options.St7.uID, ResultType(1), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(1), BeamForce);
                                                    HandleError(iErr);
                                                    % Beam Stresses
                                                    [iErr, NumColumns(2), LaneLBeamRes{2}(gg,kk,jj,ii,hh-Trucks,rr,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                                                        Options.St7.uID, ResultType(2), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(2), BeamStress);
                                                    HandleError(iErr);
                                                    % Beam end displacements 
                                                    [iErr, NumColumns(3), LaneLBeamRes{3}(gg,kk,jj,ii,hh-Trucks,rr,:)] = calllib('St7API', 'St7GetBeamResultSinglePos',...
                                                        Options.St7.uID, ResultType(3), SubType, beamNums(gg,kk,jj), ResultCase, 0, NumColumns(3), BeamDisp);
                                                    HandleError(iErr);

                                                end    
                                            end
                                        end
                                    end
                                end
                            end

                            % Pull results from all support nodes

                            % Loop through lane divisions
                            for rr = 1:NumLaneDivisions

                                % Loop through l ane position
                                for ii = 1:Parameters.Rating.LRFD.NumLane

                                    % Loop through load cases
                                    for hh = 1:Trucks+Parameters.Spans

                                        % Pull results for truck load cases
                                        if hh <= Trucks

                                            % Get result case number
                                            ResultCase = Parameters.Rating.LRFD.NumLane*(Trucks)*(rr-1)+(ii-1)*Trucks+hh;

                                            if jj == 1

                                                nRes = zeros(6,1);
                                                [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, NodeResultType , SupportNode1, ResultCase, nRes);
                                                HandleError(iErr);
                                                TruckNodeRes(jj,kk,ii,hh,rr,:) = nRes;

                                                nRes = zeros(6,1);
                                                [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, NodeResultType, SupportNode2, ResultCase, nRes);
                                                HandleError(iErr);
                                                TruckNodeRes(jj+1,kk,ii,hh,rr,:) = nRes;

                                            else

                                                nRes = zeros(6,1);
                                                [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, NodeResultType, SupportNode2, ResultCase, nRes);
                                                HandleError(iErr);
                                                TruckNodeRes(jj+1,kk,ii,hh,rr,:) = nRes;
                                            end

                                        else
                                        % Pull results for lane load cases 

                                            % Get result case number
                                            ResultCase = Parameters.Rating.LRFD.NumLane*Parameters.Spans*(rr-1) + ... % Lane load number
                                                NumLaneDivisions*Parameters.Rating.LRFD.NumLane*Trucks + ... % Number of truck positions
                                                (hh-Trucks-1)*Parameters.Rating.LRFD.NumLane + ii;

                                            if jj == 1

                                                nRes = zeros(6,1);
                                                [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, rtNodeReact , SupportNode1, ResultCase, nRes);
                                                HandleError(iErr);
                                                LaneNodeRes(jj,kk,ii,hh-Trucks,rr,:) = nRes;

                                                nRes = zeros(6,1);
                                                [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, NodeResultType, SupportNode2, ResultCase, nRes);
                                                HandleError(iErr);
                                                LaneNodeRes(jj,kk,ii,hh-Trucks,rr,:) = nRes;

                                            else

                                                nRes = zeros(6,1);
                                                [iErr, nRes] = calllib('St7API', 'St7GetNodeResult', Options.St7.uID, NodeResultType, SupportNode2, ResultCase, nRes);
                                                HandleError(iErr);
                                                LaneNodeRes(jj+1,kk,ii,hh-Trucks,rr,:) = nRes;

                                            end
                                        end
                                    end
                                end
                            end  
                        end
                    end

                    St7CloseResultFile(Options.St7.uID);

                    LLResults.TruckLBeamForce = TruckLBeamRes{1};
                    LLResults.TruckLBeamStress = TruckLBeamRes{2};
                    LLResults.TruckLBeamDisp = TruckLBeamRes{3};
                    LLResults.TruckLNodeRxn = TruckNodeRes;
                    LLResults.LaneLBeamForce = LaneLBeamRes{1};
                    LLResults.LaneLBeamStress = LaneLBeamRes{2};
                    LLResults.LaneLBeamDisp = LaneLBeamRes{3};
                    LLResults.LaneLNodeRxn = LaneNodeRes;
                    LLResults.beamNodes = beamNodes;
                    LLResults.beamNums = beamNums;

                catch
                    close(h);
                    HandleError(iErr);
                    CloseModelFile(Options.St7.uID);
                    CloseAndUnload(Options.St7.uID);
                    return
                end


                CloseModelFile(Options.St7.uID);
                CloseAndUnload(Options.St7.uID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% COMBINE LLR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Total combined loads (multi-pres, lane comb, etc)
                LLResults = CombineLL_v2(LLResults,Parameters);
                
                fprintf('Done.\n');
                
                save(rPath,'LLResults');
                
                 % Move files from local temp directory to external
                if SaveExternal
                    fprintf('\t \t \t Moving Files to External...');
                    movefile(rPath,rPathEXT);
                    movefile(LiveLoadResultPath, [st7PathEXT mName '_' SolverCase '_LL' '.lsa']); % LSA
                    movefile([LiveLoadResultPath(1:end-4) '.lsl'],[st7PathEXT mName '_' SolverCase '_LL' '.lsl']); % LSL
                    fprintf('Done.\n');
                end

            end
              
            clear LiveLoadResultPath NumLaneDivisions NumLaneLoadCases NumTruckLoadCases...
                    Trucks TruckLBeamRes TruckNodeRes LaneLBeamRes LaneNodeRes BeamForce...
                    BeamStress BeamDisp beamNodes beamNums ResultCase LLResults
        end
    end
end
fprintf('Done. \n');  
close(h);
    