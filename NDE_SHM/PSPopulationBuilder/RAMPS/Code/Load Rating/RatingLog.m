function RatingLog(Parameters,Data,fname,saveloc,Code)

%% Creates a log text file with the rating factors at various locations on the bridge
fid = fopen([saveloc fname '_RF-' Code '.txt'],'wt');
fprintf(fid,'\nRating Factors for model: %s on %s \n\n', char(fname), datestr(clock, 'mm.dd.yyyy'));
fprintf(fid, ['Rating Code:  ' Code '\n\n']);

switch Parameters.structureType
    case 'Steel'
        switch Code
            case 'LRFD'
                LimitState = ['St1'; 'Sv2'];
            case 'ASD'
                LimitState = 'St1';
        end
    case 'Prestressed'
        LimitState = ['St1'; 'Sv3'];
end
for mm = 1:size(LimitState,1)
    count = 1;
    for ii = 1:Parameters.Spans

        if strcmp(LimitState(mm,:),'St1')
            fprintf(fid,'Limit State Strength 1 Load Rating Factors\n\n');
        else
            fprintf(fid, ['Limit State Service ' LimitState(2,end) ' Load Rating Factors\n\n']);
        end
        if ii==(Parameters.Spans+1)/2
            Loc = 0.5;
        else
            Loc = 0.4;
        end
        fprintf(fid,'Location %i: Span %i at %g%% of span length...........................................\n\n',count,ii,Loc*100);
        count = count+1;
        fprintf(fid,'Girder:\t\t');
        for jj=1:Parameters.NumGirder
            fprintf(fid,'#%i \t\t',jj);
        end
        try
        fprintf(fid,'\n\n\nInv\t\t');
        for jj=1:Parameters.NumGirder
            switch jj
                case 1
                    Factor = min(Data.Ext.(LimitState(mm,:)).RatingFactors_Inv(1,2*ii-1,:),[],3);
                case Parameters.NumGirder
                    Factor = min(Data.Ext.(LimitState(mm,:)).RatingFactors_Inv(end,2*ii-1,:),[],3);
                otherwise
                    Factor = min(Data.Int.(LimitState(mm,:)).RatingFactors_Inv(jj-1,2*ii-1,:),[],3);
            end
            fprintf(fid,'%f\t',Factor);
        end
        catch 
            if ii==1
            fprintf(fid,'\tNot Applicable for this Limit State');
            end
        end
        try
        fprintf(fid,'\n\nOp\t\t');
        for jj=1:Parameters.NumGirder
            switch jj
                case 1
                    Factor = min(Data.Ext.(LimitState(mm,:)).RatingFactors_Op(1,2*ii-1,:),[],3);
                case Parameters.NumGirder
                    Factor = min(Data.Ext.(LimitState(mm,:)).RatingFactors_Op(end,2*ii-1,:),[],3);
                otherwise
                    Factor = min(Data.Int.(LimitState(mm,:)).RatingFactors_Op(jj-1,2*ii-1,:),[],3);
            end
            fprintf(fid,'%f\t',Factor);
        end
        catch
            if ii==1
            fprintf(fid,'\tNot Applicable for this Limit State');
            end
        end
        fprintf(fid,'\n\n\n');
    end

    for ii=1:Parameters.Spans-1
        fprintf(fid,'Location %i: Pier %i (Over Support).................................................\n\n',count,ii);
        count = count+1;
        fprintf(fid,'Girder:\t\t');
        for jj=1:Parameters.NumGirder
            fprintf(fid,'#%i \t\t',jj);
        end
        try
        fprintf(fid,'\n\n\nInv\t\t');
        for jj=1:Parameters.NumGirder
            switch jj
                case 1
                    Factor = min(Data.Ext.(LimitState(mm,:)).RatingFactors_Inv(1,2*ii,:),[],3);
                case Parameters.NumGirder
                    Factor = min(Data.Ext.(LimitState(mm,:)).RatingFactors_Inv(end,2*ii,:),[],3);
                otherwise
                    Factor = min(Data.Int.(LimitState(mm,:)).RatingFactors_Inv(jj-1,2*ii,:),[],3);
            end
            fprintf(fid,'%f\t',Factor);
        end
        catch
            if ii==1
            fprintf(fid,'\tNot Applicable for this Limit State');
            end
        end
        try
        fprintf(fid,'\n\nOp\t\t');
        for jj=1:Parameters.NumGirder
            switch jj
                case 1
                    Factor = min(Data.Ext.(LimitState(mm,:)).RatingFactors_Op(1,2*ii,:),[],3);
                case Parameters.NumGirder
                    Factor = min(Data.Ext.(LimitState(mm,:)).RatingFactors_Op(end,2*ii,:),[],3);
                otherwise
                    Factor = min(Data.Int.(LimitState(mm,:)).RatingFactors_Op(jj-1,2*ii,:),[],3);
            end
            fprintf(fid,'%f\t',Factor);
        end
        catch
            if ii==1
            fprintf(fid,'\tNot Applicable for this Limit State');
            end
        end
        fprintf(fid,'\n\n\n');
    end

    fprintf(fid,'---------------Minimum Ratings:--------------\n\n\t\tExt\t\tInt\n');
    try
    fprintf(fid,'Inv\t\t%f\t%f\n', Data.Ext.(LimitState(mm,:)).RFInv, Data.Int.(LimitState(mm,:)).RFInv);
    catch
        fprintf(fid,'Inv\t\t NA \n');
    end
    try
    fprintf(fid,'Op\t\t%f\t%f\n', Data.Ext.(LimitState(mm,:)).RFOp, Data.Int.(LimitState(mm,:)).RFOp);
    catch
        fprintf(fid,'Op\t\t NA \n');
    end
    fprintf(fid,'----------------------------------------------\n\n');
