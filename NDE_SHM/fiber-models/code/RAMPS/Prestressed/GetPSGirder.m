function [ Parameters, exitflag ] = GetPSGirder( Parameters)


if strcmp(Parameters.Beam.Type, 'AASHTO')
    MaxSpan(:,1) = [1:6];
    MaxSpan(:,2) = [48 70 100 120 145 167]';
elseif strcmp(Parameters.Beam.Type, 'BulbTee')
    MaxSpan(:,1) = [54 63 72]';
    MaxSpan(:,2) = [114 130 146]';
end

Type = find((MaxSpan(:,2)-(max(Parameters.Length)/12)>0),1,'first');
if isempty(Type)
    exitflag = 0;
else
    exitflag = 1;
end

Parameters.Beam.Name = [Parameters.Beam.Type num2str(MaxSpan(Type,1))];

[Parameters.Beam, Parameters.Beam.Section] = PSSectionChoose(Parameters.Beam.Name, Parameters.Beam);

end 