% NCHRP_GetLLCombinations
clc
clear

fprintf('Processing Live Load Combiantions...\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SET-UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% USER INPUTS -------------------------------------------------------------
    
% Suite No.
suite = 1;

% Directory
suitePath = ['C:\Users\Nick\Documents\Projects\NCHRP - Phase II\Steel\3-Span\Suite ' num2str(suite)];
savePath = ['E:\NCHRP Phase II\Steel\3-Span\Suite ' num2str(suite)];

% ANALYSIS OPTIONS --------------------------------------------------------

BoundCases = {'A1';'A1-F'}; %{'A1';'P1';'P2';'A2';'A1-F';'P1-F';'P2-F';'A2-F'};
BarrCases = {'Off'};

% RETRIEVE ALL MODEL FILES ------------------------------------------------

dirData = dir([suitePath '\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(8:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

for ii = 1:30%length(fileList)
    
    fprintf(['Bridge ' num2str(ii) ': \n'])
    
    % Model Name
    mName = fileList{ii}(1:end-4);
    
    % Load Parameters
    load([suitePath '\Parameters\' mName '_Para.mat']);
    
    for aa = 1:length(BoundCases)
        
        for bb = 1:length(BarrCases)
            
            fprintf(['\t' BoundCases{aa} '_' BarrCases{bb} '...']);
            
            % LL Result Path
            [~,~, ~, ~, rPath] = ...
                        NCHRP_GetModelAndResultPath(BoundCases{aa},BarrCases{bb},[],mName,suitePath,savePath,'LL');
                    
            % Load LL Results
            load(rPath)
            
            % Remove un-used fields to reduce file size
            LLResults = rmfield(LLResults,{'TruckLBeamStress','LaneLBeamStress'});
            
            % Combine LL Results
            LLResults = CombineLL_v2(LLResults,Parameters);
            
            % Save LL Results
            save(rPath, 'LLResults','-v7.3');
            
            fprintf('Done. \n');
            
        end
    end
end

fprintf('DONE. \n');    