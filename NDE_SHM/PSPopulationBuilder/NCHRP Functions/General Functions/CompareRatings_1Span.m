% CompareRatings_1Span
clear 
clc

h = waitbar(0);

modelPath = 'L:\NCHRP Phase II\Pre-Stressed\1-Span\Suite 1\Model Files';
resultPath = 'L:\NCHRP Phase II\Pre-Stressed\1-Span\Suite 1\Extracted Result Files';

dirData = dir([modelPath '\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(10:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

for ii = 1:100
    
    waitbar(ii/length(fileList),h,['Bridge ' num2str(ii)])
    
    % Model Name
    mName = fileList{ii}(1:end-4);
    
    % Load Parameters
    load([modelPath '\Parameters\' mName '_Para.mat'])
    
    % Get St1 SLG rating
    St1Pos_SLGInt(ii,1) = Parameters.Rating.LRFD.SL.Int.St1.RFInv_pos;
    St1Pos_SLGExt(ii,1) = Parameters.Rating.LRFD.SL.Ext.St1.RFInv_pos;
    
    % Get Sv2 SLG rating
    Sv3Pos_SLGInt(ii,1) = Parameters.Rating.LRFD.SL.Int.Sv3.RFInv_pos;
    Sv3Pos_SLGExt(ii,1) = Parameters.Rating.LRFD.SL.Ext.Sv3.RFInv_pos;
    
    % Get Capacities
    St1PosCap_Int(ii,1) = Parameters.Beam.Capacity.Mn_pos; St1PosCap_Ext(ii,1) = Parameters.Beam.Capacity.Mn_pos;
    Sv3PosCap_Int(ii,1) = Parameters.Beam.Capacity.Fn_pos; Sv3PosCap_Ext(ii,1) = Parameters.Beam.Capacity.Fn_pos;
        
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
    % DL1_M1 + (DL2_M1-DL2_A*y)   
    DL_Int = DL1_M1([posLB1:posUB1 posLB2:posUB2],2:end-1)...
                + DL2_M1([posLB1:posUB1 posLB2:posUB2],2:end-1)...
                -(DL2_A([posLB1:posUB1 posLB2:posUB2],2:end-1)*y);
    % LL_M1 - LL_A*y
    LL_Int = LL_M1([posLB1:posUB1 posLB2:posUB2],2:end-1)...
                - (LL_A([posLB1:posUB1 posLB2:posUB2],2:end-1)*y);        
   
             
    % Exterior    
    % DL1_M1 + (DL2_M1-DL2_A*y)   
    DL_Ext = DL1_M1([posLB1:posUB1 posLB2:posUB2],[1 end])...
                + DL2_M1([posLB1:posUB1 posLB2:posUB2],[1 end])...
                -(DL2_A([posLB1:posUB1 posLB2:posUB2],[1 end])*y);
    % LL_M1 - LL_A*y
    LL_Ext = LL_M1([posLB1:posUB1 posLB2:posUB2],[1 end])...
                - (LL_A([posLB1:posUB1 posLB2:posUB2],[1 end])*y);
   
    
    % St1_Pos FE Rating Factors
    St1Pos_FEInt(ii,1) = min(min((St1PosCap_Int(ii,1) - 1.25*abs(DL_Int))./(1.75*abs(LL_Int))));
    St1Pos_FEExt(ii,1) = min(min((St1PosCap_Ext(ii,1) - 1.25*abs(DL_Ext))./(1.75*abs(LL_Ext))));
    
       
    %% Sv3 Positive moment region__________________________________________
    
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
       
    Sv3Pos_FEInt(ii,1) = min(min((Sv3PosCap_Int(ii,1) - 1.0*abs(DL_Int))./(0.8*abs(LL_Int))));
    Sv3Pos_FEExt(ii,1) = min(min((Sv3PosCap_Ext(ii,1) - 1.0*abs(DL_Ext))./(0.8*abs(LL_Ext))));
    
       
    %% Compare FE to SLG Ratings___________________________________________
    
    % Ratio of FE/SLG for St1 Pos
    St1Pos_Ratio(ii,1) = St1Pos_FEInt(ii,1)/St1Pos_SLGInt(ii,1); % Int = 1, Ext = 2
    St1Pos_Ratio(ii,2) = St1Pos_FEExt(ii,1)/St1Pos_SLGExt(ii,1);
    
    % Ratio of FE/SLG for Sv3 Pos
    Sv3Pos_Ratio(ii,1) = Sv3Pos_FEInt(ii,1)/Sv3Pos_SLGInt(ii,1);
    Sv3Pos_Ratio(ii,2) = Sv3Pos_FEExt(ii,1)/Sv3Pos_SLGExt(ii,1);
    
        
    clear Parameters DLResults LLResults
     
end

close(h)

%% HISTOGRAMS--------------------------------------------------------------

plotType = 'Hist';
SaveDir = 'E:\NCHRP Phase II\Steel\1-Span\Suite 1\RF';

% St1Pos SLG Ratings_______________________________________________________

% Labels
ah = [];
xlabels = {'Strength I Rating Factor'};
ylabels = {'pdf'};
titles = {'Single Line Girder'; 'Positive Strength I Rating Factor'}; 
shortTitles = 'SLG_Rating_St1Pos';
legends = {'Exterior Girder';'Interior Girder'};

% Plot Histogram
X = {St1Pos_SLGExt,St1Pos_SLGInt};
[fh,ph] = CreateHistogramPlot(X,'plotType','stair',...
    'plotMode','PDF','statline','median','errorbar', 'nbins',20);

% Format Figure
formatFig(fh, ah, ph, plotType, xlabels, ylabels, titles, legends)

% Save Fig
% printFig(fh, shortTitles, SaveDir, dtails);
saveas(fh, [SaveDir '\' shortTitles '.fig']) % Save Figure
saveas(fh, [SaveDir '\' shortTitles '.png']) % Save png


% Sv3Pos SLG Ratings_______________________________________________________

% Labels
ah = [];
xlabels = {'Service III Rating Factor'};
ylabels = {'pdf'};
titles = {'Single Line Girder'; 'Positive Service III Rating Factor'}; 
shortTitles = 'SLG_Rating_Sv2Pos';
legends = {'Exterior Girder';'Interior Girder'};

% Plot Histogram
X = {Sv2Pos_SLGExt,Sv2Pos_SLGInt};
[fh,ph] = CreateHistogramPlot(X,'plotType','stair',...
    'plotMode','PDF','statline','median','errorbar', 'nbins',20);

% Format Figure
formatFig(fh, ah, ph, plotType, xlabels, ylabels, titles, legends)

% Save Fig
% printFig(fh, shortTitles, SaveDir, dtails);
saveas(fh, [SaveDir '\' shortTitles '.fig']) % Save Figure
saveas(fh, [SaveDir '\' shortTitles '.png']) % Save png


% St1Pos FE Ratings________________________________________________________

% Labels
ah = [];
xlabels = {'Strength I Rating Factor'};
ylabels = {'pdf'};
titles = {'Finite Element';'Positive Strength I Rating Factor'}; 
shortTitles = 'FE_Rating_St1Pos';
legends = {'Exterior Girder';'Interior Girder'};

% Plot Histogram
X = {St1Pos_FEExt,St1Pos_FEInt};
[fh,ph] = CreateHistogramPlot(X,'plotType','stair',...
    'plotMode','PDF','statline','median','errorbar', 'nbins',20);

% Format Figure
formatFig(fh, ah, ph, plotType, xlabels, ylabels, titles, legends)

% Save Fig
% printFig(fh, shortTitles, SaveDir, dtails);
saveas(fh, [SaveDir '\' shortTitles '.fig']) % Save Figure
saveas(fh, [SaveDir '\' shortTitles '.png']) % Save png

% Sv3Pos FE Ratings________________________________________________________

% Labels
ah = [];
xlabels = {'Service III Rating Factor'};
ylabels = {'pdf'};
titles = {'Finite Element';'Positive Service III Rating Factor'}; 
shortTitles = 'FE_Rating_Sv2Pos';
legends = {'Exterior Girder';'Interior Girder'};

% Plot Histogram
X = {Sv2Pos_FEExt,Sv2Pos_FEInt};
[fh,ph] = CreateHistogramPlot(X,'plotType','stair',...
    'plotMode','PDF','statline','median','errorbar', 'nbins',20);

% Format Figure
formatFig(fh, ah, ph, plotType, xlabels, ylabels, titles, legends)

% Save Fig
% printFig(fh, shortTitles, SaveDir, dtails);
saveas(fh, [SaveDir '\' shortTitles '.fig']) % Save Figure
saveas(fh, [SaveDir '\' shortTitles '.png']) % Save png


% St1Pos FE/SLG Ratio______________________________________________________

% Labels
ah = [];
xlabels = {'Ratio of Strength I FE to SLG Rating Factor'};
ylabels = {'pdf'};
titles = {'Ratio of Positive Strength I FE to SLG Rating Factors'}; 
shortTitles = 'FEtoSLG_Ratio_St1Pos';
legends = {'Exterior Girder';'Interior Girder'};

% Plot Histogram
X = {St1Pos_Ratio(:,2),St1Pos_Ratio(:,1)}; % Int = 1, Ext = 2
[fh,ph] = CreateHistogramPlot(X,'plotType','stair',...
    'plotMode','PDF','statline','median','errorbar', 'nbins',20);

% Format Figure
formatFig(fh, ah, ph, plotType, xlabels, ylabels, titles, legends)

% Save Fig
% printFig(fh, shortTitles, SaveDir, dtails);
saveas(fh, [SaveDir '\' shortTitles '.fig']) % Save Figure
saveas(fh, [SaveDir '\' shortTitles '.png']) % Save png

% Sv3Pos FE/SLG Ratio______________________________________________________

% Labels
ah = [];
xlabels = {'Ratio of Service III FE to SLG Rating Factor'};
ylabels = {'pdf'};
titles = {'Ratio of Positive Service III FE to SLG Rating Factors'}; 
shortTitles = 'FEtoSLG_Ratio_Sv2Pos';
legends = {'Exterior Girder';'Interior Girder'};

% Plot Histogram
X = {Sv2Pos_Ratio(:,2),Sv2Pos_Ratio(:,1)}; % Int = 1, Ext = 2
[fh,ph] = CreateHistogramPlot(X,'plotType','stair',...
    'plotMode','PDF','statline','median','errorbar', 'nbins',20);

% Format Figure
formatFig(fh, ah, ph, plotType, xlabels, ylabels, titles, legends)

% Save Fig
% printFig(fh, shortTitles, SaveDir, dtails);
saveas(fh, [SaveDir '\' shortTitles '.fig']) % Save Figure
saveas(fh, [SaveDir '\' shortTitles '.png']) % Save png


