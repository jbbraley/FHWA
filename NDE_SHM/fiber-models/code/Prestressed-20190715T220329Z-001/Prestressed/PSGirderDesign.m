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
% Calculate Section Forces
Parameters = PSSectionForces(Parameters);


%% Find number of strands necessary for each diameter
exitflag = 0;
DiaStart = 5;
MaxStrandFactor = 1;
for ii=DiaStart:length(DA(:,1))
%     if ii == DiaStart
%         Strandstart = 6;
%     else        
%         Strandstart = ceil(floor(Parameters.Beam.PSSteel.At/DA(ii,2)*0.8)/2)*2;
%     end

Strandstart = 6;
    
    for j=Strandstart:2:ceil(MaxStrandFactor*Parameters.Beam.MaxStrands)
        % Calculate area of prestressing steel
        Parameters.Beam.PSSteel.At = j*DA(ii,2);
        % Record diameter of strands
        Parameters.Beam.PSSteel.d = DA(ii,1);
        
        % Calculate centroid of strands
        Parameters.Beam.PSCenter = GetPSCenter(Parameters, j);
        
        % Get capacity of beam with prestressing
        Parameters = PSGirderCapacity(Parameters);       
        
        % Get demands based on single line girder model
        Parameters = PSGirderDemand(Parameters);
        % Overwrite compression steel based on user input
        if ~Parameters.Beam.RFSteelCheck
            Parameters.Beam.RFSteel.A = 0;
            Parameters.Beam.RFCenter = 0;
        end

        
        %% Constraints
        % Stress limits at transfer
%         c(1) = max(Parameters.Design.Transfer.StressT_max)-0.24*sqrt(Parameters.Beam.fci/1000)*1000;
%         c(2) = max(Parameters.Design.Transfer.StressB_max)-0.24*sqrt(Parameters.Beam.fci/1000)*1000;
        c(1) = -.60*Parameters.Beam.fci-min(Parameters.Design.Transfer.StressT_min); % S5.9.4.1.1
        c(2) = -.60*Parameters.Beam.fci-min(Parameters.Design.Transfer.StressB_min);
        % Stress limits under Service Loads
        c(3) = -.60*Parameters.Beam.fc - min(Parameters.Design.Service.StressT_min); % S5.9.4.2.1-1
        c(4) = -.45*Parameters.Beam.fc - min(Parameters.Design.PS1.StressT_min);
        c(5) = -.40*Parameters.Beam.fc - min(Parameters.Design.PS2.StressT_min);
        c(6) = -.45*Parameters.Beam.fc - min(Parameters.Design.Service.StressB_min);
        c(7) = -.45*Parameters.Beam.fc - min(Parameters.Design.PS1.StressB_min);
        c(8) = max(Parameters.Design.Service.StressB_max)-.19*sqrt(Parameters.Beam.fc/1000)*1000;
%         c(10) = max(Parameters.Design.Service.StressT_max)-.19*sqrt(Parameters.Beam.fc/1000)*1000;
        c(9) = -.6*Parameters.Deck.fc - min(Parameters.Design.Deck.Stress_min);
%         c(12) = max(Parameters.Design.PS1.StressB_max)-.19*sqrt(Parameters.Beam.fc/1000)*1000;
%         c(13) = max(Parameters.Design.PS1.StressT_max)-.19*sqrt(Parameters.Beam.fc/1000)*1000;
        % Strength Requirements
        c(10) = Parameters.LRFD.M_pos - Parameters.Beam.Mn_pos;
        % Over-reinforcement check
        c(11) = Parameters.Beam.cde-0.42;
        % Cracking moment check
        c(12) = min(1.33*Parameters.LRFD.M_pos, 1.2*Parameters.Beam.Mcr)-Parameters.Beam.Mn_pos;
        
%         d(1) = Parameters.Design.Transfer.StressT_max;
%         d(2) = Parameters.Design.Transfer.StressT_max;
%         d(3) = Parameters.Design.Transfer.StressT_min;
%         d(4) = Parameters.Design.Transfer.StressB_min;
%         d(5) = Parameters.Design.Service.StressT_min;
%         d(6) = Parameters.Design.PS1.StressT_min;
%         d(7) = Parameters.Design.PS2.StressT_min;
%         d(8) = Parameters.Design.Service.StressB_min;
%         d(9) = Parameters.Design.PS1.StressB_min;
%         d(10) = Parameters.Design.Service.StressB_max;
%         d(11) = Parameters.Design.Deck.Stress_min;
%         d(12) = Parameters.Design.PS1.StressB_max;
%         d(13) = Parameters.Design.PS1.StressT_max;
%         d(14) = Parameters.LRFD.M_pos;
%         d(15) = Parameters.Beam.cde;
%         d(16) = Parameters.Beam.Mcr;
        
        C(:,j) = c;
 
        if any(c>0)
            continue
        end
        
        NumStrands = j;
        exitflag = 1;
        
        break
                
    end
    
    if exitflag == 1
        Dia = ii;
        break
    end
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
        barind = find((Num-limit)>0,1,'last');
        if ~isempty(barind)
            Parameters.Beam.RFSteel.BarNo = Rbar(barind,1);
            Parameters.Beam.RFSteel.NumBars = ceil(Num(barind));
            Parameters.Beam.RFSteel.A = Parameters.Beam.RFSteel.NumBars*Rbar(barind,2);
            if Parameters.Beam.RFSteel.NumBars*(Rbar(barind,3)+2)+2<Parameters.Beam.bft
                Parameters.Beam.RFCenter = 2+Rbar(barind,3)/2;
            else
                row1 = floor((Parameters.Beam.bft-4)/(Rbar(barind,3)+2));
                row2 = Parameters.Beam.RFSteel.NumBars-row1;
                Parameters.Beam.RFCenter = (Rbar(barind,2)*row1*(2+Rbar(barind,3)/2)+Rbar(barind,2)*row2*(4+Rbar(barind,3)*3/2))/Parameters.Beam.RFSteel.A;
            end
        else
            Parameters.Beam.RFSteel.A = 0;
            Parameters.Beam.RFSteel.NumBars = 0;
        end
    end
end


end

