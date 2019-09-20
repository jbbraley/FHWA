function [settCase, oCase, barrCase, boundCase, rPath, st7Path, mPath, pPath, oPath, nPath, rPathEXT, st7PathEXT] = GetSolverCaseInfo_v3(SolverCase,mName,tempPath,externalPath,Response)

% DEFINE SOLVER CASES -----------------------------------------------------

% Fixed Rotation (integral Abutments
if length(SolverCase) > 2 && strcmp(SolverCase(4), 'F') % If Integral Abutments
    % Boundary Case
    boundCase = [bound ' ' stype ' - Fixed'];
else
    % Boundary Case
    boundCase = [bound ' ' stype];
end

% Barrier Stiffness
if strfind(SolverCase,'On')
    barrCase = 'Barriers On';
elseif strfind(SolverCase,'Off')
    barrCase = 'Barriers Off';
else
    barrCase = [];
end


% Response Case
if strfind(SolverCase,'Vert')
    settCase = 'Vertical Settlement';
    oCase = [];
    oCasePath = '\';
elseif strfind(SolverCase,'RPos')
    settCase = 'Rotational Settlement';
    oCase = 'Positive';
    oCasePath = '\Positive\';
elseif strfind(SolverCase,'RNeg')
    settCase = 'Rotational Settlement';
    oCase = 'Negative';
    oCasePath = '\Negative\';    
else
    settCase = [];
    oCase = [];
    oCasePath = '\';
end

   
% DEFINE PATHS & NAMES ----------------------------------------------------

% Model Path
mPath = [tempPath '\Model Files\'];

% Parameters Path
pPath = [tempPath '\Model Files\Parameters\' mName '_Para.mat'];

% Options Path
oPath = [tempPath '\Model Files\Options\' mName '_Options.mat'];

% Nodes Path
nPath = [tempPath '\Model Files\Nodes\' mName '_Node.mat'];


% Response Paths/Names
switch Response
    case 'S' % Settlement
        rPath = [tempPath '\Extracted Result Files\' ...
            settCase oCasePath boundCase '\' barrCase '\'...
            mName '_' SolverCase '.mat'];
        st7Path = [tempPath '\Model Files\St7 Result Files\' ...
            settCase oCasePath boundCase '\' barrCase '\'...
            mName '_' SolverCase '.lsa'];
        rPathEXT = [externalPath '\Extracted Result Files\' ...
            settCase oCasePath boundCase '\' barrCase '\'...
            mName '_' SolverCase '.mat'];
        st7PathEXT = [externalPath '\Model Files\St7 Result Files\' ...
            settCase oCasePath boundCase '\' barrCase '\'...
            mName '_' SolverCase '.lsa'];   
    case 'DL' % Dead Load
        rPath = [tempPath '\Extracted Result Files\Dead Load\'...
            boundCase '\' mName '_' SolverCase '_DLResults.mat'];
        st7Path = [tempPath '\Model Files\St7 Result Files\Dead Load\'...
            boundCase '\'];
        rPathEXT = [externalPath '\Extracted Result Files\Dead Load\'...
            boundCase '\' mName '_' SolverCase '_DLResults.mat'];
        st7PathEXT = [externalPath '\Model Files\St7 Result Files\Dead Load\'...
            boundCase '\'];
    case 'LL' % Live Load
        rPath = [tempPath '\Extracted Result Files\Live Load\'...
            boundCase '\' barrCase '\' mName '_' SolverCase '_LLResults.mat'];
        st7Path = [tempPath '\Model Files\St7 Result Files\Live Load\'...
            boundCase '\' barrCase '\'];
        rPathEXT = [externalPath '\Extracted Result Files\Live Load\'...
            boundCase '\' barrCase '\' mName '_' SolverCase '_LLResults.mat'];
        st7PathEXT = [externalPath '\Model Files\St7 Result Files\Live Load\'...
            boundCase '\' barrCase '\'];
    case 'Results'
        % Dead Load Results
        rPath{1} = [externalPath '\Extracted Result Files\Dead Load\'...
            boundCase '\' mName '_' SolverCase '_DLResults.mat'];
        % Live Load Results
        rPath{2} = [externalPath '\Extracted Result Files\Live Load\'...
            boundCase '\' barrCase '\' mName '_' SolverCase '_LLResults.mat'];
        % Settlement Results
        rPath{3} = [externalPath '\Extracted Result Files\' ...
            settCase oCasePath boundCase '\' barrCase '\'...
            mName '_' SolverCase '.mat'];
        % Final Study Results
        rPath{4} = [externalPath '\TS Results\'...
            settCase oCasePath boundCase '\' barrCase '\Results_'...
            SolverCase '.mat'];

        st7Path = [];
        rPathEXT = [];
        st7PathEXT = [];
end


end