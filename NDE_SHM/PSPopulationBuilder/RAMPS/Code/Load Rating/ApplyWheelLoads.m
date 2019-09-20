function LoadCase = ApplyWheelLoads(uID, ArgIn, LoadCase, WheelLine, DblInd)
global tyPLATE axUCS kAccelerations
% ArgIn = Parameters.Rating.(Code);

%% Get Number of Plates and Set as Selected
% Get total number of plates
Total = 0;
[iErr, Total] = calllib('St7API', 'St7GetTotal', uID, tyPLATE, Total);
HandleError(iErr);

% Set all plates to TRUE selected state
Selected = 1;

XYZ = [0, 0, 0];
PlateLocalCoord = zeros(Total, 3);
for i = 1:Total
    EntityNum = i;
    
    iErr = calllib('St7API', 'St7SetEntitySelectState', uID, tyPLATE, EntityNum, 0, Selected);
    HandleError(iErr);
    
    UV = zeros(1,3);    
    [iErr, UV] = calllib('St7API', 'St7GetPlateUV', uID, EntityNum, XYZ, UV);
    HandleError(iErr);
    PlateLocalCoord(i,:) = UV;
end

%% Apply Point Forces And Create Load Cases
Doubles = zeros(6,1);
m=1;
for kk=1:size(WheelLine,3) % Lane positions
    for ii=1:ArgIn.NumLane % Lanes
        for jj=1:size(WheelLine,1) %Spans       
            for n = 1:size(WheelLine(jj,ii,kk).L,3) %LoadingScenarios
            % Make double truck loading scenario concurrent
            Factor = 1;
            NewCase = 1;
            if DblInd~=-99 && jj<(size(WheelLine,1)-1)%strcmp(Parameters.Rating.Code, 'LRFD')
                if n==DblInd
                    temp_LoadCase = LoadCase;
                    Factor = 0.9;                
                elseif n==DblInd+1
                    LoadCase = temp_LoadCase;
                    Factor = 0.9;
                    NewCase = 0;
                end
            end
                
            

                if NewCase
                % Create Load Case
                iErr = calllib('St7API', 'St7NewLoadCase', uID, ['Live Load', ' - Truck', ' - ', num2str(m)]);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetLoadCaseType', uID, LoadCase, kAccelerations);
                HandleError(iErr);
                Defaults = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                iErr = calllib('St7API', 'St7SetLoadCaseDefaults', uID, LoadCase, Defaults);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetLoadCaseMassOption', uID, LoadCase, 0, 0);
                HandleError(iErr);
                m=m+1;

                ID = 0;
                end        

                for q = find(WheelLine(jj,ii,kk).R(:,1,n)~=-99)' % Axles
                % Set Wheel Load Positions
                    ID = ID+1;
                    Doubles(4) = WheelLine(jj,ii,kk).R(q,1,n);
                    Doubles(5) = WheelLine(jj,ii,kk).R(q,2,n);
                    if WheelLine(jj,ii,kk).R(1,1,n)==-99 && ArgIn.Load.TD ~= 0                        
                        Doubles(3) = -ArgIn.Load.TD*Factor/2*ArgIn.IM;
                    else
                        Doubles(3) = -ArgIn.Load.A(q)*Factor/2*ArgIn.IM;
                    end

                    for l = 1:Total
                        iErr = calllib('St7API', 'St7SetPlatePointForce6', uID, l, LoadCase, axUCS, ID, Doubles);
                        if iErr == 0
                            break
                        end
                    end
                    
                    ID = ID + 1;
                    Doubles(4) = WheelLine(jj,ii,kk).L(q,1,n);
                    Doubles(5) = WheelLine(jj,ii,kk).L(q,2,n);
                    
                    for l = 1:Total
                        iErr = calllib('St7API', 'St7SetPlatePointForce6', uID, l, LoadCase, axUCS, ID, Doubles);
                        if iErr == 0
                            break
                        end
                    end
                end
                LoadCase = LoadCase + 1;
            end
        end
    end
end


%% Set all plates to FALSE selected state
Selected = 0;

for i = 1:Total
    EntityNum = i;
    
    iErr = calllib('St7API', 'St7SetEntitySelectState', uID, tyPLATE, EntityNum, 0, Selected);
    HandleError(iErr);
end
end % ApplyWheelLoads()