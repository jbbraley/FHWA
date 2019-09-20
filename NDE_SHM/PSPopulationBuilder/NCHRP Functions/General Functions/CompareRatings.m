% CompareRatings
clear 
clc

h = waitbar(0);

modelPath = 'C:\Users\Nick\Documents\Projects\NCHRP - Phase II\Steel\2-Span\Suite 1';
resultPath = 'E:\NCHRP Phase II\Steel\2-Span\Suite 1\Extracted Result Files';

dirData = dir([modelPath '\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(8:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

for ii = 1:50%100
    
    waitbar(ii/length(fileList),h,['Bridge ' num2str(ii)])
    
    % Model Name
    mName = fileList{ii}(1:end-4);
    
    % Load Parameters
    load([modelPath '\Parameters\' mName '_Para.mat'])
    
    % Get St1 SLG rating
    St1Pos_SLGInt(ii,1) = Parameters.Rating.LRFD.SL.Int.St1.RFInv_pos;
    St1Neg_SLGInt(ii,1) = Parameters.Rating.LRFD.SL.Int.St1.RFInv_neg;
    St1Pos_SLGExt(ii,1) = Parameters.Rating.LRFD.SL.Ext.St1.RFInv_pos;
    St1Neg_SLGExt(ii,1) = Parameters.Rating.LRFD.SL.Ext.St1.RFInv_neg;
    
    % Get Sv2 SLG rating
    Sv2Pos_SLGInt(ii,1) = Parameters.Rating.LRFD.SL.Int.Sv2.RFInv_pos;
    Sv2Neg_SLGInt(ii,1) = Parameters.Rating.LRFD.SL.Int.Sv2.RFInv_neg;
    Sv2Pos_SLGExt(ii,1) = Parameters.Rating.LRFD.SL.Ext.Sv2.RFInv_pos;
    Sv2Neg_SLGExt(ii,1) = Parameters.Rating.LRFD.SL.Ext.Sv2.RFInv_neg;
    
    % Get Capacities
    St1PosCap_Int(ii,1) = Parameters.Beam.Int.Mn_pos; St1PosCap_Ext(ii,1) = Parameters.Beam.Ext.Mn_pos;
    St1NegCap_Int(ii,1) = Parameters.Beam.Int.Fn_neg; St1NegCap_Ext(ii,1) = Parameters.Beam.Ext.Fn_neg;
    Sv2PosCap_Int(ii,1) = 0.95*Parameters.Beam.Int.Fn_pos; Sv2PosCap_Ext(ii,1) = 0.95*Parameters.Beam.Ext.Fn_pos;
    Sv2NegCap_Int(ii,1) = 0.80*Parameters.Beam.Int.Fn_pos; Sv2NegCap_Ext(ii,1) = 0.80*Parameters.Beam.Ext.Fn_pos;
        
    % Load Dead Load Results
    load([resultPath '\Dead Load\A1\' mName '_A1_DLResults.mat']);
    
    % DL1, DL2
    DL1_M1 = DLResults(1).DL_M1; DL2_M1 = DLResults(2).DL_M1;
    DL1_M2 = DLResults(1).DL_M2; DL2_M2 = DLResults(2).DL_M2;
    DL1_A = DLResults(1).DL_A;   DL2_A = DLResults(2).DL_A;
    DL1s_b = DLResults(1).DLs_b;   DL2s_b = DLResults(2).DLs_b;

    % Load Live Load Results
    load([resultPath '\Live Load\A1\Barriers Off\' mName '_A1_Off_LLResults.mat']);
    
    % LL
    LL_M1 = LLResults.LL_M1;
    LL_M2 = LLResults.LL_M2;
    LL_A = LLResults.LL_A;
    LLs_b = LLResults.LLs_b;
    
    % Window locations of interest
    posLB1 = round(0.15*length(LLResults.LL_M1));
    posUB1 = round(0.3*length(LLResults.LL_M1));
    posLB2 = round(0.7*length(LLResults.LL_M1));
    posUB2 = round(0.85*length(LLResults.LL_M1));
    negLB = round(0.45*length(LLResults.LL_M1));
    negUB = round(0.55*length(LLResults.LL_M1));
    
    % Moment arm
    y = (Parameters.Beam.Int.d/2) + (Parameters.Deck.t/2);
    
    
    %% St1 Positive moment region__________________________________________
    
    % Interior
    if Parameters.Beam.Int.SectionComp % If section is compact, use moment
        % DL1_M1 + (DL2_M1-DL2_A*y)   
        DL_Int = DL1_M1([posLB1:posUB1 posLB2:posUB2],2:end-1)...
                    + DL2_M1([posLB1:posUB1 posLB2:posUB2],2:end-1)...
                    -(DL2_A([posLB1:posUB1 posLB2:posUB2],2:end-1)*y);
        % LL_M1 - LL_A*y
        LL_Int = LL_M1([posLB1:posUB1 posLB2:posUB2],2:end-1)...
                    + (LL_A([posLB1:posUB1 posLB2:posUB2],2:end-1)*y);        
    else
        % DL1s_b + DL2s_b
        DL_Int = DL1s_b([posLB1:posUB1 posLB2:posUB2],2:end-1)...
                    + DL2s_b([posLB1:posUB1 posLB2:posUB2],2:end-1);
        % LLs_b
        LL_Int = LLs_b([posLB1:posUB1 posLB2:posUB2],2:end-1);
    end
         
    % Exterior
    if Parameters.Beam.Ext.SectionComp % If section is compact, use moment
        % DL1_M1 + (DL2_M1-DL2_A*y)   
        DL_Ext = DL1_M1([posLB1:posUB1 posLB2:posUB2],[1 end])...
                    + DL2_M1([posLB1:posUB1 posLB2:posUB2],[1 end])...
                    -(DL2_A([posLB1:posUB1 posLB2:posUB2],[1 end])*y);
        % LL_M1 - LL_A*y
        LL_Ext = LL_M1([posLB1:posUB1 posLB2:posUB2],[1 end])...
                    + (LL_A([posLB1:posUB1 posLB2:posUB2],[1 end])*y);
    else
        % DL1s_b + DL2s_b
        DL_Ext = DL1s_b([posLB1:posUB1 posLB2:posUB2],[1 end])...
                    + DL2s_b([posLB1:posUB1 posLB2:posUB2],[1 end]);
        % LLs_b
        LL_Ext = LLs_b([posLB1:posUB1 posLB2:posUB2],[1 end]);
    end
    
    % Log if pos section is comapct or non-compact
    CompCheck(ii,1) = Parameters.Beam.Int.SectionComp;
    CompCheck(ii,2) = Parameters.Beam.Ext.SectionComp;

    % St1_Pos FE Rating Factors
    St1Pos_FEInt(ii,1) = min(min((St1PosCap_Int(ii,1) - 1.25*abs(DL_Int))./(1.75*abs(LL_Int))));
    St1Pos_FEExt(ii,1) = min(min((St1PosCap_Ext(ii,1) - 1.25*abs(DL_Ext))./(1.75*abs(LL_Ext))));
    
    %% St1 Negative moment region__________________________________________
    
    % Interior DL1s_b + DL2s_b
    DL_Int = DL1s_b(negLB:negUB,2:end-1)...
           + DL2s_b(negLB:negUB,2:end-1);
    % Interior LLs_b
    LL_Int = LLs_b(negLB:negUB,2:end-1);
    
    % Exterior DL1s_b + DL2s_b
    DL_Ext = DL1s_b(negLB:negUB,[1 end])...
           + DL2s_b(negLB:negUB,[1 end]);
    % Exterior LLs_b
    LL_Ext = LLs_b(negLB:negUB,[1 end]);
    
    % St1_Pos FE Rating Factors
    St1Neg_FEInt(ii,1) = min(min((St1NegCap_Int(ii,1) - 1.25*abs(DL_Int))./(1.75*abs(LL_Int))));
    St1Neg_FEExt(ii,1) = min(min((St1NegCap_Ext(ii,1) - 1.25*abs(DL_Ext))./(1.75*abs(LL_Ext))));
    
   
    %% Sv2 Positive moment region__________________________________________
    
    % Interior DL1s_b + DL2s_b
    DL_Int = DL1s_b([posLB1:posUB1 posLB2:posUB2],2:end-1)...
           + DL2s_b([posLB1:posUB1 posLB2:posUB2],2:end-1);
    % Interior LLs_b
    LL_Int = LLs_b([posLB1:posUB1 posLB2:posUB2],2:end-1);
    
    % Exterior DL1s_b + DL2s_b
    DL_Ext = DL1s_b([posLB1:posUB1 posLB2:posUB2],[1 end])...
           + DL2s_b([posLB1:posUB1 posLB2:posUB2],[1 end]);
    % Exterior LLs_b
    LL_Ext = LLs_b([posLB1:posUB1 posLB2:posUB2],[1 end]);
       
    Sv2Pos_FEInt(ii,1) = min(min((Sv2PosCap_Int(ii,1) - 1.0*abs(DL_Int))./(1.3*abs(LL_Int))));
    Sv2Pos_FEExt(ii,1) = min(min((Sv2PosCap_Ext(ii,1) - 1.0*abs(DL_Ext))./(1.3*abs(LL_Ext))));
    
    %% Sv2 Negative moment region__________________________________________

    % Interior DL1s_b + DL2s_b
    DL_Int = DL1s_b(negLB:negUB,2:end-1)...
           + DL2s_b(negLB:negUB,2:end-1);
    % Interior LLs_b
    LL_Int = LLs_b(negLB:negUB,2:end-1);
    
    % Exterior DL1s_b + DL2s_b
    DL_Ext = DL1s_b(negLB:negUB,[1 end])...
           + DL2s_b(negLB:negUB,[1 end]);
    % Exterior LLs_b
    LL_Ext = LLs_b(negLB:negUB,[1 end]);
    
    % St1_Pos FE Rating Factors
    Sv2Neg_FEInt(ii,1) = min(min((Sv2NegCap_Int(ii,1) - 1.0*abs(DL_Int))./(1.3*abs(LL_Int))));
    Sv2Neg_FEExt(ii,1) = min(min((Sv2NegCap_Ext(ii,1) - 1.0*abs(DL_Ext))./(1.3*abs(LL_Ext))));
    
    %% Compare FE to SLG Ratings___________________________________________
    
    % Ratio of FE/SLG for St1 Pos
    St1Pos_Ratio(ii,1) = St1Pos_FEInt(ii,1)/St1Pos_SLGInt(ii,1);
    St1Pos_Ratio(ii,2) = St1Pos_FEExt(ii,1)/St1Pos_SLGExt(ii,1);
    
    % Ratio of FE/SLG for St1 Neg
    St1Neg_Ratio(ii,1) = St1Neg_FEInt(ii,1)/St1Neg_SLGInt(ii,1);
    St1Neg_Ratio(ii,2) = St1Neg_FEExt(ii,1)/St1Neg_SLGExt(ii,1);
    
    % Ratio of FE/SLG for Sv2 Pos
    Sv2Pos_Ratio(ii,1) = Sv2Pos_FEInt(ii,1)/Sv2Pos_SLGInt(ii,1);
    Sv2Pos_Ratio(ii,2) = Sv2Pos_FEExt(ii,1)/Sv2Pos_SLGExt(ii,1);
    
    % Ratio of FE/SLG for Sv2 Neg
    Sv2Neg_Ratio(ii,1) = Sv2Neg_FEInt(ii,1)/Sv2Neg_SLGInt(ii,1);
    Sv2Neg_Ratio(ii,2) = Sv2Neg_FEExt(ii,1)/Sv2Neg_SLGExt(ii,1);
 
    
    clear Parameters DLResults LLResults
     

    
end