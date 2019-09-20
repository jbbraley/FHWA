clc
clear


modelPath = 'D:\Files\Documents\Projects\FHWA WV\Models\PierIncluded\Rating\THMPR\Shear&Flexure_FullLength\CenterSpan\Model Files';
resultPath = 'D:\Files\Documents\Projects\FHWA WV\Models\PierIncluded\Rating\THMPR\Shear&Flexure_FullLength\CenterSpan\Extracted Result Files';

dirData = dir([modelPath '\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(17:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

for ii = 1%:100
   
    % Model Name
    mName = fileList{1}(1:end-4);
    
    % Load Parameters
    load([modelPath '\Parameters\' mName '_Para.mat'])
    
    % Load Dead Load Results
    load([resultPath '\Dead Load\A1\' mName '_A1_DLResults.mat']);
    
    % Load Live Load Results
    load([resultPath '\Live Load\A1\Barriers On\' mName '_A1_On_LLResults.mat']);
    
    DLResults = NCHRP_ProcessDLR_v2(DLResults, Parameters);
    LLResults = NCHRP_ProcessLLR_v2(LLResults, Parameters);
    
    save([resultPath '\Dead Load\A1\' mName '_A1_DLResults.mat'],'DLResults');
    save([resultPath '\Live Load\A1\Barriers On\' mName '_A1_On_LLResults.mat'],'LLResults');
end
 fprintf('Done. \n');  