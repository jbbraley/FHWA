% Study to validate Interior vs Exterior vs Interior/Exterior Section
clc

%% DEFINE DIRECTORY TO SAVE STUDY FILES
dirName = 'C:\Users\David\RAMPS';

%% LOAD/CREATE PARAMETER SAMPLE SPACE
Results = cell(length(SampleSpace),1);

%% BUILD MODEL SPACE
for ii = 1:20  
    Parameters = P_temp;
    % Save model name & sample parameters
    modelName = ['StudyBridge_' num2str(ii)];
    Parameters.ModelName = modelName;
    
    Results{ii,1} = modelName; % Model Name
    Results{ii,2} = SampleSpace(ii,1); % Girder Spacing
    Results{ii,3} = SampleSpace(ii,2); % Length
    Results{ii,4} = SampleSpace(ii,3); % Skew
    
    % Design code
    Parameters.Design.Code = 'LRFD';
    Parameters.Design.DesignLoad = 'A';

    % Model Design 
    Parameters.ModelType = 'RAMPS Design';

    % NBI
    NBI = [];

    % DESIGN/SIZING
    Parameters.Design.MaxSpantoDepth = 20;
    Parameters.Deck.CompositeDesign = 1;
    
    % LHS Assignments 
    GirderSpacing = Results{ii,2};
    Length = Results{ii,3};
    Skew = Results{ii,4};
    
    % NumGirder (based on number of girder spaces that fit in road width)
    Spaces = floor(Parameters.RoadWidth/GirderSpacing); 
    NumGirder = Spaces + 1;
    
    Results{ii,5} = NumGirder; % Number of Girders
    
    % Adjusted Road width   
    Parameters.RoadWidth = Spaces*Results{ii,2};
    
    % Parameter Assignments
    Parameters.NumGirder = NumGirder;
    Parameters.GirderSpacing = GirderSpacing;
    Parameters.Length = [Length;Length]; % For two span bridge
    Parameters.SkewNear = Skew;
    Parameters.SkewFar = Skew;
    Parameters.TotalWidth = Parameters.RoadWidth;
    Parameters.Width = Parameters.RoadWidth + 60; % Add 30" overhang on either side
    Parameters.Overhang = (Parameters.Width - Parameters.TotalWidth)/2;
    Parameters.NumDia = ceil(Parameters.Length/(25*12));
    
     % Coverplate
    Parameters.Beam.CoverPlate.Ratio = 0.2;
    Parameters.Beam.CoverPlate.Length = round(Parameters.Beam.CoverPlate.Ratio*max(Parameters.Length));
    
    % Structure Configuration parameters (replaced GetStructureConfig.m)
    Parameters.Beam.E = 29000000;
    Parameters.Dia.E = 29000000;
    Parameters.Dia.density = 0.284321769236;
    Parameters.Sidewalk.density = 150/(12^3); %pci
    Parameters.Deck.density = 150/(12^3); %pci
    Parameters.Barrier.density = 150/(12^3); %pci
    Parameters.Deck.E = 57000*sqrt(Parameters.Deck.fc);
    Parameters.Sidewalk.E = 57000*sqrt(Parameters.Sidewalk.fc);
    Parameters.Barrier.E = 57000*sqrt(Parameters.Barrier.fc);
    Parameters.LengthOption = 'Girder';
    
    % Get AASHTO design parameters
    Parameters = AASHTODesign(Parameters); 

    % Single Line Analysis
    Parameters = GetMemberActions(Parameters);
    Parameters = GetAASHTOLLDeflectionRequirement(Parameters);
    
    % Girder Sizing function
    inputs = cell(4,1);
    inputs{1} = 'RAMPS';
    inputs{2} = WShapes;
    inputs{3} = CShapes;
    inputs{4} = LShapes;
    
    Parameters.Design.Section = 'All';
    Parameters = GirderSizing(Parameters,Options,inputs);

    if ~strcmp(Parameters.Beam.Type, 'None')
        
        % Section dimensions
        Results{ii,6} = Parameters.Beam.bf;
        Results{ii,7} = Parameters.Beam.tf;
        Results{ii,8} = Parameters.Beam.CoverPlate.tf;
        Results{ii,9} = Parameters.Beam.CoverPlate.t;
        Results{ii,10} = Parameters.Beam.tw;
        
        % Girder capacities
        Results{ii,11} = Parameters.Beam.Mn_pos;
        Results{ii,12} = Parameters.Beam.Fn_neg;
        
        % Compact/Non-compact
        Results{ii,13} = Parameters.Beam.Comp;
        Results{ii,14} = Parameters.Beam.ExitflagC;
        Results{ii,15} = Parameters.Beam.ExitflagNC;
        Results{ii,13} = Parameters.Beam.DesignTime;
        Results{ii,14} = Parameters.Beam.Iterations;

        % LRFD Assignments
        Parameters.Rating.Code = 'LRFD';
        Parameters.Rating.DesignLoad = 'A';
        % Get Trucks
        Parameters.Rating = GetTruckLoads(Parameters.Rating);
        Parameters.Rating.IMF = 1.33;
        Parameters.Rating.Load.A = Parameters.Rating.Load.A*Parameters.Rating.IMF;
        Parameters.Rating.Load.TD = Parameters.Rating.Load.TD*Parameters.Rating.IMF;
        % AASHTO Load Rating
        Parameters = AASHTOLoadRating(Parameters);
        Parameters.Rating.SingleLine = GetRatingFactor(Parameters.Beam,Parameters.Demands,Parameters,'false');
        save([dirName '\Parameters\' modelName '_Para.mat'], 'Parameters', '-v7');      

        %Ratings
        Results{ii,15} = min(Parameters.Rating.SingleLine.Int.Strength1_inv);
        Results{ii,16} = min(Parameters.Rating.SingleLine.Int.Strength1_op);
        Results{ii,17} = min(Parameters.Rating.SingleLine.Ext.Strength1_inv);
        Results{ii,18} = min(Parameters.Rating.SingleLine.Ext.Strength1_op);
    else
        for q = 6:18
            Results{ii,q} = 'N/A';
        end
    end
       
 
end
save('C:\Users\David\RAMPS', 'Results');
