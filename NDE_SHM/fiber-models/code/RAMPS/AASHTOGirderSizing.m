function Parameters = AASHTOGirderSizing(Parameters, Options)
%% ASD & LRFD Design
oldFolder = pwd;
cd('..\');
filepath = [pwd '\Tables\WShapes_Current.mat'];
load(filepath);
filepath = [pwd '\Tables\CShapes_Current.mat'];
load(filepath);
filepath = [pwd '\Tables\LShapes_Current.mat'];
load(filepath);
cd(oldFolder);

% Get LL Deflection Requirements
exitflagP = -99;
exitflagR = -99; % make these default for not running case
exitflagCP = -99;

% Runs innitial design for simple or continuous span with no cover plate
% for rolled and plate girder
    if strcmp(Parameters.Design.Code, 'ASD')
        if Parameters.Spans == 1
            [Parameters_tempR, exitflagR] = RolledGirderDesignASD(Parameters, Options, WShapes, CShapes, LShapes);
            Parameters.tempR = Parameters_tempR;
        end
        [Parameters_tempP, exitflagP] = PlateGirderDesignASD(Parameters, CShapes, LShapes);
        Parameters.tempP = Parameters_tempP;
    elseif strcmp(Parameters.Design.Code, 'LRFD')
        if Parameters.Spans == 1
            [Parameters_tempR, exitflagR] = RolledGirderDesignLRFD(Parameters, Options, WShapes, CShapes, LShapes);
            Parameters.tempR = Parameters_tempR;
            
            [Parameters_tempP, exitflagP] = PlateGirderDesignLRFD_NoCP(Parameters, CShapes, LShapes);
            Parameters.tempP = Parameters_tempP;
        else % Spans > 1
            if Parameters.Design.CoverPlate.Ratio > 0
                [Parameters_tempP, exitflagP] = PlateGirderDesignLRFD_CP(Parameters, CShapes, LShapes); %Runs if user chooses to include a cover plate 
                Parameters.tempP = Parameters_tempP;
            else
                [Parameters_tempP, exitflagP] = PlateGirderDesignLRFD_NoCP(Parameters, CShapes, LShapes);%Runs if user chooses not to include a cover plate
                Parameters.tempP = Parameters_tempP;
            end
        end
    end

% Saves design as either rolled girder or plate girder        
    if exitflagP > 0 && exitflagR > 0 % if both pass
            if Parameters_tempR.Beam.A*(1 + Options.RolledGirder.Var) <= Parameters_tempP.Beam.A % if rolled is lighter plus penatly
                Parameters = Parameters_tempR;
                Parameters.Beam.Type = 'Rolled'; %Rolled girder is designed
                Parameters = GetRatingFactor(Parameters);
            else
                Parameters = Parameters_tempP;
                Parameters.Beam.Type = 'Plate'; %Plate girder is designed
                Parameters = GetRatingFactor(Parameters);
            end
    elseif exitflagP > 0
        Parameters = Parameters_tempP;
        Parameters.Beam.Type = 'Plate';%Plate girder is designed
        Parameters = GetRatingFactor(Parameters);
    else
        Parameters.Beam.Type = 'None';
    end

Parameters.Design.ExitFlags = [exitflagR, exitflagP, exitflagCP];
end