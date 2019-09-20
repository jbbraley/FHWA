function RAMPS(Parameters, Options)
%% Load Bridge Population Data and Get Bridge Geometry
tempcd = pwd;
cd('../');
[fid, ~] = fopen([pwd '\Tables\State Data\' Options.NBI.State '\NBIformated.mat']);

fprintf('Loading/Checking NBI Data...\n');
if fid==-1
    % Load in population data from NBI ASCII File
    % Filter population
    NBI_data = LoadNBIData(Options);
    
    % Gets bridge geometry data from NBI
    NBI = GetNBIData(NBI_data, []);                
    NBI = TranslateNBIData(NBI);
    
    save([pwd '\Tables\State Data\' Options.NBI.State '\NBIraw.mat'],'NBI_data','-v7');
    save([pwd '\Tables\State Data\' Options.NBI.State '\NBIformated.mat'],'NBI','-v7');
else
    fclose(fid);
    load([pwd '\Tables\State Data\' Options.NBI.State '\NBIformated.mat']);
end

cd(tempcd);
%% Bridge Design Heuristics
tic
if Options.Design == 1
    fprintf('Loading/Checking Design Parameters...\n');
    fprintf('Loading/Checking Line Girder Rating Factors...\n');
    
    dir = isdir([ModelPath '\Data\Parameters']);                                                                                                                          
    if dir == 0                                                                                                                                                   
        mkdir(ModelPath , 'Data\Parameters');                                                                                                                            
    end
    
    for i=1:NumModels
        clc
        fprintf('Designing Bridge Model %i of %i...\n',i, NumModels);
        for j=1:Options.StructVar.NumVersions
            
            for k=1:size(Options.StructVar.CodeOp)
                % Model Name
                ModelName = [Options.NBI.State '_' strtrim(NBI(i).StructureNumber) '_' num2str(j)];
                
                % Check for File
                if exist([ModelPath '\Data\Parameters\' ModelName '.mat'],'file') == 0
                    fprintf('Designing Bridge Variation %i of %i...\n',j,Options.StructVar.NumVersions);
                    
                    Version = Options.StructVar.Version(j);
                    DesignCode = Options.StructVar.CodeOp{k};
                    
                    Parameters = GetStructureConfig(NBI(i), [], Version, Options);
                    
                    if ~isempty(Options.StructVar.Version(j).CoverPlateLength)
                        Parameters.Beam.CoverPlate.Length = ones(1,length(Parameters.Length))*Options.StructVar.Version(j).CoverPlateLength;
                    end
                    
                    Parameters = AASHTODesign(Parameters, Version, Options, DesignCode);
                    
                    save([ModelPath '\Data\Parameters\' ModelName '.mat'], 'Parameters', '-v7');
                end
            end
        end
    end
end
toc

%% Model Gengeration and Analysis
% Create FEM model and run analysis
tic
n=0;
if Options.BuildModels==1
    
    dir = isdir([ModelPath '\Data\Nodes']);
    if dir == 0
        mkdir(ModelPath , 'Data\Nodes');
    end
   
    fprintf('Loading/Checking Models...\n');
    
    for i=1:NumModels
        fprintf('Creating Model %u out of %u...\n',i,NumModels);
        
        for j=1:Options.StructVar.NumVersions
            n=n+1;
            ModelName = [Options.NBI.State '_' strtrim(NBI(i).StructureNumber) '_' num2str(j)];
            load([pwd '\Data\Parameters\'  ModelName '.mat']);
            
            if strcmp(Parameters.Design.Code,'ASD') && ~strcmp(Parameters.Beam.Type, 'None')
               if exist([ModelPath '\Models\' ModelName '.st7'],'file')==0
                    
                    fprintf('Creating Version %u out of %u...',j,Options.StructVar.NumVersions);
                    
                    uID=1;
                    
                    if exist([ModelPath '\Data\Nodes\' ModelName '.mat'],'file') == 2
                        Nodes = load([ModelPath '\Data\Nodes\' ModelName '.mat'],'Nodes');
                    else
                        Nodes.Node = 0;
                    end
                    
                    %%
                    Parameters.LengthOption = 'Girder';                   
                    
                    
                    % Number of diaphragms
                    Parameters.NumDia = ceil(Parameters.Length/300)-1;
                    if Parameters.SkewNear < 20
                        Parameters.Dia.Config = 'Parallel';
                    else
                        Parameters.Dia.Config = 'Normal';
                    end
                    save([ModelPath '\Data\Parameters\' ModelName '.mat'], 'Parameters', '-v7');
                    %%
                    
                    NewModel(uID, ModelPath, ModelName, ScratchPath, Units);
    
                    [Nodes.Node] = ModelGeneration(uID, Options, Parameters);
        
                    iErr = calllib('St7API', 'St7SaveFile', uID);
                    HandleError(iErr);
                    calllib('St7API','St7CloseFile',uID);
    
                    save([ModelPath '\Data\Nodes\' ModelName '.mat'],'Nodes','-v7');
                    clear('Nodes');
    
                end

                fprintf('Done\n');
            end
        end  
    end
end
toc

%% Load Rating
if Options.Analysis.LoadRating == 1
    for i=1:NumModels
        fprintf('Getting Results For Model %u out of %u...\n',i,NumModels);
        
        for j=1:Options.StructVar.NumVersions
            fprintf('Version %u out of %u...\n',j,Options.StructVar.NumVersions);
            
            uID=1;
            ModelName = [Options.NBI.State '_' strtrim(NBI(i).StructureNumber) '_' num2str(j)];
            
            
            ModelPathName = [ModelPath '\Models\' ModelName '.st7'];
            NodePathName = [ModelPath '\Data\Nodes\' ModelName '.mat'];
            
            if exist([ModelPath '\Models\' ModelName '.st7'],'file') == 2 
                iErr = calllib('St7API', 'St7OpenFile', uID, ModelPathName, ScratchPath);
                HandleError(iErr);                
                
                if exist([ModelPath '\Models\' ModelName '_1_1.lsa'],'file') == 0 || exist([ModelPath '\Data\Results\' ModelName '_DLR.mat'],'file') == 0 ||...
                        exist([ModelPath '\Models\' ModelName '_1_LL.lsa'],'file') == 0 || exist([ModelPath '\Data\Results\' ModelName '_LLR.mat'],'file') == 0
                    Nodes = open(NodePathName);
                    NodeID = Nodes.Node.ID;
                    Node = Nodes.Node;
                    
                    load([pwd '\Data\Parameters\'  ModelName '.mat']);
                end
                % Call Dead Load Solver
                if exist([ModelPath '\Models\' ModelName '_1.lsa'],'file') == 0
                    DeadLoadSolver(uID, ModelName, ModelPath, Node, Parameters);
                end
                
                % Get Dead Load Results
                if exist([ModelPath '\Models\' ModelName '_1.lsa'],'file') == 2 && exist([ModelPath '\Data\Results\' ModelName '_DLR.mat'],'file') == 0
                    [DLResults] = DeadLoadResults(uID, ModelPath, ModelName, Node, Parameters);
                
                    save([ModelPath '\Data\Results\' ModelName '_DLR.mat'],'DLResults','-v7');
                    clear('DLResults');
                end
                
                % Call Live Load Solver
                if exist([ModelPath '\Models\' ModelName '_LL.lsa'],'file') == 0
                    LiveLoadSolver(uID, Options, ModelName, ModelPath, Node, Parameters);
                end
  
                % Get Live Load Results
                if exist([ModelPath '\Models\' ModelName '_LL.lsa'],'file') == 2 && exist([ModelPath '\Data\Results\' ModelName '_LLR.mat'],'file') == 0
                    [LLResults] = LiveLoadResults(uID, ModelPath, ModelName, Node, Parameters);
                
                    save([ModelPath '\Data\Results\' ModelName '_LLR.mat'],'LLResults','-v7');
                    clear('LLResults');
                end
                
                if exist([ModelPath '\Data\Results\' ModelName '_DLR.mat'],'file') == 2 && exist([ModelPath '\Data\Results\' ModelName '_LLR.mat'],'file') == 2 
                    if exist('Parameters','var') ~= 1
                         load([pwd '\Data\Parameters\'  ModelName '.mat']);
                    end
                    if Parameters.NumLane <= 10
                        Parameters = FEMRatingFactors(Parameters,Options,ModelPath,ModelName);
                    end
                end
                calllib('St7API','St7CloseFile',uID);
                
                if exist('parameters','var') == 1
                    save([ModelPath '\Data\Parameters\' ModelName '.mat'], 'Parameters', '-v7');
                    clear Parameters;
                end
            end
        end
    end   
end

if Options.Analysis.Disp == 1
    for i=1:NumModels
        fprintf('Getting Disp Results For Model %u out of %u...\n',i,NumModels);  
        for j=1:Options.StructVar.NumVersions
            fprintf('Version %u out of %u...\n',j,Options.StructVar.NumVersions);
            
            uID=1;
            
            ModelName = [Options.NBI.State '_' strtrim(NBI(i).StructureNumber) '_' num2str(j)];
            
            ModelPathName = [ModelPath '\Models_old\' ModelName '.st7'];
            NodePathName = [ModelPath '\Data\Nodes_old\' ModelName '.mat'];
            
            if exist([ModelPath '\Models_old\' ModelName '.st7'],'file') == 2
                if exist([ModelPath '\Models_old\' ModelName '_1_LL.lsa'],'file') == 2  
                    
                    iErr = calllib('St7API', 'St7OpenFile', uID, ModelPathName, ScratchPath);
                    HandleError(iErr);
                    
                    load([pwd '\Data\Parameters_old\'  ModelName '.mat']);
                    if Parameters.NumLane <= 10
                    
                        Nodes = open(NodePathName);
                        NodeID = Nodes.Nodes.NodeID;
                        
                        LiveLoadDisp = LiveLoadDeflectionResults(uID, ModelPath, ModelName, NodeID, Parameters);
                        
                        save([ModelPath '\Data\Results_old\' ModelName '_LLD.mat'],'LiveLoadDisp','-v7');
                        clear('LiveLoadDisp');
                        clear('Nodes');
                        clear('NodeID');
                        
                        Parameters = LLDispComp(Parameters,Options,ModelPath,ModelName);
                        
                        save([ModelPath '\Data\Parameters_old\' ModelName '.mat'], 'Parameters', '-v7');
                        clear Parameters;
                    end
                    
                    calllib('St7API','St7CloseFile',uID);
                    
                    
                end
            end
        end
    end   
end
%matlabpool close
unloadlibrary('St7API');
close all;
toc
clear all;

end %RAMPS()