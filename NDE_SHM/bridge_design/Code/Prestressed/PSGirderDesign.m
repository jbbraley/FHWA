function [ Parameters, exitflag] = PSGirderDesign( Parameters )

 
%% 7 Wire Strand diam. & area
DA(:,1) = [.250 .313 .375 .438 .500 .520 .563 .600 .700]';
DA(:,2) = [.036 .058 .085 .115 .153 .167 .192 .217 .294]';

%% Get Section Forces and Moments
% Get Single Line Girder Results
Parameters.Design.Code = 'LRFD';
Parameters.Design.DesignLoad = 'A';
Parameters.Design = GetTruckLoads(Parameters.Design);
Parameters = AASHTODesign(Parameters);

exitflag=0;
n=0;
while exitflag==0
    [ Parameters, sxn_flag ] = GetPSGirder( Parameters,n);
    if sxn_flag~=1
        break
    end
    Parameters.Beam.Int = Parameters.Beam;
    Parameters.Beam.Int.Des = 'Int';
    Parameters.Beam.Ext = Parameters.Beam.Int;
    Parameters.Beam.Ext.Des = 'Ext';
    [Parameters,Parameters.Design.Load] = GetFEApproximation(Parameters, []);
    % Calculate Section Forces
    Parameters = PSSectionForces(Parameters);
    %% Find number of strands necessary for each diameter
    [NumStrands, Dia, Parameters, exitflag] = GetStrands(Parameters);
    n = n+1;
end

if exitflag
    Parameters.Beam.PSSteel.d = DA(Dia,1);
    Parameters.Beam.PSSteel.Aps = DA(Dia,2);
    Parameters.Beam.PSSteel.NumStrands = NumStrands;
    % Parameters.Beam.PSCenter = GetPSCenter(Parameters, NumStrands);
    % Parameters.Beam.PSEcc = Parameters.Beam.yb-Parameters.Beam.PSCenter;
    Rbar(:,1) = [3 4 5 6 7 8 9 10 11 14 18];
    Rbar(:,2) = [.11 .20 .31 .44 .60 .79 1.00 1.27 1.56 2.25 4];
    Rbar(:,3) = [.375 .5 .625 .75 .875 1 1.128 1.27 1.41 1.693 2.257];

    if Parameters.Beam.RFSteelCheck
        
        Num = Parameters.Beam.RFSteel.A./Rbar(:,2);
        limit = (Parameters.Beam.bft-4)./(Rbar(:,3)+2);
        
        if ~isfield(Parameters.Beam.RFSteel,'BarNo') || isempty(Parameters.Beam.RFSteel.BarNo)
            barind = find((limit-Num)>0,1,'first');
        else
            barind = find(Parameters.Beam.RFSteel.BarNo==Rbar(:,1));
        end
        if ~isempty(barind)
            Parameters.Beam.RFSteel.BarNo = Rbar(barind,1);
            Parameters.Beam.RFSteel.NumBars = ceil(Num(barind));
            Parameters.Beam.RFSteel.A = Parameters.Beam.RFSteel.NumBars*Rbar(barind,2);
        else
            Parameters.Beam.RFSteel.BarNo = [];
            Parameters.Beam.RFSteel.A = 0;
            Parameters.Beam.RFSteel.NumBars = 0;
        end
        
        if Parameters.Beam.RFSteel.NumBars*(Rbar(barind,3)+2)+2<Parameters.Beam.bft
            Parameters.Beam.RFCenter = 2+Rbar(barind,3)/2;
        else
            row1 = floor((Parameters.Beam.bft-4)/(Rbar(barind,3)+2));
            row2 = Parameters.Beam.RFSteel.NumBars-row1;
            Parameters.Beam.RFCenter = (Rbar(barind,2)*row1*(2+Rbar(barind,3)/2)+Rbar(barind,2)*row2*(4+Rbar(barind,3)*3/2))/Parameters.Beam.RFSteel.A;
        end
        
    end
else
    disp('No suitable design found');    
end


end

