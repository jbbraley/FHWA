function LoadCase = ApplyWheelLoads(uID, Parameters, Options, LoadCase, WheelLine)
global tyPLATE axUCS kAccelerations

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
for hh=1:size(WheelLine,3)
    for jj=1:Parameters.Rating.NumLane
        for k=1:size(WheelLine,1) %Loading Scenarios
            % Make double truck loading scenario concurrent
            if Parameters.Rating.Load.S(3)~=0 && strcmp(Parameters.Rating.Code, 'LRFD')
                if k==4
                    temp_LoadCase = LoadCase;
                    Factor = 0.9;                
                elseif k==5
                    LoadCase = temp_LoadCase;
                    Factor = 0.9;
                else
                    Factor = 1;
                end
            else
                Factor = 1;
            end

            for p = 1:size(WheelLine(k,jj,hh).L,3) %Spans

                if Parameters.Rating.Load.S(3)==0 || k~=5 || ~strcmp(Parameters.Rating.Code, 'LRFD')
                % Create Load Case
                iErr = calllib('St7API', 'St7NewLoadCase', uID, ['Live Load', ' - Truck', ' - ', num2str(LoadCase-1)]);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetLoadCaseType', uID, LoadCase, kAccelerations);
                HandleError(iErr);
                Defaults = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
                iErr = calllib('St7API', 'St7SetLoadCaseDefaults', uID, LoadCase, Defaults);
                HandleError(iErr);
                iErr = calllib('St7API', 'St7SetLoadCaseMassOption', uID, LoadCase, 0, 0);
                HandleError(iErr);

                ID = 0;
                end        

                for q = 1:3 % Axles
                % Set Wheel Load Positions
                    ID = ID+1;
                    Doubles(4) = WheelLine(k,jj,hh).R(q,1,p);
                    Doubles(5) = WheelLine(k,jj,hh).R(q,2,p);

                    Doubles(3) = -Parameters.Rating.Load.A(q)*Factor/2;

                    for l = 1:Total
                        iErr = calllib('St7API', 'St7SetPlatePointForce6', uID, l, LoadCase, axUCS, ID, Doubles);
                        if iErr == 0
                            break
                        end
                    end
        %         end

        %         if WheelLine(j).R(1,1) >= tan(Parameters.SkewNear*pi/180)*WheelLine(j).R(1,2)
                    ID = ID + 1;
                    Doubles(4) = WheelLine(k,jj,hh).L(q,1,p);
                    Doubles(5) = WheelLine(k,jj,hh).L(q,2,p);

                    Doubles(3) = -Parameters.Rating.Load.A(q)*Factor/2;

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