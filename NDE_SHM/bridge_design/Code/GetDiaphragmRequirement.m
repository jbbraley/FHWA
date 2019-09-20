function Parameters = GetDiaphragmRequirement(Parameters, CShapes, LShapes, Beam)

Parameters.Dia.Force = 1.14*50/144*Beam.d*Parameters.Dia.Spacing; % wind force

if strcmp(Parameters.Dia.Assign, 'Auto')
    if Beam.d <= 30
        Parameters.Dia.Type = 'Beam';
        Parameters.Dia.Req = Beam.d/2;
        DiaShapes = CShapes;
    else
        Parameters.Dia.Type = 'Cross'; %or 'Cross' or 'Chevron' or 'Beam'
        if strcmp(Parameters.Dia.Config,'Normal')
            Parameters.Dia.Req = 0.75*sqrt(Parameters.GirderSpacing^2+Beam.d^2)/140; %Requirement is radius of gyration for Kl/r = 140 , K=0.75
        elseif strcmp(Parameters.Dia.Config,'Parallel')
            Parameters.Dia.Req = 0.75*sqrt((Parameters.GirderSpacing/cos(Parameters.SkewNear*pi()/180))^2+Beam.d^2)/140;
        else
            Parameters.Dia.Req = 0.75*sqrt(Parameters.GirderSpacing^2+Beam.d^2)/140; %Requirement is radius of gyration for Kl/r = 140 , K=0.75
        end
        DiaShapes = LShapes;
    end
    
    Parameters = GetDiaSection(Parameters, DiaShapes, Beam); 
end
%     
% else
%     if strcmp(Parameters.Dia.Type, 'Beam')
%         Parameters.Dia.Req = Parameters.Beam.d/2;
%         DiaShapes = CShapes;
%     else
%         if strcmp(Parameters.Dia.Config,'Normal')
%             Parameters.Dia.Req = 0.75*sqrt(Parameters.GirderSpacing^2+Parameters.Beam.d^2)/140; %Requirement is radius of gyration for Kl/r = 140 , K=0.75
%         elseif strcmp(Parameters.Dia.Config,'Parallel')
%             Parameters.Dia.Req = 0.75*sqrt((Parameters.GirderSpacing/cos(Parameters.SkewNear*pi()/180))^2+Parameters.Beam.d^2)/140;
%         else
%             Parameters.Dia.Req = 0.75*sqrt(Parameters.GirderSpacing^2+Parameters.Beam.d^2)/140; %Requirement is radius of gyration for Kl/r = 140 , K=0.75
%         end
%         DiaShapes = LShapes;       
%     end
% end

% Parameters = GetDiaSection(Parameters, DiaShapes); 

end %GetDiaphragmRequirment()
    