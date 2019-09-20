param_dir = uigetdir();
% Get filenames of all parameter files
dirData = dir([param_dir '\*.mat']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(10:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

% Get model info for all models
for ii = 1:length(fileList)   
        % load parameters file
        modelName = fileList{ii};
        load([param_dir '\' modelName]);

        % populate bridge object with parameters file
        brdg = param2fiber(Parameters);

        % brdg.deck.rbar.density = 0.0868;
        % brdg.deck.rbar.size = 6;
        % brdg.deck.rbar.spacing = 6; % inches
        % brdg.deck.rbar.elev = 3; % inches
        % brdg.deck.rbar.num_bars = brdg.be/brdg.deck.rbar.spacing;

        %base moment curve
        sxn = section(brdg,0.5);

        dc = 1e-5; % curvature step size
        curv = (1:85)*dc; 
        top_fiber = max(brdg.girder.shape(:,2))+brdg.deck.t;
        init_na = [];
        clear moment na strain_y exitflag;
        for jj = 1:length(curv)
            sxn.curvature = curv(jj);
            [moment(jj), na(jj), ~, ~, strain_y(jj), exitflag(jj)] = sxn.mom_curv(top_fiber,init_na);
            init_na = na(jj);
        end
        
        data(ii).ModelName = modelName;
        if isfield(Parameters.Beam.Int,'SectionName')
            data(ii).Beam = Parameters.Beam.Int.SectionName;
        else
            data(ii).Beam = '';
        end
        
        data(ii).ult_mom = interp1(strain_y,moment,-.003);
        data(ii).ult_curv = interp1(strain_y,curv+sxn.init_curv,-.003);
        data(ii).LRFD_Mn_pos = Parameters.Beam.Mn_pos;

        %% Plots
%         figure
%         plot(sxn.coords(:,1),sxn.coords(:,2),'.')
        fh1 = brdg.plot_sxn;        
        text(0,top_fiber-Parameters.Deck.t/2,brdg.girder.name,'HorizontalAlignment','center')
        saveas(fh1,[param_dir '\img\' modelName '_sxn' '.jpeg']);
        close(fh1);
        
        fh2 = figure;
        plot(curv+sxn.init_curv,moment,'o-')
        xlabel 'Curvature'
        ylabel 'Moment [lb-in]'
        hold all
        plot(data.ult_curv(ii),data.ult_mom(ii),'o','color','black');
        line([1 1]*data.ult_curv(ii),[1.05 0.85]*data.ult_mom(ii),'color','black');
        line([curv(1)+sxn.init_curv 1.05*data.ult_curv(ii)],data.ult_mom(ii)*[1 1],'color','black');
        text(curv(1)+sxn.init_curv,data.ult_mom(ii),[num2str(data.ult_mom(ii),'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
        text(data.ult_curv(ii),data.ult_mom(ii)*.9,['\leftarrow' 'Crushing'],'VerticalAlignment','bottom')
        saveas(fh2,[param_dir '\img\' modelName '_mom-curv' '.jpeg']);
        close(fh2);

        fh3 = figure;
        plot(-strain_y, moment,'o-')
        xlabel 'Top fiber strain'
        ylabel 'Moment [lb-in]'
        hold all
        plot(0.003,data.ult_mom(ii),'o','color','black');
        line([0.003 0.003],[1.05 0.85]*data.ult_mom(ii),'color','black');
        line([-strain_y(1) 1.05*0.003],data.ult_mom(ii)*[1 1],'color','black');
        text(-strain_y(1),data.ult_mom(ii),[num2str(data.ult_mom(ii),'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
        text(0.003,data.ult_mom(ii)*.9,['\leftarrow' 'Crushing Strain'],'VerticalAlignment','bottom')
        saveas(fh3,[param_dir '\img\' modelName '_top-strain' '.jpeg']);
        close(fh3);

        
        fh4 = figure;
        plot(curv+sxn.init_curv,top_fiber-na,'o-')
        xlabel 'Curvature'
        ylabel 'Neutral Axis (distance below top of deck) [in]'
        saveas(fh4,[param_dir '\img\' modelName '_NA' '.jpeg']);
        close(fh4);       
  
end
% for ii = 1:length(data.ModelName)
%     new_dat(ii).ModelName = data.ModelName{ii};
%     new_dat(ii).Beam = data.Beam{ii};
%     new_dat(ii).LRFD_Mn_pos = data.LRFD_Mn_pos(ii);
%      new_dat(ii).ult_mom = data.ult_mom(ii);
%         new_dat(ii).ult_curv = data.ult_curv(ii);
%         
% end
data_table = struct2table(data);
writetable(data_table,[user_dir '\ultimate_states.csv'])