% for i=1:length(GuiInit.StateList)
% i=30;    

% for n=1:21
%     Year = num2str(1991+n);
%     fid=fopen(['D:\Research\Auto Modeling\RAMPS\Tables\NBI\' Year '\NJ' Year(3:4) '.txt']);
%     
%     if fid == -1
%         break
%     end
%     
%     bridge = 1;
%     while ~feof(fid)
%         NBI = fgetl(fid);
%         if length(NBI)==432
%             NBI_StrNum{bridge,1} = NBI(4:18);
%         end
%         bridge = bridge+1;
%     end
%     fclose(fid);
%     
%     if n==1
%         StructureNo = NBI_StrNum{n,1};
%     else
%         StructureNo = [StructureNo; NBI_StrNum{n,1}(~cellfun(@isempty,NBI_StrNum{n,1}(:)))'];
%         StructureNo = unique(StructureNo);
%     end    
% 
% end

% Find unique structure number identifiers
% StructureNo = NBI_StrNum{bridge,1}(:);
% for n=1:21
%     Year = num2str(1991+n);
%     fid=fopen(['D:\Research\Auto Modeling\RAMPS\Tables\NBI\' Year '\NJ' Year(3:4) '.txt']);
%     if fid == -1
%         break
%     end
%     
%    
% end
% 
% save(['D:\Research\Auto Modeling\RAMPS\Tables\NBI\Structure List\NJ.mat'],'StructureNo');
% end
% 
% %%
NBI_output = cell([1 119]);
NBI_data=cell([1 119]);
for n=1:21
    Year = num2str(1991+n);
    fid=fopen(['E:\Research\Auto Modeling\RAMPS\Tables\NBI\' Year '\PA' Year(3:4) '.txt']);
    
    if fid == -1
        continue
    end
    
    bridge = 1;
    
    while ~feof(fid) 
        NBI = fgetl(fid);
        if length(NBI)==432
            NBI_data{bridge,1} = str2double(NBI(1:3));
            NBI_data{bridge,2} = NBI(4:18);
            NBI_data{bridge,3} = NBI(19);
            NBI_data{bridge,4} = str2double(NBI(20));
            NBI_data{bridge,5} = str2double(NBI(21));
            NBI_data{bridge,6} = NBI(22:26);
            NBI_data{bridge,7} = str2double(NBI(27));
            NBI_data{bridge,8} = NBI(28:29);
            NBI_data{bridge,9} = str2double(NBI(30:32));
            NBI_data{bridge,10} = str2double(NBI(33:37));
            NBI_data{bridge,11} = NBI(38:61);
            NBI_data{bridge,12} = NBI(62);
            NBI_data{bridge,13} = NBI(63:80);
            NBI_data{bridge,14} = NBI(81:105);
            NBI_data{bridge,15} = str2double(NBI(106:109));
            NBI_data{bridge,16} = str2double(NBI(110:116));
            NBI_data{bridge,17} = str2double(NBI(117));
            NBI_data{bridge,18} = NBI(118:127);
            NBI_data{bridge,19} = NBI(128:129);
            NBI_data{bridge,20} = str2double(NBI(130:137));
            NBI_data{bridge,21} = str2double(NBI(138:146));
            NBI_data{bridge,22} = str2double(NBI(147:149));
            NBI_data{bridge,23} = str2double(NBI(150));
            NBI_data{bridge,24} = str2double(NBI(151:152));
            NBI_data{bridge,25} = str2double(NBI(153:154));
            NBI_data{bridge,26} = str2double(NBI(155:156));
            NBI_data{bridge,27} = str2double(NBI(157:160));
            NBI_data{bridge,28} = str2double(NBI(161:162));
            NBI_data{bridge,29} = str2double(NBI(163:164));
            NBI_data{bridge,30} = str2double(NBI(165:170));
            NBI_data{bridge,31} = str2double(NBI(171:174));
            NBI_data{bridge,32} = NBI(175);
            NBI_data{bridge,33} = str2double(NBI(176:179));
            NBI_data{bridge,34} = str2double(NBI(180));
            NBI_data{bridge,35} = str2double(NBI(181:182));
            NBI_data{bridge,36} = str2double(NBI(183));
            NBI_data{bridge,37} = NBI(184);
            NBI_data{bridge,38} = NBI(185);
            NBI_data{bridge,39} = NBI(186);
            NBI_data{bridge,40} = NBI(187);
            NBI_data{bridge,41} = str2double(NBI(188));
            NBI_data{bridge,42} = NBI(189);
            NBI_data{bridge,43} = str2double(NBI(190:193));
            NBI_data{bridge,44} = str2double(NBI(194:198));
            NBI_data{bridge,45} = str2double(NBI(199));
            NBI_data{bridge,46} = str2double(NBI(200));
            NBI_data{bridge,47} = str2double(NBI(201));
            NBI_data{bridge,48} = str2double(NBI(202));
            NBI_data{bridge,49} = str2double(NBI(203:204));
            NBI_data{bridge,50} = str2double(NBI(205));
            NBI_data{bridge,51} = str2double(NBI(206:207));
            NBI_data{bridge,52} = str2double(NBI(208:210));
            NBI_data{bridge,53} = str2double(NBI(211:214));
            NBI_data{bridge,54} = str2double(NBI(215:217));
            NBI_data{bridge,55} = str2double(NBI(218:222));
            NBI_data{bridge,56} = str2double(NBI(223:228));
            NBI_data{bridge,57} = str2double(NBI(229:231));
            NBI_data{bridge,58} = str2double(NBI(232:234));
            NBI_data{bridge,59} = str2double(NBI(235:238));
            NBI_data{bridge,60} = str2double(NBI(239:242));
            NBI_data{bridge,61} = str2double(NBI(243:246));
            NBI_data{bridge,62} = NBI(247);
            NBI_data{bridge,63} = str2double(NBI(248:251));
            NBI_data{bridge,64} = NBI(252);
            NBI_data{bridge,65} = str2double(NBI(253:255));
            NBI_data{bridge,66} = str2double(NBI(256:258));
            NBI_data{bridge,67} = NBI(259);
            NBI_data{bridge,68} = NBI(260);
            NBI_data{bridge,69} = NBI(261);
            NBI_data{bridge,70} = NBI(262);
            NBI_data{bridge,71} = NBI(263);
            NBI_data{bridge,72} = str2double(NBI(264));
            NBI_data{bridge,73} = str2double(NBI(265:267));
            NBI_data{bridge,74} = str2double(NBI(268));
            NBI_data{bridge,75} = str2double(NBI(269:271));
            NBI_data{bridge,76} = NBI(272);
            NBI_data{bridge,77} = NBI(273);
            NBI_data{bridge,78} = NBI(274);
            NBI_data{bridge,79} = str2double(NBI(275));
            NBI_data{bridge,80} = NBI(276);
            NBI_data{bridge,81} = NBI(277);
            NBI_data{bridge,82} = str2double(NBI(278:279));
            NBI_data{bridge,83} = NBI(280);
            NBI_data{bridge,84} = str2double(NBI(281:286));
            NBI_data{bridge,85} = str2double(NBI(287:290));
            NBI_data{bridge,86} = str2double(NBI(291:292));
            NBI_data{bridge,87} = NBI(293:295);
            NBI_data{bridge,88} = NBI(296:298);
            NBI_data{bridge,89} = NBI(299:301);
            NBI_data{bridge,90} = NBI(302:313);
            NBI_data{bridge,91} = NBI(306:309);
            NBI_data{bridge,92} = NBI(310:313);
            NBI_data{bridge,93} = str2double(NBI(314:319));
            NBI_data{bridge,94} = str2double(NBI(320:325));
            NBI_data{bridge,95} = str2double(NBI(326:331));
            NBI_data{bridge,96} = str2double(NBI(332:335));
            NBI_data{bridge,97} = NBI(336:338);
            NBI_data{bridge,98} = str2double(NBI(339:340));
            NBI_data{bridge,99} = NBI(341:355);
            NBI_data{bridge,100} = str2double(NBI(356));
            NBI_data{bridge,101} = NBI(357);
            NBI_data{bridge,102} = str2double(NBI(358));
            NBI_data{bridge,103} = NBI(359);
            NBI_data{bridge,104} = str2double(NBI(360));
            NBI_data{bridge,105} = str2double(NBI(361));
            NBI_data{bridge,106} = str2double(NBI(362:365));
            NBI_data{bridge,107} = NBI(366);
            NBI_data{bridge,108} = NBI(367);
            NBI_data{bridge,109} = NBI(368);
            NBI_data{bridge,110} = NBI(369);
            NBI_data{bridge,111} = str2double(NBI(370:371));
            NBI_data{bridge,112} = str2double(NBI(372));
            NBI_data{bridge,113} = str2double(NBI(373));
            NBI_data{bridge,114} = NBI(374);
            NBI_data{bridge,115} = NBI(375);
            NBI_data{bridge,116} = str2double(NBI(376:381));
            NBI_data{bridge,117} = str2double(NBI(382:385));
            NBI_data{bridge,118} = NBI(427);
            NBI_data{bridge,119} = str2double(NBI(429:432));
            
            bridge = bridge + 1;
        end
    end
    
    fclose(fid);  
    
    if n == 1
        NBI_Data = NBI_data;
    else
 
        NBI_Data = [NBI_Data; NBI_data(~cellfun(@isempty,NBI_data(:,2)),:)];
        [~, rows, ~] = unique(NBI_Data(:,2),'last');
        NBI_Data = NBI_Data(rows,:);
    end
end

save(['D:\Research\Auto Modeling\RAMPS\Tables\State Data\' Options.NBI.State '\NBI_Data.mat'], 'NBI_Data','-v7');
% 
% 
