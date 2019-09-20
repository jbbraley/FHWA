param_dir = uigetdir();
% Get filenames of all parameter files
dirData = dir([param_dir '\*.mat']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(10:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

% Get model info for all models
for ii = 4:length(fileList)   
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
        strand_elev = 2;
        top_fiber = max(brdg.girder.shape(:,2))+brdg.deck.t;
        init_na = [];
        clear moment na strain_y exitflag;
        for jj = 1:length(curv)
            sxn.curvature = curv(jj);
            [moment(jj), na(jj), ~, ~, strain_y(jj,:), exitflag(jj)] = sxn.mom_curv([top_fiber strand_elev],init_na);
            init_na = na(jj);
        end
        
        data(ii).ModelName = modelName;
        if isfield(Parameters.Beam.Int,'SectionName')
            data(ii).Beam = Parameters.Beam.Int.SectionName;
        else
            data(ii).Beam = Parameters.Beam.Name;
        end
        
        
        rupture = find(strain_y(:,2)+sxn.fibers{end}.init_strain>=0.04,1,'first')-1;
        crush = find(-strain_y(:,1)>=0.003,1,'first')-1;
        drop = find(diff(moment)<0,1,'first');
        
        if ~isempty(crush) && crush<rupture
            fail_mode = 'crushing';
        else
            fail_mode = 'rupture';
        end
        
        data(ii).fail_mode = fail_mode;
        data(ii).strand_yield_mom = interp1(strain_y(1:rupture,2)+sxn.fibers{end}.init_strain,moment(1:rupture),.0086,'linear','extrap');
        
        data(ii).strand_rupture_mom = interp1(strain_y(1:rupture,2)+sxn.fibers{end}.init_strain,moment(1:rupture),.04,'linear','extrap');
        data(ii).crush_mom = interp1(strain_y(1:rupture,1),moment(1:rupture),-.003);
        
        data(ii).rupture_curv = interp1(strain_y(1:rupture,2)+sxn.fibers{end}.init_strain,curv(1:rupture)+sxn.init_curv,.04,'linear','extrap');
        data(ii).crush_curv = interp1(strain_y(1:rupture,1),curv(1:rupture)+sxn.init_curv,-.003);
        data(ii).LRFD_Mn_pos = Parameters.Beam.Mn_pos;

        %% Plots
%         figure
%         plot(sxn.coords(:,1),sxn.coords(:,2),'.')
        limit_ind = drop+1;
        
        fh1 = brdg.plot_sxn;        
        text(0,top_fiber-Parameters.Deck.t/2,brdg.girder.name,'HorizontalAlignment','center')
        saveas(fh1,[param_dir '\img\' modelName '_sxn' '.jpeg']);
        close(fh1);
        
        fh2 = figure;
        plot(curv(1:limit_ind)+sxn.init_curv,moment(1:limit_ind),'o-') %plot(curv+sxn.init_curv,moment,'o-')
        xlabel 'Curvature'
        ylabel 'Moment [lb-in]'
        hold all
        if strcmp(fail_mode,'rupture')
            plot(data(ii).ult_curv,data(ii).strand_rupture_mom,'o','color','black');
            line([1 1]*data(ii).ult_curv,[1.05 0.85]*data(ii).strand_rupture_mom,'color','black');
            line([curv(10)+sxn.init_curv 1.05*data(ii).ult_curv],data(ii).strand_rupture_mom*[1 1],'color','black');
            text(curv(10)+sxn.init_curv,data(ii).strand_rupture_mom,[num2str(data(ii).strand_rupture_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
            text(data(ii).ult_curv,data(ii).strand_rupture_mom*.9,['Strand Rupture' '\rightarrow'],'VerticalAlignment','bottom','HorizontalAlignment','right')
        else   %~isempty(data(ii).crush_mom) && ~isnan(data(ii).crush_mom)
             plot(data(ii).crush_curv,data(ii).crush_mom,'o','color','black');
            line([1 1]*data(ii).crush_curv,[1.05 0.93]*data(ii).crush_mom,'color','black');
            line([curv(1)+sxn.init_curv 1.05*data(ii).crush_curv],data(ii).crush_mom*[1 1],'color','black');
            text(curv(1)+sxn.init_curv,data(ii).crush_mom,[num2str(data(ii).crush_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
            text(data(ii).crush_curv,data(ii).crush_mom*.95,['Crushing' '\rightarrow'],'VerticalAlignment','bottom','HorizontalAlignment','right')
        end
        saveas(fh2,[param_dir '\img\' modelName '_mom-curv' '.jpeg']);
        close(fh2);

        fh3 = figure;
        plot(strain_y((1:limit_ind),2)+sxn.fibers{end}.init_strain, moment(1:limit_ind),'o-')
        xlabel 'Extreme Tendon Strain'
        ylabel 'Moment [lb-in]'
        hold all
        if strcmp(fail_mode,'rupture')
            plot(0.04,data(ii).strand_rupture_mom,'o','color','black');
            line([0.04 0.04],[1.05 0.85]*data(ii).strand_rupture_mom,'color','black');
            line([strain_y(10,2)+sxn.fibers{end}.init_strain 1.05*0.04],data(ii).strand_rupture_mom*[1 1],'color','black');
            text(strain_y(10,2)+sxn.fibers{end}.init_strain,data(ii).strand_rupture_mom,[num2str(data(ii).strand_rupture_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
            text(0.04,data(ii).strand_rupture_mom*.9,['Rupture Strain' '\rightarrow'],'VerticalAlignment','bottom','HorizontalAlignment','right')
        end
        plot(.0086,data(ii).strand_yield_mom,'o','color','black');
        line([0.0086 0.0086],[1.05 0.85]*data(ii).strand_yield_mom,'color','black');
        line([strain_y(1,2)+sxn.fibers{end}.init_strain 2.5*0.0086],data(ii).strand_yield_mom*[1 1],'color','black');
        text(2.4*0.0086,data(ii).strand_yield_mom,[num2str(data(ii).strand_yield_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','right')        
        text(0.0086,data(ii).strand_yield_mom*.9,['\leftarrow' 'Yield Strain' ],'VerticalAlignment','bottom','HorizontalAlignment','left')
        
       saveas(fh3,[param_dir '\img\' modelName '_strand-strain' '.jpeg']);
        close(fh3);
        
        fh5 = figure;
        plot(-strain_y((1:limit_ind),1), moment(1:limit_ind),'o-')
        xlabel 'Top fiber strain'
        ylabel 'Moment [lb-in]'
        hold all
        if strcmp(fail_mode,'crushing')
            plot(0.003,data(ii).crush_mom,'o','color','black');
            line([0.003 0.003],[1.05 0.85]*data(ii).crush_mom,'color','black');
            line([-strain_y(1) 1.05*0.003],data(ii).crush_mom*[1 1],'color','black');
            text(-strain_y(1),data(ii).crush_mom,[num2str(data(ii).crush_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
            text(0.003,data(ii).crush_mom*.9,['Crushing Strain' '\rightarrow'],'VerticalAlignment','bottom','HorizontalAlignment','right')
        end
%         xlim([0  -strain_y(rupture,1)]);
        saveas(fh5,[param_dir '\img\' modelName '_top-strain' '.jpeg']);
        close(fh5);


        
        fh4 = figure;
        plot(curv(1:limit_ind)+sxn.init_curv,top_fiber-na(1:limit_ind),'o-')
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
writetable(data_table,[param_dir '\ultimate_states.csv'])