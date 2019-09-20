function NBI_output = LoadNBIData(Options)
tic
%% Load data
% Load data for each year
NBI_output = cell([19 119]);
NBI_data=cell([1 119]);
for n=1:19
    Year = num2str(1991+n);
    tempcd = pwd;
    cd('../');
    fid=fopen(['E:\Research\Auto Modeling\RAMPS\Tables\NBI\' Year '\' Options.NBI.State Year(3:4) '.txt']);
    
    bridge = 1;
    
    while ~feof(fid) 
        NBI = fgetl(fid);
        if length(NBI)==432
            NBI_data{1,1}{bridge} = str2double(NBI(1:3));
            NBI_data{1,2}{bridge} = NBI(4:18);
            NBI_data{1,3}{bridge} = NBI(19);
            NBI_data{1,4}{bridge} = str2double(NBI(20));
            NBI_data{1,5}{bridge} = str2double(NBI(21));
            NBI_data{1,6}{bridge} = NBI(22:26);
            NBI_data{1,7}{bridge} = str2double(NBI(27));
            NBI_data{1,8}{bridge} = NBI(28:29);
            NBI_data{1,9}{bridge} = str2double(NBI(30:32));
            NBI_data{1,10}{bridge} = str2double(NBI(33:37));
            NBI_data{1,11}{bridge} = NBI(38:61);
            NBI_data{1,12}{bridge} = NBI(62);
            NBI_data{1,13}{bridge} = NBI(63:80);
            NBI_data{1,14}{bridge} = NBI(81:105);
            NBI_data{1,15}{bridge} = str2double(NBI(106:109));
            NBI_data{1,16}{bridge} = str2double(NBI(110:116));
            NBI_data{1,17}{bridge} = str2double(NBI(117));
            NBI_data{1,18}{bridge} = NBI(118:127);
            NBI_data{1,19}{bridge} = NBI(128:129);
            NBI_data{1,20}{bridge} = str2double(NBI(130:137));
            NBI_data{1,21}{bridge} = str2double(NBI(138:146));
            NBI_data{1,22}{bridge} = str2double(NBI(147:149));
            NBI_data{1,23}{bridge} = str2double(NBI(150));
            NBI_data{1,24}{bridge} = str2double(NBI(151:152));
            NBI_data{1,25}{bridge} = str2double(NBI(153:154));
            NBI_data{1,26}{bridge} = str2double(NBI(155:156));
            NBI_data{1,27}{bridge} = str2double(NBI(157:160));
            NBI_data{1,28}{bridge} = str2double(NBI(161:162));
            NBI_data{1,29}{bridge} = str2double(NBI(163:164));
            NBI_data{1,30}{bridge} = str2double(NBI(165:170));
            NBI_data{1,31}{bridge} = str2double(NBI(171:174));
            NBI_data{1,32}{bridge} = NBI(175);
            NBI_data{1,33}{bridge} = str2double(NBI(176:179));
            NBI_data{1,34}{bridge} = str2double(NBI(180));
            NBI_data{1,35}{bridge} = str2double(NBI(181:182));
            NBI_data{1,36}{bridge} = str2double(NBI(183));
            NBI_data{1,37}{bridge} = NBI(184);
            NBI_data{1,38}{bridge} = NBI(185);
            NBI_data{1,39}{bridge} = NBI(186);
            NBI_data{1,40}{bridge} = NBI(187);
            NBI_data{1,41}{bridge} = str2double(NBI(188));
            NBI_data{1,42}{bridge} = NBI(189);
            NBI_data{1,43}{bridge} = str2double(NBI(190:193));
            NBI_data{1,44}{bridge} = str2double(NBI(194:198));
            NBI_data{1,45}{bridge} = str2double(NBI(199));
            NBI_data{1,46}{bridge} = str2double(NBI(200));
            NBI_data{1,47}{bridge} = str2double(NBI(201));
            NBI_data{1,48}{bridge} = str2double(NBI(202));
            NBI_data{1,49}{bridge} = str2double(NBI(203:204));
            NBI_data{1,50}{bridge} = str2double(NBI(205));
            NBI_data{1,51}{bridge} = str2double(NBI(206:207));
            NBI_data{1,52}{bridge} = str2double(NBI(208:210));
            NBI_data{1,53}{bridge} = str2double(NBI(211:214));
            NBI_data{1,54}{bridge} = str2double(NBI(215:217));
            NBI_data{1,55}{bridge} = str2double(NBI(218:222));
            NBI_data{1,56}{bridge} = str2double(NBI(223:228));
            NBI_data{1,57}{bridge} = str2double(NBI(229:231));
            NBI_data{1,58}{bridge} = str2double(NBI(232:234));
            NBI_data{1,59}{bridge} = str2double(NBI(235:238));
            NBI_data{1,60}{bridge} = str2double(NBI(239:242));
            NBI_data{1,61}{bridge} = str2double(NBI(243:246));
            NBI_data{1,62}{bridge} = NBI(247);
            NBI_data{1,63}{bridge} = str2double(NBI(248:251));
            NBI_data{1,64}{bridge} = NBI(252);
            NBI_data{1,65}{bridge} = str2double(NBI(253:255));
            NBI_data{1,66}{bridge} = str2double(NBI(256:258));
            NBI_data{1,67}{bridge} = NBI(259);
            NBI_data{1,68}{bridge} = NBI(260);
            NBI_data{1,69}{bridge} = NBI(261);
            NBI_data{1,70}{bridge} = NBI(262);
            NBI_data{1,71}{bridge} = NBI(263);
            NBI_data{1,72}{bridge} = str2double(NBI(264));
            NBI_data{1,73}{bridge} = str2double(NBI(265:267));
            NBI_data{1,74}{bridge} = str2double(NBI(268));
            NBI_data{1,75}{bridge} = str2double(NBI(269:271));
            NBI_data{1,76}{bridge} = NBI(272);
            NBI_data{1,77}{bridge} = NBI(273);
            NBI_data{1,78}{bridge} = NBI(274);
            NBI_data{1,79}{bridge} = str2double(NBI(275));
            NBI_data{1,80}{bridge} = NBI(276);
            NBI_data{1,81}{bridge} = NBI(277);
            NBI_data{1,82}{bridge} = str2double(NBI(278:279));
            NBI_data{1,83}{bridge} = NBI(280);
            NBI_data{1,84}{bridge} = str2double(NBI(281:286));
            NBI_data{1,85}{bridge} = str2double(NBI(287:290));
            NBI_data{1,86}{bridge} = str2double(NBI(291:292));
            NBI_data{1,87}{bridge} = NBI(293:295);
            NBI_data{1,88}{bridge} = NBI(296:298);
            NBI_data{1,89}{bridge} = NBI(299:301);
            NBI_data{1,90}{bridge} = NBI(302:313);
            NBI_data{1,91}{bridge} = NBI(306:309);
            NBI_data{1,92}{bridge} = NBI(310:313);
            NBI_data{1,93}{bridge} = str2double(NBI(314:319));
            NBI_data{1,94}{bridge} = str2double(NBI(320:325));
            NBI_data{1,95}{bridge} = str2double(NBI(326:331));
            NBI_data{1,96}{bridge} = str2double(NBI(332:335));
            NBI_data{1,97}{bridge} = NBI(336:338);
            NBI_data{1,98}{bridge} = str2double(NBI(339:340));
            NBI_data{1,99}{bridge} = NBI(341:355);
            NBI_data{1,100}{bridge} = str2double(NBI(356));
            NBI_data{1,101}{bridge} = NBI(357);
            NBI_data{1,102}{bridge} = str2double(NBI(358));
            NBI_data{1,103}{bridge} = NBI(359);
            NBI_data{1,104}{bridge} = str2double(NBI(360));
            NBI_data{1,105}{bridge} = str2double(NBI(361));
            NBI_data{1,106}{bridge} = str2double(NBI(362:365));
            NBI_data{1,107}{bridge} = NBI(366);
            NBI_data{1,108}{bridge} = NBI(367);
            NBI_data{1,109}{bridge} = NBI(368);
            NBI_data{1,110}{bridge} = NBI(369);
            NBI_data{1,111}{bridge} = str2double(NBI(370:371));
            NBI_data{1,112}{bridge} = str2double(NBI(372));
            NBI_data{1,113}{bridge} = str2double(NBI(373));
            NBI_data{1,114}{bridge} = NBI(374);
            NBI_data{1,115}{bridge} = NBI(375);
            NBI_data{1,116}{bridge} = str2double(NBI(376:381));
            NBI_data{1,117}{bridge} = str2double(NBI(382:385));
            NBI_data{1,118}{bridge} = NBI(427);
            NBI_data{1,119}{bridge} = str2double(NBI(429:432));
            
            bridge = bridge + 1;
        end
    end
    
    fclose(fid);  
    cd(tempcd);
    %% Filter
    % Get subset of highway bridges
%     j=0;
%     NBI_temp=cell([1 119]);
%     for i=1:length(NBI_data{1,1})
%         if strcmp(NBI_data{1,3}{i},'1') && NBI_data{1,56}{i}>=61 && strcmp(NBI_data{1,114}{i},'Y') &&...
%                 (NBI_data{1,46}{i}==1 || NBI_data{1,46}{i}==4 || NBI_data{1,46}{i}==5 || NBI_data{1,46}{i}==6 || NBI_data{1,46}{i}==7 || NBI_data{1,46}{i}==8)
%             j=j+1;
%             for k=1:119
%                 NBI_temp{1,k}{j}=NBI_data{1,k}{i};
%             end
%         end
%     end
%     
%     % Get bridges built 1950 and later
%     NBI_data=NBI_temp;
%     
%     j=0;
%     NBI_temp=cell([1 119]);
%     for i=1:length(NBI_data{1,1})
%         if NBI_data{1,27}{i}>=1950
%             j=j+1;
%             for k=1:119
%                 NBI_temp{1,k}{j}=NBI_data{1,k}{i};
%             end
%         end
%     end
%     
%     % Get state-owned bridges
%     NBI_data=NBI_temp;
%     
%     j=0;
%     NBI_temp=cell([1 119]);
%     for i=1:length(NBI_data{1,1})
%         if NBI_data{1,24}{i}==1 || NBI_data{1,25}{i}==1
%             j=j+1;
%             for k=1:119
%                 NBI_temp{1,k}{j}=NBI_data{1,k}{i};
%             end
%         end
%     end
%     
%     % Get single-span, simply-supported steel girder bridge
%     NBI_data=NBI_temp;
%     
%     j=0;
%     NBI_temp=cell([1 119]);
%     for i=1:length(NBI_data{1,1})
%         if NBI_data{1,48}{i}==3 && NBI_data{1,49}{i}==2
%             if NBI_data{1,52}{i} == 1
%                 j=j+1;
%                 for k=1:119
%                     NBI_temp{1,k}{j}=NBI_data{1,k}{i};
%                 end
%             end
%         end
%     end
%     
%     % Get Bridges with Concrete Deck Slab
%     NBI_data=NBI_temp;
%     
%     j=0;
%     NBI_temp=cell([1 119]);
%     for i=1:length(NBI_data{1,1})
%         if strcmp(NBI_data{1,107}{i},'1') || strcmp(NBI_data{1,107}{i},'2')
%             j=j+1;
%             for k=1:119
%                 NBI_temp{1,k}{j}=NBI_data{1,k}{i};
%             end
%         end
%     end
%     
%     % Remove Bridges with Skew > 60 degrees
%     NBI_data=NBI_temp;
%     
%     j=0;
%     NBI_temp=cell([1 119]);
%     for i=1:length(NBI_data{1,1})
%         if NBI_data{1,35}{i}<=60
%             j=j+1;
%             for k=1:119
%                 NBI_temp{1,k}{j}=NBI_data{1,k}{i};
%             end
%         end
%     end
%     
    NBI_output(n,:)=NBI_data;
end
toc
end %LoadNBIData()