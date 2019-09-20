% NCHRP_GetSettlementResults
clc
clear

fprintf('Retrieving Settlement Responses...\n');
h = waitbar(0,'Initializing...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% USER INPUT --------------------------------------------------------------

    % Directory
    tempPath = 'C:\Users\Nick\Documents\Projects\NCHRP - Phase II\Settlement Study\2-Span\Suite 1 Local';
    externalPath = 'G:\NCHRP\Settlement Study\2-Span\Suite 1';
 
    Start = 1;
    SaveExternal = 1; % Option to store locally or move files to external

% ANALYSIS OPTIONS --------------------------------------------------------

%     BoundCases = {'PA';'FA';'PP';'FP'}; % P = Pinned or Pier, F = Fixed, A = Abutment
    BoundCases = {'PA';'PP'};
%     BarrCases = {'On';'Off'};
    BarrCases = {'On'};
    SettCases = {'Vertical'; 'Rotational'};
%     SettCases = {'Vertical'};
    oCases = {'Pos';'Neg'};

% RETRIEVE ALL MODEL FILES ------------------------------------------------

dirData = dir([tempPath '\Model Files\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(8:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%% RUN SETTLEMENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = Start:length(fileList)
    
%     if ii == 20 || ii == 40 || ii == 60 || ii == 80
%         pause
%     end
    
    fprintf(['\t Bridge ' num2str(ii) ': \n'])
    
    % Model Name
    mName = fileList{ii}(1:end-4);

    % Loop through boundary conditions
    for aa = 1:length(BoundCases)

        % Loop through barrier stiffness conditions
        for bb = 1:length(BarrCases)

            % Loop through settlement cases
            for cc = 1:length(SettCases)

                if strcmp(SettCases{cc},'Vertical')

                    % Define Solver Case
                    SolverCase = [BoundCases{aa} '_' BarrCases{bb} '_' SettCases{cc}];
                    [settCase, oCase, barrCase, boundCase, rPath, st7Path, mPath, pPath, oPath, nPath, rPathEXT, st7PathEXT] =...
                        GetSolverCaseInfo(SolverCase,mName,tempPath,externalPath,'S');
                    SettCaseName = [settCase ' - ' boundCase];

                    % Run Solver
                    fprintf(['\t \t' SolverCase '...']);
                    waitbar(ii/length(fileList),h,['Running Settlement Solver for Bridge ' num2str(ii)]);
                    SResults = SettlementSolver(SettCaseName,barrCase,mPath, pPath, oPath, nPath, st7Path);                    
                    
                    % Save Settlement Results
                    save(rPath,'SResults');
                    clear SResults
                    fprintf('Done. \n');
                    
                    % Move files from local temp directory to external
                    if SaveExternal
                        fprintf('\t \t \t Moving Files to External...');
                        movefile(rPath,rPathEXT);
                        movefile([st7Path(1:end-4) '.lsa'],[st7PathEXT(1:end-4) '.lsa']); % LSA
                        movefile([st7Path(1:end-4) '.lsl'],[st7PathEXT(1:end-4) '.lsl']); % LSL
                        fprintf('Done.\n');
                    end
                    
                else 
                    
                    % Loop through rotational settlement orientation 
                    for dd = 1:length(oCases)

                        % Define Solver Case
                        SolverCase = [BoundCases{aa} '_' BarrCases{bb} '_' SettCases{cc} '_' oCases{dd}];
                        [settCase, oCase, barrCase, boundCase, rPath, st7Path, mPath, pPath, oPath, nPath, rPathEXT, st7PathEXT] =...
                            GetSolverCaseInfo(SolverCase,mName,tempPath,externalPath,'S');
                        SettCaseName = [settCase ' ' oCase ' - ' boundCase];

                        % Run Solver
                        fprintf(['\t \t' SolverCase '...']);
                        waitbar(ii/length(fileList),h,['Running Settlement Solver for Bridge ' num2str(ii)]);
                        SResults = SettlementSolver(SettCaseName,barrCase,mPath, pPath, oPath, nPath, st7Path);                        
                        
                        % Save Settlement Results
                        save(rPath,'SResults');
                        clear SResults
                        fprintf('Done. \n');
                        
                        % Move files from local temp directory to external
                        if SaveExternal
                            fprintf('\t \t \t Moving Files to External...');
                            movefile(rPath,rPathEXT);
                            movefile([st7Path(1:end-4) '.lsa'],[st7PathEXT(1:end-4) '.lsa']); % LSA
                            movefile([st7Path(1:end-4) '.lsl'],[st7PathEXT(1:end-4) '.lsl']); % LSL
                            fprintf('Done.\n');
                        end
                    end
                end
            end
        end
    end    
end

close(h);
fprintf('Done.\n');

