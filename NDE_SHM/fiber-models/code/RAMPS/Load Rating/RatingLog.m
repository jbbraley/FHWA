function RatingLog(Parameters,Options,saveloc)

%% Creates a log text file with the rating factors at various locations on the bridge
if isfield(Options, 'St7') && isfield(Options.St7, 'FileName')
    modelname = Options.St7.FileName;
else
    modelname = Options.ModelName;
end

fid = fopen([saveloc modelname '_RF.txt'],'wt');
fprintf(fid,'\nRating Factors for model: %s on %s \n\n\n\n', char(modelname), datestr(clock, 'mm.dd.yyyy'));
count = 1;
switch Parameters.structureType
    case 'Steel'
        LimitState = ['St1'; 'Sv2'];
    case 'Prestressed'
        LimitState = ['St1'; 'Sv3'];
end
for mm = 1:2
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
    fprintf(fid,'Location %i: Span %i at %g of span length...........................................\n\n',count,ii,Loc);
    count = count+1;
    fprintf(fid,'Girder:\t\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'#%i \t\t',jj);
    end
    try
    fprintf(fid,'\n\n\nInv\t\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%f\t', min(Parameters.Rating.(LimitState(mm,:)).RatingFactors_Inv(jj,2*ii-1,:),[],3));
    end
    catch 
        if ii==1
        fprintf(fid,'\tNot Applicable for this Limit State');
        end
    end
    try
    fprintf(fid,'\n\nOp\t\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%f\t', min(Parameters.Rating.(LimitState(mm,:)).RatingFactors_Op(jj,2*ii-1,:),[],3));
    end
    catch
        if ii==1
        fprintf(fid,'\tNot Applicable for this Limit State');
        end
    end
    
%     fprintf(fid,'\n\nMax DL Stress\t');
%     for jj=1:Parameters.NumGirder
%         fprintf(fid,'%f\t', max(Parameters.Rating.(LimitState(mm,:)).DeadLoadStresses(jj,2*ii-1,:),[],3));
%     end
%     fprintf(fid,'\n\nMax LL Stress\t');
%     for jj=1:Parameters.NumGirder
%         fprintf(fid,'%f\t', max(Parameters.Rating.(LimitState(mm,:)).LiveLoadStresses(jj,2*ii-1,:),[],3));
%     end
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
        fprintf(fid,'%f\t', min(Parameters.Rating.(LimitState(mm,:)).RatingFactors_Inv(jj,2*ii,:),[],3));
    end
    catch
        if ii==1
        fprintf(fid,'\tNot Applicable for this Limit State');
        end
    end
    try
    fprintf(fid,'\n\nOp\t\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%f\t', min(Parameters.Rating.(LimitState(mm,:)).RatingFactors_Op(jj,2*ii,:),[],3));
    end
    catch
        if ii==1
        fprintf(fid,'\tNot Applicable for this Limit State');
        end
    end
%     fprintf(fid,'\n\nMax DL Stress\t');
%     for jj=1:Parameters.NumGirder
%         fprintf(fid,'%f\t', max(Parameters.Rating.(LimitState(mm,:)).DeadLoadStresses(jj,2*ii,:),[],3));
%     end
%     fprintf(fid,'\n\nMax LL Stress\t');
%     for jj=1:Parameters.NumGirder
%         fprintf(fid,'%f\t', max(Parameters.Rating.(LimitState(mm,:)).LiveLoadStresses(jj,2*ii,:),[],3));
%     end
    fprintf(fid,'\n\n\n');
end

fprintf(fid,'------Minimum Ratings:------\n\n');
try
fprintf(fid,'Inv\t\t%f\n', Parameters.Rating.(LimitState(mm,:)).RFInv);
catch
    fprintf(fid,'Inv\t\t NA \n');
end
try
fprintf(fid,'Op\t\t%f\n', Parameters.Rating.(LimitState(mm,:)).RFOp);
catch
    fprintf(fid,'Op\t\t NA \n');
end
fprintf(fid,'----------------------------\n\n');
end

fprintf(fid,'\n\n Moments (lb-in) and Stresses (psi)\n\n');
for ii = 1:Parameters.Spans
    fprintf(fid,'Location %i: Span %i at %g of span length...........................................\n\n',count,ii,Loc);
    count = count+1;
    fprintf(fid,'Girder:\t\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'#%i \t\t',jj);
    end
    fprintf(fid,'\n\nMax DL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', max(Parameters.Rating.DeadLoadMoments(jj,2*ii-1,1),[],3));
    end
    fprintf(fid,'\n\nMax SDL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', max(Parameters.Rating.DeadLoadMoments(jj,2*ii-1,2),[],3));
    end
    fprintf(fid,'\n\nMax DLW Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', max(Parameters.Rating.DeadLoadMoments(jj,2*ii-1,3),[],3));
    end
    fprintf(fid,'\n\nMax LL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', max(Parameters.Rating.LiveLoadMoments(jj,2*ii-1,:),[],3));
    end
    fprintf(fid,'\n\nMax DL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', max(Parameters.Rating.DeadLoadStresses(jj,2*ii-1,1),[],3));
    end
    fprintf(fid,'\n\nMax SDL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', max(Parameters.Rating.DeadLoadStresses(jj,2*ii-1,2),[],3));
    end
    fprintf(fid,'\n\nMax DLW Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', max(Parameters.Rating.DeadLoadStresses(jj,2*ii-1,3),[],3));
    end
    fprintf(fid,'\n\nMax LL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', max(Parameters.Rating.LiveLoadStresses(jj,2*ii-1,:),[],3));
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
        fprintf(fid,'%.2f\t', max(Parameters.Rating.DeadLoadMoments(jj,2*ii,1),[],3));
    end
    fprintf(fid,'\n\nMax SDL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', max(Parameters.Rating.DeadLoadMoments(jj,2*ii,2),[],3));
    end
    fprintf(fid,'\n\nMax DLW Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', max(Parameters.Rating.DeadLoadMoments(jj,2*ii,3),[],3));
    end
    fprintf(fid,'\n\nMax LL Moment\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t', max(Parameters.Rating.LiveLoadMoments(jj,2*ii,:),[],3));
    end
    fprintf(fid,'\n\nMax DL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', max(Parameters.Rating.DeadLoadStresses(jj,2*ii,1),[],3));
    end
    fprintf(fid,'\n\nMax SDL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', max(Parameters.Rating.DeadLoadStresses(jj,2*ii,2),[],3));
    end
    fprintf(fid,'\n\nMax DLW Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', max(Parameters.Rating.DeadLoadStresses(jj,2*ii,3),[],3));
    end
    fprintf(fid,'\n\nMax LL Stress\t');
    for jj=1:Parameters.NumGirder
        fprintf(fid,'%.2f\t\t', max(Parameters.Rating.LiveLoadStresses(jj,2*ii,:),[],3));
    end
    fprintf(fid,'\n\n\n');
end

fprintf(fid,'\n\nEnd of Report.');
fclose(fid);
        
    
