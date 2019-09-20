% NCHRP_GetSettlementResults_v4
clc
clear

fprintf('Retrieving Settlement Responses...\n');
h = waitbar(0,'Initializing...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% USER INPUT --------------------------------------------------------------

    % Suite No.
    suite = 1;
    
    % Directory
    suitePath = ['C:\Users\Nick\Documents\Projects\NCHRP - Phase II\Steel\3-Span\Suite ' num2str(suite)];
    savePath = ['E:\NCHRP Phase II\Steel\3-Span\Suite ' num2str(suite)];

    Start = 1;
    uID = 1;
    
% ANALYSIS OPTIONS --------------------------------------------------------

BoundCases = {'A1';'P1';'P2';'A2';'A1-F';'P1-F';'P2-F';'A2-F'};
BarrCases = {'Off'};
SettCases = {'Vert';'RPos';'RNeg'};

% RETRIEVE ALL MODEL FILES ------------------------------------------------

dirData = dir([suitePath '\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(8:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%% RUN SETTLEMENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load St7 API
InitializeSt7(0);

% Create temp directory (ScratchPath)
ScratchPath = ['C:\Temp\Settlements ' num2str(suite) '\'];
mkdir(ScratchPath);

for ii = Start:length(fileList)
    
    fprintf(['\t Bridge ' num2str(ii) ': \n'])
    
    % Model Name
    mName = fileList{ii}(1:end-4);

    % Loop through boundary conditions
    for aa = 1:length(BoundCases)

        % Loop through barrier stiffness conditions
        for bb = 1:length(BarrCases)

            % Loop through settlement cases
            for cc = 1:length(SettCases)

                % Define Solver Case
                SolverCaseName = [BoundCases{aa} '_' BarrCases{bb} '_' SettCases{cc}];
                [mPath,pPath, oPath, nPath, rPath] = ...
                NCHRP_GetModelAndResultPath(BoundCases{aa},BarrCases{bb},SettCases{cc},mName,suitePath,savePath,'S');
                SettCaseName = [BoundCases{aa} '_' SettCases{cc}];

                % Run Solver
                fprintf(['\t \t' SolverCaseName '...']);
                waitbar(ii/length(fileList),h,['Running Settlement Solver for Bridge ' num2str(ii)]);
                SResults = NCHRP_SettlementSolver_v2(SettCaseName,BarrCases{bb},mPath,mName, pPath, oPath, nPath, ScratchPath);                    

                % Save Settlement Results
                save(rPath,'SResults');
                clear SResults
                fprintf('Done. \n');
                
                
            end
        end
    end        
end

% Remove Scratchpath
rmdir(ScratchPath);

% Close and unload
CloseAndUnload(uID);
close(h);
fprintf('Done.\n');

