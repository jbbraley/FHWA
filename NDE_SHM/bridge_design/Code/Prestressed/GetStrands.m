function [NumStrands, Dia, Parameters, exitflag] = GetStrands(Parameters)
%% GetStrands
% 
% 
% 
% author: 
% create date: 04-Sep-2019 15:28:22
	
%% 7 Wire Strand diam. & area
DA(:,1) = [.250 .313 .375 .438 .500 .520 .563 .600 .700]';
DA(:,2) = [.036 .058 .085 .115 .153 .167 .192 .217 .294]';

%% Find number of strands necessary for each diameter
exitflag = 0;

DiaStart = 8; %Parameters.Beam.DiaStart;
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
%         if c(2)> 0
%             break
%         end
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
        

        
%         C(:,j) = c;
 
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
    else
        NumStrands = [];
        Dia = [];
    end
end	
	
	
	
end