end

fprintf(fid,'\n\n Capacity:  Girder moment or stress capacity\n--------------------------------------------------');
switch Parameters.structureType
    case 'Steel'
        switch Code
            case 'ASD'
               fprintf(fid,'\n\nInventory Stress Limit\t%g',Parameters.Rating.(Code).Capacity.Int.FnInv); 
               fprintf(fid,'\n\nOperating Stress Limit\t%g',Parameters.Rating.(Code).Capacity.Int.FnOp);
            case 'LRFD'
                fprintf(fid,'\n\nYield Stress Limit for Service State Capacity (psi):\t%g',Parameters.Rating.(Code).Capacity.Int.Fy);
                fprintf(fid,'\n\n\nStrength 1 Capacity of Exterior Girders');
                try
                    fprintf(fid,'\n\nStress Limit for Positive Moment Region (psi):\t\t%g',Parameters.Rating.(Code).Capacity.Ext.Fn_pos);
                catch
                end
                try
                    fprintf(fid,'\n\nMoment Limit for Positive Moment Region (lb-in):\t%.0f',Parameters.Rating.(Code).Capacity.Ext.Mn_pos);
                catch
                end
                try
                    fprintf(fid,'\n\nStress Limit for Negative Moment Region (psi):\t%g',Parameters.Rating.(Code).Capacity.Ext.Fn_neg);
                catch
                end
                fprintf(fid,'\n\n\nStrength 1 Capacity of Interior Girders');
                try
                    fprintf(fid,'\n\nStress Limit for Positive Moment Region (psi):\t\t%g',Parameters.Rating.(Code).Capacity.Int.Fn_pos);
                catch
                end
                try
                    fprintf(fid,'\n\nMoment Limit for Positive Moment Region (lb-in):\t%.0f',Parameters.Rating.(Code).Capacity.Int.Mn_pos);
                catch
                end
                try
                    fprintf(fid,'\n\nStress Limit for Negative Moment Region (psi):\t%g',Parameters.Rating.(Code).Capacity.Int.Fn_neg);
                catch
                end
        end
end


fprintf(fid,'\n\n\n Demands:  Moments (lb-in) and Stresses (psi)\n--------------------------------------------------\n\n');
count = 1;
for ii = 1:Parameters.Spans
    fprintf(fid,'Location %i: Span %i at %g of span length...........................................\n\n',count,ii,Loc);
    count = count+1;
    fprintf(fid,'Girder:\t\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'#%i \t\t',jj);
    end
    fprintf(fid,'\n\nMax DL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', Data.DeadLoadMoments(jj,2*ii-1,1));
    end
    fprintf(fid,'\n\nMax SDL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', Data.DeadLoadMoments(jj,2*ii-1,2));
    end
    fprintf(fid,'\n\nMax DLW Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', Data.DeadLoadMoments(jj,2*ii-1,3));
    end
    fprintf(fid,'\n\nMax LL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', max(Data.LiveLoadMoments(jj,2*ii-1,:),[],3));
    end
    fprintf(fid,'\n\n\nMax DL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', Data.DeadLoadStresses(jj,2*ii-1,1));
    end
    fprintf(fid,'\n\nMax SDL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', Data.DeadLoadStresses(jj,2*ii-1,2));
    end
    fprintf(fid,'\n\nMax DLW Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', Data.DeadLoadStresses(jj,2*ii-1,3));
    end
    fprintf(fid,'\n\nMax LL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.1f\t\t', max(Data.LiveLoadStresses(jj,2*ii-1,:),[],3));
    end
    fprintf(fid,'\n\n\n');
end

for ii=1:Parameters.Spans-1
    fprintf(fid,'Location %i: Pier %i (Over Support).................................................\n\n',count,ii);
    count = count+1;
    fprintf(fid,'Girder:\t\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'#%i \t\t',jj);
    end
    fprintf(fid,'\n\nMax DL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', Data.DeadLoadMoments(jj,2*ii,1));
    end
    fprintf(fid,'\n\nMax SDL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', ata.DeadLoadMoments(jj,2*ii,2));
    end
    fprintf(fid,'\n\nMax DLW Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', Data.DeadLoadMoments(jj,2*ii,3));
    end
    fprintf(fid,'\n\nMax LL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', max(Data.LiveLoadMoments(jj,2*ii,:),[],3));
    end
    fprintf(fid,'\n\n\nMax DL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', Data.DeadLoadStresses(jj,2*ii,1));
    end
    fprintf(fid,'\n\nMax SDL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', Data.DeadLoadStresses(jj,2*ii,2));
    end
    fprintf(fid,'\n\nMax DLW Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', Data.DeadLoadStresses(jj,2*ii,3));
    end
    fprintf(fid,'\n\nMax LL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.1f\t\t', max(Data.LiveLoadStresses(jj,2*ii,:),[],3));
    end
    fprintf(fid,'\n\n\n');
end

fprintf(fid,'\n\nEnd of Report.');
fclose(fid);
        
    
