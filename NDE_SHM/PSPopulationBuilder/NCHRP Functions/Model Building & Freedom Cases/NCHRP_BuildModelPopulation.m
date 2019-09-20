% NCHRP_BuildModelPopulation

clc
clear

h = waitbar(0,'Initializing...');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% USER INPUT --------------------------------------------------------------

    % Directories
    Path = 'C:\Users\Nick\Documents\Projects\NCHRP - Phase II\Steel\2-Span\Suite 2 - Re-run';

    % Model Info
    structureType = 'Steel';
    Spans = 2;
    
% OTHER SET-UP ------------------------------------------------------------

    % Load Shapes
    load([Path '\WShapes_Current.mat']);
    load([Path '\CShapes_Current.mat']);
    load([Path '\LShapes_Current.mat']);

    % Sampling Parameters
    n = 100;
    p = 5;
    lb = [480 432 0 20 60]; % bounds = [Length Width Skew Span/Depth GirderSpacing]
    ub = [1920 864 60 30 144];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
%%%%%%%%%%%%%%%%%%%%%%%%% CREATE/LOAD SAMPLE SPACE %%%%%%%%%%%%%%%%%%%%%%%%

    if exist([Path '\SampleSpace.mat'],'file') == 0
        SampleSpace = LHS(lb,ub,n,p);
        save([Path '\SampleSpace.mat'],'SampleSpace');
    else % Load or Build Sample Space
        load([Path '\SampleSpace.mat']);
        fprintf('Sample space loaded. \n');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MODEL SIZING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = [2 15 22 24 26 47 48 53 76 77 98] %1:size(SampleSpace,1)

    if exist([Path '\Nodes\Bridge_' num2str(ii) '_Node.mat'],'file') 
        continue
    else
        
        waitbar(ii/length(SampleSpace),h,['Sizing members for Bridge ' num2str(ii) '...']);

% MEDIAN MODEL SETUP ------------------------------------------------------

        % Initialize Parameters and Options
        St7Start = 1;
        Options = [];
        Parameters = [];
        [Parameters, Options] = InitializeRAMPS(Options, Parameters, St7Start);

        % Median Model Parameters
        Parameters.Design.Code = 'LRFD';
        Parameters.Design.DesignLoad = 'A';
        Parameters.Rating.Code = 'LRFD';
        Parameters.ModelType = 'RAMPS Design';
        Parameters.structureType = structureType;
        Parameters.LengthOption = 'Girder';
        Parameters.Spans = Spans;
        Parameters.Beam.Fy = 50000;
        Parameters.Beam.E = 29000000;
        if Spans > 1
            Parameters.Beam.Int.CoverPlate.Ratio = 0.2;
            Parameters.Beam.Ext.CoverPlate.Ratio = 0.2;
        else
            Parameters.Beam.Int.CoverPlate.Ratio = 0;
            Parameters.Beam.Ext.CoverPlate.Ratio = 0;
        end
        Parameters.Dia.E = 29000000;
        Parameters.Dia.density = 0.284321769236;
        Parameters.Deck.t = 9;
        Parameters.Deck.WearingSurface = 0;
        Parameters.Deck.Offset = 0;
        Parameters.Deck.CompositeDesign = 1;
        Parameters.Deck.density = 150/(12^3); %pci
        Parameters.Deck.fc = 4000;
        Parameters.Deck.E = 57000*sqrt(Parameters.Deck.fc);
        Parameters.Sidewalk.Height = 0;
        Parameters.Sidewalk.Left = 0;
        Parameters.Sidewalk.Right = 0;
        Parameters.Sidewalk.density = 150/(12^3); %pci
        Parameters.Sidewalk.fc = 4000;
        Parameters.Sidewalk.E = 57000*sqrt(Parameters.Sidewalk.fc);
        Parameters.Barrier.Height = 27;
        Parameters.Barrier.Width = 12;
        Parameters.Barrier.density = 150/(12^3); %pci
        Parameters.Barrier.fc = 4000;
        Parameters.Barrier.E = 57000*sqrt(Parameters.Barrier.fc);
        Parameters.Overhang = 30;

        % Design Options
        Options.Spans = Parameters.Spans;
        Options.Dia.Spacing = 20*12;
        Options.Dia.autoConfig = 1;

        % Default bearing conditions
        if Spans == 1
            Parameters.Bearing.Type = [1; 0];
        elseif Spans == 2
            Parameters.Bearing.Type = [1; 0; 0];
        elseif Spans == 3
            Parameters.Bearing.Type = [1; 0; 0; 0];
        end

        % Fixed Bearing (Restrain vertical, alignment, longitudinal)
        Parameters.Bearing.Fixed.Fixity = [0 0 1 0 0 0 1 1];

        % Expansion bearing (restrain vertical and alignment)
        Parameters.Bearing.Expansion.Fixity = [0 0 1 0 0 0 0 0];
        
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
        Options.PathName = Path;
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
            InitializeSt7(1);

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
ModelSpace = GetModelInfo_v2(Path);
waitbar(0.75,h,'Saving ModelSpace.mat...');
save([Path '\ModelSpace.mat'],'ModelSpace');   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BACK-UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitbar(0.9,h,'Saving Back-Up Files...');
F1 = [Path '\*.st7']; F2 = [Path '\Model Back-Up'];
copyfile(F1,F2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Model population building complete. \n');
close(h);
