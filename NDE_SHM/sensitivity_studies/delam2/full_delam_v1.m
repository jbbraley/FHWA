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
    
    % results locations
    strand_elev = 2;
    top_fiber = max(brdg.girder.shape(:,2))+brdg.deck.t;
    bottom_fiber = 0;
    if strcmp(brdg.girder.type, 'PS')
        result_elev = [top_fiber strand_elev bottom_fiber];
    else
        result_elev = top_fiber;
    end

    % loop through sections with decreasing deck thickness (to account for
    % full-width delamination
    clear moment strain_y exitflag
    
    deck_t = 8:-0.5:4;
    
    for kk = 1:length(deck_t)
        brdg.deck.t = deck_t(kk);
        sxn = section(brdg,0.5);

        dc = 1e-5; % curvature step size
        curv = (1:85)*dc; 
        
        init_na = [];
        clear na
        for jj = 1:length(curv)
            sxn.curvature = curv(jj);
            [moment(jj,kk), na(jj), ~, ~, strain_y(jj,kk,:), exitflag(jj,kk)] = sxn.mom_curv(result_elev,init_na);
            total_curv(jj,kk) = sxn.total_curvature;
            init_na = na(jj);
        end
                
        % first drop in moment (or end)
        drop = min([find(diff(moment)<-1000,1,'first') length(curv)]);
        crush = min([find(-strain_y(:,1)>=0.003,1,'first')-1 length(curv)]);   
        
        if strcmp(Parameters.Beam.Type,'PS')        
            rupture = min([find(strain_y(:,kk,2)+sxn.fibers{end}.init_strain>=0.04,1,'first')-1 length(curv)]);
            bottom_crack = find(-strain_y(:,kk,3)>0,1,'first')-1;
            data(ii,kk).crak_mom = interp1(strain_y(1:bottom_crack,kk,3),moment(1:bottom_crack,kk),0);
        end      
             
        if strcmp(Parameters.Beam.Type,'PS') && rupture<crush
            data(ii,kk).fail_mode = 'rupture';
            data(ii,kk).ult_mom = interp1(strain_y(1:rupture,kk,2),moment(1:rupture,kk),.04,'linear','extrap');
            data(ii,kk).ult_curv = interp1(strain_y(1:rupture,kk,2)+sxn.fibers{end}.init_strain, total_curv(1:rupture,kk),.04,'linear','extrap');
        else
            data(ii,kk).fail_mode = 'crushing';
            data(ii,kk).ult_mom = interp1(strain_y(1:crush,kk,1),moment(1:crush,kk),-.003,'linear','extrap');
            data(ii,kk).ult_curv = interp1(strain_y(1:crush,kk,1),total_curv(1:rupture,kk),-.003,'linear','extrap');
        end
            
    end
    
    %convert structure to table
    data_table = struct2table(data(ii,:));
    
    % plot
    limit_ind = drop+1;
    
    fh1 = figure;
    plot(total_curv,moment,'o-') %plot(curv+sxn.init_curv,moment,'o-')
    xlabel 'Curvature'
    ylabel 'Moment [lb-in]'
    hold all
    plot(data_table.ult_curv,data_table.ult_mom,'o','color','black');
    saveas(fh2,[param_dir '\img\' modelName '_mom-curv' '.jpeg']);
    close(fh2);

    
    writetable(data_table,[param_dir  '\full-delam_' modelName '.csv'])

%         %% Plots
% %         figure
% %         plot(sxn.coords(:,1),sxn.coords(:,2),'.')
%         limit_ind = drop+1;
%                 
%         fh2 = figure;
%         plot(curv(1:limit_ind)+sxn.init_curv,moment(1:limit_ind),'o-') %plot(curv+sxn.init_curv,moment,'o-')
%         xlabel 'Curvature'
%         ylabel 'Moment [lb-in]'
%         hold all
%         if strcmp(fail_mode,'rupture')
%             plot(data(ii).ult_curv,data(ii).strand_rupture_mom,'o','color','black');
%             line([1 1]*data(ii).ult_curv,[1.05 0.85]*data(ii).strand_rupture_mom,'color','black');
%             line([curv(10)+sxn.init_curv 1.05*data(ii).ult_curv],data(ii).strand_rupture_mom*[1 1],'color','black');
%             text(curv(10)+sxn.init_curv,data(ii).strand_rupture_mom,[num2str(data(ii).strand_rupture_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
%             text(data(ii).ult_curv,data(ii).strand_rupture_mom*.9,['Strand Rupture' '\rightarrow'],'VerticalAlignment','bottom','HorizontalAlignment','right')
%         else   %~isempty(data(ii).crush_mom) && ~isnan(data(ii).crush_mom)
%              plot(data(ii).crush_curv,data(ii).crush_mom,'o','color','black');
%             line([1 1]*data(ii).crush_curv,[1.05 0.93]*data(ii).crush_mom,'color','black');
%             line([curv(1)+sxn.init_curv 1.05*data(ii).crush_curv],data(ii).crush_mom*[1 1],'color','black');
%             text(curv(1)+sxn.init_curv,data(ii).crush_mom,[num2str(data(ii).crush_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
%             text(data(ii).crush_curv,data(ii).crush_mom*.95,['Crushing' '\rightarrow'],'VerticalAlignment','bottom','HorizontalAlignment','right')
%         end
%         saveas(fh2,[param_dir '\img\' modelName '_mom-curv' '.jpeg']);
%         close(fh2);
% 
%         fh3 = figure;
%         plot(strain_y((1:limit_ind),2)+sxn.fibers{end}.init_strain, moment(1:limit_ind),'o-')
%         xlabel 'Extreme Tendon Strain'
%         ylabel 'Moment [lb-in]'
%         hold all
%         if strcmp(fail_mode,'rupture')
%             plot(0.04,data(ii).strand_rupture_mom,'o','color','black');
%             line([0.04 0.04],[1.05 0.85]*data(ii).strand_rupture_mom,'color','black');
%             line([strain_y(10,2)+sxn.fibers{end}.init_strain 1.05*0.04],data(ii).strand_rupture_mom*[1 1],'color','black');
%             text(strain_y(10,2)+sxn.fibers{end}.init_strain,data(ii).strand_rupture_mom,[num2str(data(ii).strand_rupture_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
%             text(0.04,data(ii).strand_rupture_mom*.9,['Rupture Strain' '\rightarrow'],'VerticalAlignment','bottom','HorizontalAlignment','right')
%         end
%         plot(.0086,data(ii).strand_yield_mom,'o','color','black');
%         line([0.0086 0.0086],[1.05 0.85]*data(ii).strand_yield_mom,'color','black');
%         line([strain_y(1,2)+sxn.fibers{end}.init_strain 2.5*0.0086],data(ii).strand_yield_mom*[1 1],'color','black');
%         text(2.4*0.0086,data(ii).strand_yield_mom,[num2str(data(ii).strand_yield_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','right')        
%         text(0.0086,data(ii).strand_yield_mom*.9,['\leftarrow' 'Yield Strain' ],'VerticalAlignment','bottom','HorizontalAlignment','left')
%         
%        saveas(fh3,[param_dir '\img\' modelName '_strand-strain' '.jpeg']);
%         close(fh3);
%         
%         fh5 = figure;
%         plot(-strain_y((1:limit_ind),1), moment(1:limit_ind),'o-')
%         xlabel 'Top fiber strain'
%         ylabel 'Moment [lb-in]'
%         hold all
%         if strcmp(fail_mode,'crushing')
%             plot(0.003,data(ii).crush_mom,'o','color','black');
%             line([0.003 0.003],[1.05 0.85]*data(ii).crush_mom,'color','black');
%             line([-strain_y(1) 1.05*0.003],data(ii).crush_mom*[1 1],'color','black');
%             text(-strain_y(1),data(ii).crush_mom,[num2str(data(ii).crush_mom,'%.3e') ' [lb-in]'],'VerticalAlignment','bottom','HorizontalAlignment','left')        
%             text(0.003,data(ii).crush_mom*.9,['Crushing Strain' '\rightarrow'],'VerticalAlignment','bottom','HorizontalAlignment','right')
%         end
% %         xlim([0  -strain_y(rupture,1)]);
%         saveas(fh5,[param_dir '\img\' modelName '_top-strain' '.jpeg']);
%         close(fh5);
% 
% 
%         
%         fh4 = figure;
%         plot(curv(1:limit_ind)+sxn.init_curv,top_fiber-na(1:limit_ind),'o-')
%         xlabel 'Curvature'
%         ylabel 'Neutral Axis (distance below top of deck) [in]'
%         saveas(fh4,[param_dir '\img\' modelName '_NA' '.jpeg']);
%         close(fh4);       
%   
end
% for ii = 1:length(data.ModelName)
%     new_dat(ii).ModelName = data.ModelName{ii};
%     new_dat(ii).Beam = data.Beam{ii};
%     new_dat(ii).LRFD_Mn_pos = data.LRFD_Mn_pos(ii);
%      new_dat(ii).ult_mom = data.ult_mom(ii);
%         new_dat(ii).ult_curv = data.ult_curv(ii);
%         
% end
