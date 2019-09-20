% NCHRP_BuildModelPopulation

clc
clear

h = waitbar(0,'Initializing...');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% USER INPUT --------------------------------------------------------------

    % Directories
    Path = 'C:\Users\Nick\Desktop\tmp';

    % Model Info
    structureType = 'Steel';
    Spans = 2;
    
% OTHER SET-UP ------------------------------------------------------------

    % Load Shapes
    load([Path '\Tables\WShapes_Current.mat']);
    load([Path '\Tables\CShapes_Current.mat']);
    load([Path '\Tables\LShapes_Current.mat']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
%%%%%%%%%%%%%%%%%%%%%%%%% CREATE/LOAD SAMPLE SPACE %%%%%%%%%%%%%%%%%%%%%%%%

    % Sampling Parameters
    n = 100;
    p = 5;
    lb = [480 432 0 20 60]; % bounds = [Length Width Skew Span/Depth GirderSpacing]
    ub = [1920 864 60 30 144];
    
    if exist([Path '\SampleSpace.mat'],'file') == 0
        SampleSpace = LHS(lb,ub,n,p);
        save([Path '\SampleSpace.mat'],'SampleSpace');
    else % Load or Build Sample Space
        load([Path '\SampleSpace.mat']);
        fprintf('Sample space loaded. \n');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODEL SIZING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1:size(SampleSpace,1)

    if exist([Path '\Nodes\Bridge_' num2str(ii) '_Node.mat'],'file') 
        continue
    else
        
        waitbar(ii/length(SampleSpace),h,['Sizing members for Bridge ' num2str(ii) '...']);

% MEDIAN MODEL SETUP ------------------------------------------------------

        % Initialize Parameters and Options
        
        St7Start = 1;
        Options = [];
        Parameters = [];
        ScratchPath = 'C:\Temp';
        [Parameters, Options] = InitializeRAMPS(Options, Parameters, St7Start);

        % Default Median Model Parameters/Options
        Parameters.Spans = Spans;
        Parameters.structureType = structureType;
        [Parameters,Options] = MedianModelParameters(Parameters,Options);

% SAMPLED PARAMETER ASSIGNMENTS -------------------------------------------

        % LHS Assignments 
        Length = SampleSpace(ii,1);
        ExtWidth = SampleSpace(ii,2);
        Skew = SampleSpace(ii,3);
        SpanDepth = SampleSpace(ii,4);
        GirderSpacing = SampleSpace(ii,5);

        % NumGirder (based on number of girder that fit in road width) 
        Spaces = round(ExtWidth/GirderSpacing);
        NumGirder = Spaces + 1;

        % Adjusted Road width
        AdjustedExtWidth = Spaces*GirderSpacing;

        % Add 30" Overhang
        Width = AdjustedExtWidth + 2*Parameters.Overhang; % Out-to-out

        % Parameter Assignments
        Parameters.NumGirder = NumGirder;
        Parameters.GirderSpacing = GirderSpacing;
        Parameters.Length(1:Parameters.Spans,1) = Length; % For two span bridge
        Parameters.SkewNear = Skew;
        Parameters.SkewFar = Skew;
        Parameters.RoadWidth = AdjustedExtWidth;
        Parameters.TotalWidth = AdjustedExtWidth;
        Parameters.Width = Width;
        Parameters.NumDia = ceil(Parameters.Length/Options.Dia.Spacing);
        Parameters.Design.MaxSpantoDepth = SpanDepth;
        Parameters.Beam.Int.CoverPlate.Length = max(Parameters.Length)*Parameters.Beam.Int.CoverPlate.Ratio;
        Parameters.Beam.Ext.CoverPlate.Length = max(Parameters.Length)*Parameters.Beam.Ext.CoverPlate.Ratio;

% MODEL NAME/PATH ---------------------------------------------------------

        % Save model name and path name
        modelName = ['Bridge_' num2str(ii)];
        Options.FileName = [modelName '.st7'];
        Options.PathName = [Path '\Strand7 Model Files'];
        Parameters.ModelName = modelName;
        
% MEMBER SIZING -----------------------------------------------------------

        % Get AASHTO design parameters
        Parameters = AASHTODesign(Parameters, Options); 

    % --------------------------- SLG ANALYSIS ----------------------------
        waitbar(ii/size(SampleSpace,1),h, ['Running SL Analysis for Bridge ' num2str(ii)]);
        [Parameters,Parameters.Design.SLG.Int] = GetFEApproximation(Parameters, []);
        Parameters.Design.SLG.Ext = Parameters.Design.SLG.Int;
        Parameters = GetAASHTOLLDeflectionRequirement(Parameters);

    % --------------------------- GIRDER SIZING ---------------------------
        Section = {'Int';'Ext'};
        waitbar(ii/size(SampleSpace,1),h, ['Sizing Bridge ' num2str(ii)]);
        Parameters = GirderSizing(Parameters, Options, Section,CShapes, WShapes, LShapes);

    % ---------------------------- SLG RATING -----------------------------
        if ~strcmp(Parameters.Beam.Type, 'None')

            Code = Parameters.Rating.Code;
            Parameters.Rating.(Code).DesignLoad = Parameters.Design.DesignLoad;
            Parameters.Rating.(Code).useCB = 0;
            Parameters.Rating.(Code) = GetTruckLoads(Parameters.Rating.(Code));
            [Parameters,Parameters.Rating.(Code)] = ...
                AASHTOLoadRating(Parameters.Rating.(Code),Parameters);
%             Parameters.Rating.(Code).Load.A = ...
%                 Parameters.Rating.(Code).Load.A*Parameters.Rating.(Code).IMF;
%             Parameters.Rating.(Code).Load.TD = ...
%                 Parameters.Rating.(Code).Load.TD*Parameters.Rating.(Code).IMF;

            % Get Rating Factor
            for jj = 1:2
                Parameters.Rating.(Code).SL.(Section{jj}) = ...
                    GetRatingFactor(Parameters.Beam.(Section{jj}),Parameters.Demands.(Section{jj}).SL,Parameters,Section{jj});
            end

    % ------------------------- COMPACTNESS CHECK -------------------------
            for jj = 1:2
                Parameters.Beam.(Section{jj}) = CompactCheckLRFD(Parameters.Beam.(Section{jj}),Parameters);
            end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODEL BUILDING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            waitbar(ii/size(SampleSpace,1),h, ['Building Bridge ' num2str(ii) ' Strand 7 Model']);

            CloseAndUnload(Options.St7.uID);
            InitializeSt7();

            NewModel(Options.St7.uID, Options.PathName, modelName, Options.St7.ScratchPath, Options.St7.Units)
            [Node, Parameters] = ModelGeneration(Options.St7.uID, Options, Parameters);
            save([Path '\Nodes\' modelName '_Node.mat'],'Node','-v7');
            clear('Nodes');

            % Save model file
            iErr = calllib('St7API', 'St7SaveFile', Options.St7.uID);
            HandleError(iErr);

            CloseModelFile(Options.St7.uID);
            CloseAndUnload(Options.St7.uID);
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            save([Path '\Parameters\' modelName '_Para.mat'], 'Parameters', '-v7');
            save([Path '\Options\' modelName '_Options.mat'], 'Options', '-v7');
            save([Path '\Nodes\' modelName '_Node.mat'],'Node','-v7');
            clear Parameters Options Nodes
            
        end  
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%% GET MODELSPACE INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitbar(0.5,h,'Generating ModelSpace.mat...');
ModelSpace = GetModelInfo(Path);
waitbar(0.75,h,'Saving ModelSpace.mat...');
save([Path '\ModelSpace.mat'],'ModelSpace');   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BACK-UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitbar(0.9,h,'Saving Back-Up Files...');
P1 = [Path '\Parameters']; P2 = [Path '\Back-Up\Parameters']; 
N1 = [Path '\Nodes']; N2 = [Path '\Back-Up\Nodes'];
O1 = [Path '\Options']; O2 = [Path '\Back-Up\Options'];
M1 = [Path '\Strand7 Model Files']; M2 = [Path '\Back-Up\Strand7 Model Files'];
copyfile(P1,P2);
copyfile(N1,N2);
copyfile(O1,O2);
copyfile(M1,M2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Model population building complete. \n');
close(h);
