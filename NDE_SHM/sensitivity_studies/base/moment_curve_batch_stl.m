param_dir = uigetdir();
% Get filenames of all parameter files
dirData = dir([param_dir '\*.mat']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(10:end-4));
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

% Get model info for all models
for ii = 7:length(fileList)   
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
            data(ii).Beam = Parameters.Beam.Int.Type;
        end
        
        
        drop = min([find(diff(moment)<-1000,1,'first') length(curv)]);
        crush = find(-strain_y>=0.003,1,'first')-1;
        
        fail_mode = 'crushing';
                
        data(ii).crush_mom = interp1(strain_y(1:drop),moment(1:drop),-.003);
        data(ii).crush_curv = interp1(strain_y(1:drop),curv(1:drop)+sxn.init_curv,-.003);
        data(ii).LRFD_Mn_pos = Parameters.Beam.Int.Mn_pos;

        %% Plots
        limit_ind = min([drop+1 length(curv)]);
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
        plot(data(ii).crush_curv,data(ii).crush_mom,'o','color','black');
        line([1 1]*data(ii).crush_curv,[1.05 0.85]*data(ii).crush_mom,'color','black');
        line([curv(1)+sxn.init_curv 1.05*data(ii).crush_curv],data(ii).crush_mom*[1 1],'color','black');
        text(curv(1)+sxn.init_curv,data(ii).crush_mom,[num2str(data(ii).crush_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
        text(data(ii).crush_curv,data(ii).crush_mom*.9,[ 'Crushing' '\rightarrow'],'VerticalAlignment','bottom','HorizontalAlignment','right')
        xlim([0 curv(limit_ind)+sxn.init_curv])
        saveas(fh2,[param_dir '\img\' modelName '_mom-curv' '.jpeg']);
        close(fh2);

        fh3 = figure;
        plot(-strain_y, moment,'o-')
        xlabel 'Top fiber strain'
        ylabel 'Moment [lb-in]'
        hold all
        plot(0.003,data(ii).crush_mom,'o','color','black');
        line([0.003 0.003],[1.05 0.85]*data(ii).crush_mom,'color','black');
        line([-strain_y(1) 1.05*0.003],data(ii).crush_mom*[1 1],'color','black');
        text(-strain_y(1),data(ii).crush_mom,[num2str(data(ii).crush_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
        text(0.003,data(ii).crush_mom*.9,['Crushing Strain' '\rightarrow'],'VerticalAlignment','bottom','HorizontalAlignment','right')
        xlim([0 -strain_y(limit_ind)])
        saveas(fh3,[param_dir '\img\' modelName '_top-strain' '.jpeg']);
        close(fh3);
        


        
        fh4 = figure;
        plot(curv+sxn.init_curv,top_fiber-na,'o-')
        xlabel 'Curvature'
        ylabel 'Neutral Axis (distance below top of deck) [in]'
        xlim([0 curv(limit_ind)+sxn.init_curv])
        saveas(fh4,[param_dir '\img\' modelName '_NA' '.jpeg']);
        close(fh4);       
  
end
% for ii = 1:length(data.ModelName)
%     new_dat(ii).ModelName = data.ModelName{ii};
%     new_dat(ii).Beam = data.Beam{ii};
%     new_dat(ii).LRFD_Mn_pos = data.LRFD_Mn_pos(ii);
%      new_dat(ii).ult_mom = data(ii).crush_mom;
%         new_dat(ii).ult_curv = data(ii).crush_curv;
%         
% end
data_table = struct2table(data);
writetable(data_table,[user_dir '\ultimate_states.csv'])