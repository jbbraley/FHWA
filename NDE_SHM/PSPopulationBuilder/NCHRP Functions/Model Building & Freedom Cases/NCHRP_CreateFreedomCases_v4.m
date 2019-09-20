%NCHRP_CreateFreedomCases
clear
clc

h = waitbar(0,'Initializing...');
global kNormalFreedom

% USER INPUT --------------------------------------------------------------

Path = 'D:\Files\Documents\PSPopulationBuilder\Pre-Stressed\3-Span\Suite 2\Model Files';
SettCases = {'Vert';'RPos';'RNeg'};

% Defaults
FCaseType = kNormalFreedom;
FCaseDefaults = [false, false, false, false, false, false];

% -------------------------------------------------------------------------

% Get filenames of all model files
dirData = dir([Path '\*.st7']);
for ii = 1:length(dirData)
    dirData(ii).ind = str2double(dirData(ii).name(10:end-4));
    ind(ii) = dirData(ii).ind;
end
[~,index] = sortrows([dirData.ind].'); dirData = dirData(index); clear index
fileList = {dirData(:).name}'; 

InitializeSt7(1)
for ii = 1:length(fileList)
    
    waitbar(ii/length(fileList),h,['Creating freedom cases for Bridge ' num2str(ii)]);
    try
        if ~exist([Path '\Nodes\PSBridge_' num2str(ii) '_Node.mat'],'file') 
            continue
        end

        % Load St7 API
        St7Start = 0;
        InitializeRAMPS([],[], St7Start);

        mName = ['PSBridge_' num2str(ii)];
%         mName = fileList{ii}(1:end-4);
%         ModelPathName = [Path '\Model Files\'];
        ModelPathName = [Path '\'];

        % Load in parameters, node, and options files
%         load([Path '\Model Files\Nodes\' mName '_Node' '.mat']);
%         load([Path '\Model Files\Parameters\' mName '_Para' '.mat']);
%         load([Path '\Model Files\Options\' mName '_Options' '.mat']);
        load([Path '\Nodes\' mName '_Node' '.mat']);
        load([Path '\Parameters\' mName '_Para' '.mat']);
        load([Path '\Options\' mName '_Options' '.mat']);


        uID = Options.St7.uID;

        % Support Fixity Conditions -------------------------------------------

        % Fixity  = [DX DY DZ RX RY RZ Alignment Long.]

        % Pinned Fixity
        Parameters.Bearing.Fixed.Fixity = [0 0 1 0 0 0 1 1];

        % Expansion fixity and displacement
        Parameters.Bearing.Expansion.Fixity = [0 0 1 0 0 0 0 0];

        % Pinned Bearing Settlement/location
        noSettLoc = zeros(1,Parameters.Spans+1);
        if Parameters.Spans == 1
            Locs = eye(2); 
        elseif Parameters.Spans == 2
            Locs = eye(3);
        elseif Parameters.Spans == 3
            Locs = eye(4);
        end

        % Fixed rotation at abutment
        nofixedR = zeros(1,Parameters.Spans+1);
        if Parameters.Spans == 1
            fixedR = [1 1];
        elseif Parameters.Spans == 2
            fixedR = [1 0 1];
        elseif Parameters.Spans == 3
            fixedR = [1 0 0 1];
        end

        % Support Disp Conditions ---------------------------------------------
        Parameters.Bearing.Fixed.Disp = [0 0 0 0 0 0];
        Parameters.Bearing.Expansion.Disp = [0 0 0 0 0 0];
        
        % no Displacement
        no_disp = zeros(1,Parameters.NumGirder); 

        % Vertical Displacement
        v_disp = -1*ones(1,Parameters.NumGirder); %[inches, degrees]

        % Rotational Displacement
        r_dispNeg = 0:-1/(Parameters.NumGirder-1):-1;
        r_dispPos = fliplr(r_dispNeg);

        % Load St7 Model files ------------------------------------------------
        St7OpenModelFile(Options.St7.uID, ModelPathName, Parameters.ModelName, Options.St7.ScratchPath);

        %% Delete Existing Freedom Cases
        NumCases = 0;
        cStart = 2;
        [iErr, NumCases] = calllib('St7API', 'St7GetNumFreedomCase', uID, NumCases);
        HandleError(iErr);

        if NumCases > 1
            for jj=cStart:NumCases
                k = cStart;
                iErr = calllib('St7API', 'St7DeleteFreedomCase', uID, k);
                HandleError(iErr);
            end
        end
        
        % Get existing freedom case names
        [~, ~, FNumCases, FCaseName] = St7GetLoadAndFreedomCaseInfo(Options.St7.uID);

        % Create General freedom cases first ------------------------------
        % no settlements

        fCaseNum = 0;
        
        % Loop Through locations of long. fixity
        for aa = 1:length(Locs)
            
            fCaseNum = fCaseNum +1;
           
            % Define location of long. fixity
            Parameters.Bearing.Type = Locs(aa,:);
            if Locs(aa,1) == 1
                LocID = 'A1';
            elseif Locs(aa,end) == 1
                LocID = 'A2';
            elseif Locs(aa,2) == 1
                LocID = 'P1';
            elseif size(Locs,1) > 3 && Locs(aa,3) == 1
                LocID = 'P2';
            end

            % Freedom Case Name
            fCaseName = LocID;

            % Create freedom case 
            if aa == 1 && ~strcmp(FCaseName(1),LocID)
                iErr = calllib('St7API', 'St7SetFreedomCaseName', Options.St7.uID, fCaseNum, fCaseName);
                HandleError(iErr); % Rename freedom case
            elseif aa > 1
                St7CreateFreedomCase(Options.St7.uID, fCaseName, fCaseNum, FCaseType, FCaseDefaults);
            end

            % Set Boundary Condition
            NCHRP_SetBoundaryConditions_v2(uID, Node, Parameters, fCaseNum, no_disp, noSettLoc, nofixedR);

        end

        % Create Settlement Freedom cases next ----------------------------

        % Loop through boundary cases
        for aa = 1:length(Locs)

             % Define location of long. fixity
            Parameters.Bearing.Type = Locs(aa,:);
            if Locs(aa,1) == 1
                LocID = 'A1';
            elseif Locs(aa,end) == 1
                LocID = 'A2';
            elseif Locs(aa,2) == 1
                LocID = 'P1';
            elseif size(Locs,1) > 3 && Locs(aa,3) == 1
                LocID = 'P2';
            end

            % Loop through settlement cases
            for bb = 1:length(SettCases)
                
                fCaseNum = fCaseNum +1;

                % Define settlement displacements
                if strcmp(SettCases{bb},'Vert')
                    disp = v_disp;
                elseif strcmp(SettCases{bb},'RPos')
                    disp = r_dispPos;
                elseif strcmp(SettCases{bb},'RNeg')
                    disp = r_dispNeg;
                end

                % Freedom Case Name
                fCaseName = [LocID '_' SettCases{bb}];

                % Create freedom case 
                St7CreateFreedomCase(Options.St7.uID, fCaseName, fCaseNum, FCaseType, FCaseDefaults);

                % Set Boundary Condition
                NCHRP_SetBoundaryConditions_v2(uID, Node, Parameters, fCaseNum, disp, Locs(aa,:), nofixedR);
                
            end          
        end
        
        % Create general freedom cases with fixed abutments ---------------
        
        % Loop Through locations of long. fixity
        for aa = 1:length(Locs)
            
            fCaseNum = fCaseNum +1;
           
            % Define location of long. fixity
            Parameters.Bearing.Type = Locs(aa,:);
            if Locs(aa,1) == 1
                LocID = 'A1';
            elseif Locs(aa,end) == 1
                LocID = 'A2';
            elseif Locs(aa,2) == 1
                LocID = 'P1';
            elseif size(Locs,1) > 3 && Locs(aa,3) == 1
                LocID = 'P2';
            end

            % Freedom Case Name
            fCaseName = [LocID '-F'];

            % Create freedom case 
            St7CreateFreedomCase(Options.St7.uID, fCaseName, fCaseNum, FCaseType, FCaseDefaults);

            % Set Boundary Condition
            NCHRP_SetBoundaryConditions_v2(uID, Node, Parameters, fCaseNum, no_disp, noSettLoc, fixedR);

        end
        
        % Create sett. freedom cases with fixed abutments -----------------
        
        % Loop through boundary cases
        for aa = 1:length(Locs)

             % Define location of long. fixity
            Parameters.Bearing.Type = Locs(aa,:);
            if Locs(aa,1) == 1
                LocID = 'A1';
            elseif Locs(aa,end) == 1
                LocID = 'A2';
            elseif Locs(aa,2) == 1
                LocID = 'P1';
            elseif size(Locs,1) > 3 && Locs(aa,3) == 1
                LocID = 'P2';
            end

            % Loop through settlement cases
            for bb = 1:length(SettCases)
                
                fCaseNum = fCaseNum +1;

                % Define settlement displacements
                if strcmp(SettCases{bb},'Vert')
                    disp = v_disp;
                elseif strcmp(SettCases{bb},'RPos')
                    disp = r_dispPos;
                elseif strcmp(SettCases{bb},'RNeg')
                    disp = r_dispNeg;
                end

                % Freedom Case Name
                fCaseName = [LocID '-F_' SettCases{bb}];

                % Create freedom case 
                St7CreateFreedomCase(Options.St7.uID, fCaseName, fCaseNum, FCaseType, FCaseDefaults);

                % Set Boundary Condition
                NCHRP_SetBoundaryConditions_v2(uID, Node, Parameters, fCaseNum, disp, Locs(aa,:), fixedR);
                
            end          
        end
        
    catch
        close(h)
        CloseModelFile(Options.St7.uID);
        CloseAndUnload(Options.St7.uID);
        return
    end
        
    SaveModelFile(Options.St7.uID);
    CloseModelFile(Options.St7.uID);
    
end
CloseAndUnload();
close(h);
fprintf('Freedom cases created. \n');


