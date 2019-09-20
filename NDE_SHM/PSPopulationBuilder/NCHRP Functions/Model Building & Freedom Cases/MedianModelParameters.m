function [Parameters, Options] = MedianModelParameters(Parameters,Options)

% Median Model Parameters
Parameters.Design.Code = 'LRFD';
Parameters.Design.DesignLoad = 'A';
Parameters.Rating.Code = 'LRFD';
Parameters.ModelType = 'RAMPS Design';
Parameters.LengthOption = 'Girder';
Parameters.Beam.Fy = 50000;
Parameters.Beam.E = 29000000;
if Parameters.Spans > 1
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
if Parameters.Spans == 1
    Parameters.Bearing.Type = [1; 0];
elseif Parameters.Spans == 2
    Parameters.Bearing.Type = [1; 0; 0];
elseif Parameters.Spans == 3
    Parameters.Bearing.Type = [1; 0; 0; 0];
end

% Fixed Bearing (Restrain vertical, alignment, longitudinal)
Parameters.Bearing.Fixed.Fixity = [0 0 1 0 0 0 1 1];

% Expansion bearing (restrain vertical and alignment)
Parameters.Bearing.Expansion.Fixity = [0 0 1 0 0 0 1 0];




end