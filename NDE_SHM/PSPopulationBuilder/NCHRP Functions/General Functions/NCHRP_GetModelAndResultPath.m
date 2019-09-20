function [mPath, pPath, oPath, nPath, rPath] = NCHRP_GetModelAndResultPath(BoundCase,BarrCase,SettCase,mName,suitePath,savePath,Response)

% Barrier Case
if strcmp(BarrCase,'On')
    barrCase = 'Barriers On';
elseif strcmp(BarrCase,'Off')
    barrCase = 'Barriers Off';
end

% Settlement Case
if strfind(SettCase,'Vert')
    settCase = 'Vertical Settlement';
    oCase = [];
    oCasePath = '\';
elseif strfind(SettCase,'RPos')
    settCase = 'Rotational Settlement';
    oCase = 'Positive';
    oCasePath = '\Positive\';
elseif strfind(SettCase,'RNeg')
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
mPath = [suitePath '\'];

% Parameters Path
pPath = [suitePath '\Parameters\' mName '_Para.mat'];

% Options Path
oPath = [suitePath '\Options\' mName '_Options.mat'];

% Nodes Path
nPath = [suitePath '\Nodes\' mName '_Node.mat'];


% Response Paths/Names
switch Response
    
    case 'DL' % Dead Load
        rPath = [savePath '\Extracted Result Files\Dead Load\'...
            BoundCase '\' mName '_' BoundCase '_DLResults.mat'];
        
    case 'S' % Settlement
        rPath = [savePath '\Extracted Result Files\' ...
            settCase '\' BoundCase '\' barrCase oCasePath...
            mName '_' BoundCase '_' BarrCase '_' SettCase...
            '_SResults.mat'];

    case 'LL' % Live Load
        rPath = [savePath '\Extracted Result Files\Live Load\'...
            BoundCase '\' barrCase '\' mName '_' BoundCase '_'...
            BarrCase '_LLResults.mat'];
        
    case 'R' % Settlement
        rPath = [savePath '\TS Results\' ...
            settCase '\' BoundCase '\' barrCase oCasePath...
            'Results_' BoundCase '_' BarrCase '_' SettCase '.mat'];

end


end