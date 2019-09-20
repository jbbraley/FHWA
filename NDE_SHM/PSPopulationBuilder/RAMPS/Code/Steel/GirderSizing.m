function Parameters = GirderSizing(Parameters, Options,Section,CShapes, WShapes, LShapes)
%% ASD & LRFD Design
% Case = inputs{1};
% switch Case
%     case 'RAMPS'
%         oldFolder = pwd;
%         cd('..\');
%         filepath = [pwd '\Tables\WShapes_Current.mat'];
%         load(filepath);
%         filepath = [pwd '\Tables\CShapes_Current.mat'];
%         load(filepath);
%         filepath = [pwd '\Tables\LShapes_Current.mat'];
%         load(filepath);
%         cd(oldFolder);
%     case 'Study'
%         load(inputs{2});
%         load(inputs{3});
%         load(inputs{4});
% end

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
        [Parameters_tempR,exitflagR] = RolledGirderDesignLRFD(Parameters,Options,WShapes,CShapes,LShapes);
    end
      [Parameters_tempP,exitflagP] = PlateSizing_LRFD(Parameters, CShapes, LShapes,Section);
end

% Handle exitflags
if strcmp(Section, 'All')
    exitflagP = min(exitflagP);
else
    exitflagP = min(exitflagP(1,2), exitflagP(2,2));
end

%-----------FINAL GIRDER SIZING-------------------

% Saves design as either rolled girder or plate girder

if exitflagP > 0 && min(exitflagR) > 0 % if both pass
        if Parameters_tempR.Beam.Int.A*(1 + Options.RolledGirder.Var) <= Parameters_tempP.Beam.Int.A % if rolled is lighter plus penatly
            Parameters = Parameters_tempR;
            Parameters.Beam.Type = 'Rolled'; %Rolled girder is designed
        else
            Parameters = Parameters_tempP;
            Parameters.Beam.Type = 'Plate';%Plate girder is designed
        end
elseif all(exitflagP > 0)
    Parameters = Parameters_tempP;
    Parameters.Beam.Type = 'Plate';%Plate girder is designed
%         Parameters = GetRatingFactor(Parameters);
else
    Parameters.Beam.Type = 'None';
end
      
Parameters.Design.ExitFlags = [exitflagR, exitflagP, exitflagCP];
end