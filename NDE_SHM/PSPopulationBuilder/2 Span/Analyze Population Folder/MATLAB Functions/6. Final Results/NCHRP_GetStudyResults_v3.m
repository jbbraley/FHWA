% NCHRP_GetStudyResults
clc
clear

h = waitbar(0,'Initializing...');
fprintf('Retrieving final resutls from sample population...\n');

% USER INPUTS -------------------------------------------------------------
    
    % Directory
    tempPath = 'C:\Users\Nick\Documents\Projects\NCHRP - Phase II\Settlement Study\2-Span\Suite 1 Local';
    externalPath = 'G:\NCHRP\Settlement Study\2-Span\Suite 1';
    
    Start = 1;
            
% Results Options ---------------------------------------------------------

%     BoundCases = {'PA';'FA';'PP';'FP'}; % P = Pinned or Pier, F = Fixed, A = Abutment
    BoundCases = {'PA';'PP'};
    BarrCases = {'On'};
    SettCases = {'Vertical'; 'Rotational'};
    oCases = {'Pos';'Neg'};                                             

% GET LIST OF MODEL FILES -------------------------------------------------

dirData = dir([tempPath '\Model Files\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(8:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

% LOOP THROUGH MODEL FILES ------------------------------------------------

for ii = Start:63%length(fileList)
    
    waitbar(ii/length(fileList),h,['Retrieving final resutls for Bridge ' num2str(ii) '...']);
    fprintf(['\t Bridge ' num2str(ii) ': \n'])
    
    % Model Name
    mName = fileList{ii}(1:end-4);
    
    % Load Parameters
    load([tempPath '\Model Files\Parameters\' mName '_Para.mat']);
    
    % Loop through boundary conditions
    for aa = 1:length(BoundCases)
        
%% DEAD LOAD RESPONSES ----------------------------------------------------

        % Get SolverCase
        SolverCase = BoundCases{aa};
        [~, ~, ~, ~, rPath, ~, ~, ~, ~, ~, ~, ~] = ...
            GetSolverCaseInfo(SolverCase,mName,tempPath,externalPath,'Results');
        
        % Load DLResults
        load(rPath{1});

        % Get DL stresses and moments
        [DLResults] = NCHRP_CombineDLR(DLResults,Parameters);
        save(rPath{1},'DLResults');

        % Loop through barrier stiffness conditions
        for bb = 1:length(BarrCases)

%% LIVE LOAD RESPONSES ----------------------------------------------------

            % Get SolverCase
            SolverCase = [BoundCases{aa} '_' BarrCases{bb}];
            [~, ~, ~, ~, rPath, ~, ~, ~, ~, ~, ~, ~] = ...
                GetSolverCaseInfo(SolverCase,mName,tempPath,externalPath,'Results');
            
            % Load LLResults
            load(rPath{2});
            
            % Get LL stresses and moments
            [LLResults] = NCHRP_CombineLLR(LLResults,Parameters);
            save(rPath{2},'LLResults');

            % Loop through settlement cases
            for cc = 1:length(SettCases)

%% SETTLEMENT RESPONSES ---------------------------------------------------

                if strcmp(SettCases{cc},'Vertical')

                    % Get SolverCase
                    SolverCase = [BoundCases{aa} '_' BarrCases{bb} '_' SettCases{cc}];
                    [~, ~, ~, ~, rPath, ~, ~, ~, ~, ~, ~, ~] =...
                        GetSolverCaseInfo(SolverCase,mName,tempPath,externalPath,'Results');
                    fprintf(['\t \t' SolverCase '...']);
                    
                    % Load SResults
                    load(rPath{3});
                    
                    % Get Sett stresses and moments
                    [SResults] = NCHRP_CombineSR(SResults,Parameters);
                    save(rPath{3},'SResults');
                    
                    % Get Tolerable Settlement Factors
                    [TS] = NCHRP_GetTSFactors_v3(Parameters, DLResults,LLResults,SResults);

                    % Create/load final results structure
                    if exist(rPath{4},'file') == 2
                        load(rPath{4})
                    else
                        [Results] = NCHRP_CreateFinalResultsStructure;
                    end

                    % Save Results
                    Results(ii).ModelName = mName;
                    Results(ii).SpanLength = max(Parameters.Length);
                    Results(ii).GirderSpacing = Parameters.GirderSpacing;
                    Results(ii).Skew = Parameters.SkewNear;
                    Results(ii).SpanDepth = Parameters.Design.MaxSpantoDepth;
                    Results(ii).Width = Parameters.TotalWidth;
                    Results(ii).minTS_M_St1_pier = min(min(TS.M_St1_pier));
                    Results(ii).minTS_M_St1_pos1 = min(min(TS.M_St1_pos1));
                    Results(ii).minTS_M_St1_pos2 = min(min(TS.M_St1_pos2));
                    Results(ii).minTS_M_Sv2_pier = min(min(TS.M_Sv2_pier));
                    Results(ii).minTS_M_Sv2_pos1 = min(min(TS.M_Sv2_pos1));
                    Results(ii).minTS_M_Sv2_pos2 = min(min(TS.M_Sv2_pos2));
                    Results(ii).minTS_M_SvA_pier = min(min(TS.M_SvA_pier));
                    Results(ii).minTS_M_SvA_pos1 = min(min(TS.M_SvA_pos1));
                    Results(ii).minTS_M_SvA_pos2 = min(min(TS.M_SvA_pos2));
                    Results(ii).minTS_V_St1_pier = min(min(TS.V_St1_pier));
                    Results(ii).minTS_V_St1_abt1 = min(min(TS.V_St1_abt1));
                    Results(ii).minTS_V_St1_abt2 = min(min(TS.V_St1_abt2));
                    Results(ii).TS_M_St1_pier = TS.M_St1_pier;
                    Results(ii).TS_M_St1_pos1 = TS.M_St1_pos1;
                    Results(ii).TS_M_St1_pos2 = TS.M_St1_pos2;
                    Results(ii).TS_M_Sv2_pier = TS.M_Sv2_pier;
                    Results(ii).TS_M_Sv2_pos1 = TS.M_Sv2_pos1;
                    Results(ii).TS_M_Sv2_pos2 = TS.M_Sv2_pos2;
                    Results(ii).TS_M_SvA_pier = TS.M_SvA_pier;
                    Results(ii).TS_M_SvA_pos1 = TS.M_SvA_pos1;
                    Results(ii).TS_M_SvA_pos2 = TS.M_SvA_pos2;
                    Results(ii).TS_V_St1_pier = TS.V_St1_pier;
                    Results(ii).TS_V_St1_abt1 = TS.V_St1_abt1;
                    Results(ii).TS_V_St1_abt2 = TS.V_St1_abt2;
                    Results(ii).DL1_StressT = DLResults(1).DL1s_t;
                    Results(ii).DL2_StressT = DLResults(2).DL2s_t;
                    Results(ii).LL_StressT = LLResults.LLs_t;
                    Results(ii).Sett_StressT = SResults.Setts_t;
                    Results(ii).DL1_StressB = DLResults(1).DL1s_b;                            
                    Results(ii).DL2_StressB = DLResults(2).DL2s_b;
                    Results(ii).LL_StressB = LLResults.LLs_b;
                    Results(ii).Sett_StressB = SResults.Setts_b;
                    Results(ii).DL1_StressD = DLResults(1).DL1s_d;
                    Results(ii).DL2_StressD = DLResults(2).DL2s_d;
                    Results(ii).LL_StressD = LLResults.LLs_d;
                    Results(ii).Sett_StressD = SResults.Setts_d;
                    Results(ii).DL1_Rxns = DLResults(1).DL1_Rxns;
                    Results(ii).DL2_Rxns = DLResults(2).DL2_Rxns;
                    Results(ii).LL_Rxns = LLResults.LL_Rxns;
                    Results(ii).Sett_Rxns = SResults.Sett_Rxns;

                    fprintf('Done.\n');

                    % Save SettResults
                    fprintf('\t \t \t Saving final results...');
                    save(rPath{4},'Results');
                    fprintf('Done.\n');
                    clear SettResults SResults SettFactM_St1 SettFactM_Sv2 SettFactM_SvA SettFactV_St1 St1_Cap

                else

                    % Loop through rotational settlement orientation 
                    for dd = 1:length(oCases)

                        % Get SolverCase
                        SolverCase = [BoundCases{aa} '_' BarrCases{bb} '_' SettCases{cc} '_' oCases{dd}];
                        [settCase, oCase, barrCase, boundCase, rPath, ~, ~, ~, ~, ~, ~, ~] =...
                            GetSolverCaseInfo(SolverCase,mName,tempPath,externalPath,'Results');
                        fprintf(['\t \t' SolverCase '...']);
                        
                        % Load SResults
                        load(rPath{3});
                        
                        % Get Sett stresses and moments
                        [SResults] = NCHRP_CombineSR(SResults,Parameters);
                        
                        % Get Tolerable Settlement Factors
                        [TS] = NCHRP_GetTSFactors_v3(Parameters, DLResults,LLResults,SResults);
                                                
                        % Create/load final results structure
                        if exist(rPath{4},'file') == 2
                            load(rPath{4})
                        else
                            [Results] = NCHRP_CreateFinalResultsStructure;
                        end
                       
                        % Save Results
                        Results(ii).ModelName = mName;
                        Results(ii).SpanLength = max(Parameters.Length);
                        Results(ii).GirderSpacing = Parameters.GirderSpacing;
                        Results(ii).Skew = Parameters.SkewNear;
                        Results(ii).SpanDepth = Parameters.Design.MaxSpantoDepth;
                        Results(ii).Width = Parameters.TotalWidth;
                        Results(ii).minTS_M_St1_pier = min(min(TS.M_St1_pier));
                        Results(ii).minTS_M_St1_pos1 = min(min(TS.M_St1_pos1));
                        Results(ii).minTS_M_St1_pos2 = min(min(TS.M_St1_pos2));
                        Results(ii).minTS_M_Sv2_pier = min(min(TS.M_Sv2_pier));
                        Results(ii).minTS_M_Sv2_pos1 = min(min(TS.M_Sv2_pos1));
                        Results(ii).minTS_M_Sv2_pos2 = min(min(TS.M_Sv2_pos2));
                        Results(ii).minTS_M_SvA_pier = min(min(TS.M_SvA_pier));
                        Results(ii).minTS_M_SvA_pos1 = min(min(TS.M_SvA_pos1));
                        Results(ii).minTS_M_SvA_pos2 = min(min(TS.M_SvA_pos2));
                        Results(ii).minTS_V_St1_pier = min(min(TS.V_St1_pier));
                        Results(ii).minTS_V_St1_abt1 = min(min(TS.V_St1_abt1));
                        Results(ii).minTS_V_St1_abt2 = min(min(TS.V_St1_abt2));
                        Results(ii).TS_M_St1_pier = TS.M_St1_pier;
                        Results(ii).TS_M_St1_pos1 = TS.M_St1_pos1;
                        Results(ii).TS_M_St1_pos2 = TS.M_St1_pos2;
                        Results(ii).TS_M_Sv2_pier = TS.M_Sv2_pier;
                        Results(ii).TS_M_Sv2_pos1 = TS.M_Sv2_pos1;
                        Results(ii).TS_M_Sv2_pos2 = TS.M_Sv2_pos2;
                        Results(ii).TS_M_SvA_pier = TS.M_SvA_pier;
                        Results(ii).TS_M_SvA_pos1 = TS.M_SvA_pos1;
                        Results(ii).TS_M_SvA_pos2 = TS.M_SvA_pos2;
                        Results(ii).TS_V_St1_pier = TS.V_St1_pier;
                        Results(ii).TS_V_St1_abt1 = TS.V_St1_abt1;
                        Results(ii).TS_V_St1_abt2 = TS.V_St1_abt2;
                        Results(ii).DL1_StressT = DLResults(1).DL1s_t;
                        Results(ii).DL2_StressT = DLResults(2).DL2s_t;
                        Results(ii).LL_StressT = LLResults.LLs_t;
                        Results(ii).Sett_StressT = SResults.Setts_t;
                        Results(ii).DL1_StressB = DLResults(1).DL1s_b;                            
                        Results(ii).DL2_StressB = DLResults(2).DL2s_b;
                        Results(ii).LL_StressB = LLResults.LLs_b;
                        Results(ii).Sett_StressB = SResults.Setts_b;
                        Results(ii).DL1_StressD = DLResults(1).DL1s_d;
                        Results(ii).DL2_StressD = DLResults(2).DL2s_d;
                        Results(ii).LL_StressD = LLResults.LLs_d;
                        Results(ii).Sett_StressD = SResults.Setts_d;
                        Results(ii).DL1_Rxns = DLResults(1).DL1_Rxns;
                        Results(ii).DL2_Rxns = DLResults(2).DL2_Rxns;
                        Results(ii).LL_Rxns = LLResults.LL_Rxns;
                        Results(ii).Sett_Rxns = SResults.Sett_Rxns;

                        fprintf('Done.\n');

                        % Save SettResults
                        fprintf('\t \t \t Saving final results...');
                        save(rPath{4},'Results');
                        fprintf('Done.\n');
                        clear SettResults SResults SettFactM_St1 SettFactM_Sv2 SettFactM_SvA SettFactV_St1 St1_Cap

                    end
                end
            end
        end
    end
    
    
    fprintf('Done. \n');

    
end

close(h);


