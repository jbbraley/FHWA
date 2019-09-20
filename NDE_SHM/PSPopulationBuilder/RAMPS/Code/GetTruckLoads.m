function ArgIn = GetTruckLoads(ArgIn)

% Truck Loads
switch ArgIn.DesignLoad
    case '1'
        % H 10
        ArgIn.DesignTruckName = 'H-10';
        ArgIn.Tandem = 0;
        
        ArgIn.Load.A = [4000 15000 0]; % [lbs]
        
        ArgIn.Load.S = 0; % [inches]
        ArgIn.Load.FS = 168; % [inches]
        
        ArgIn.Load.TD = 0;
        
        ArgIn.Load.PM = 0;
        ArgIn.Load.PS = 0;
    case '2'
        % H 15
        ArgIn.DesignTruckName = 'H-15';
        ArgIn.Tandem = 0;
        
        ArgIn.Load.A = [6000 24000 0]; % [lbs]
        
        ArgIn.Load.S = 0;
        ArgIn.Load.FS = 168; % [inches]
        
        ArgIn.LaneLoad = 480/12; % [lbs/inch]
        
        ArgIn.Load.PM = 13500; % [lbs]
        ArgIn.Load.PS = 19500; % [lbs]
        
        ArgIn.Load.TD = 0;
    case '3'
        % HS 15
        ArgIn.DesignTruckName = 'HS-15';
        ArgIn.Tandem = 0;
        
        ArgIn.Load.A = [6000 24000 24000]; % [lbs]
        
        ArgIn.Load.S = [168 264 360]; % [inches]
        ArgIn.Load.FS = 168; % [inches]
        
        ArgIn.LaneLoad = 480/12; % [lbs/inch]
        
        ArgIn.Load.PM = 13500; % [lbs]
        ArgIn.Load.PS = 19500; % [lbs]
        
        ArgIn.Load.TD = 0;
    case '4'
        % H 20
        ArgIn.DesignTruckName = 'H-20';
        ArgIn.Tandem = 0;
        
        ArgIn.Load.A = [8000 32000 0]; % [lbs]
        
        ArgIn.Load.S = 0;
        ArgIn.Load.FS = 168; % [inches]
        
        ArgIn.LaneLoad = 640/12; % [lbs/inch]
        
        ArgIn.Load.PM = 18000; % [lbs]
        ArgIn.Load.PS = 26000; % [lbs]
        
        ArgIn.Load.TD = 0;
    case '5'
        % HS 20
        ArgIn.DesignTruckName = 'HS-20';
        ArgIn.Tandem = 0;
        
        ArgIn.Load.A = [8000 32000 32000]; % [lbs]
        
        ArgIn.Load.S = [168 264 360]; % [inches]
        ArgIn.Load.FS = 168; % [inches]
        ArgIn.Load.TS = 0;
        
        ArgIn.LaneLoad = 640/12; % [lbs/inch]
        
        ArgIn.Load.PM = 18000; % [lbs]
        ArgIn.Load.PS = 26000; % [lbs]
        
        ArgIn.Load.TD = 0;
    case '6'
        % HS 20 + Mod (HS 20 + Military Loading)
        ArgIn.DesignTruckName = 'HS-20 + Mod';
        ArgIn.Tandem = 1;
        
        ArgIn.Load.A = [8000 32000 32000]; % [lbs]
        
        ArgIn.Load.S = [168 264 360]; % [inches]
        ArgIn.Load.FS = 168; % [inches]
        ArgIn.Load.TS = 48; % [inches]
        
        ArgIn.LaneLoad = 640/12; % [lbs/inch]
        
        ArgIn.Load.PM = 18000; % [lbs]
        ArgIn.Load.PS = 26000; % [lbs]
        
        ArgIn.Load.TD = 24000; % [lbs]
    case '9'
        % HS 25 or greater - Assume HS 25
        ArgIn.DesignTruckName = 'HS-25';
        ArgIn.Tandem = 1;
        
        ArgIn.Load.A = [10000 40000 340000]; % [lbs]

        ArgIn.Load.S = [168 264 360]; % [inches]
        ArgIn.Load.FS = 168; % [inches]
        ArgIn.Load.TS = 48; % [inches]
        
        ArgIn.LaneLoad = 640/12; % [lbs/inch]
        
        ArgIn.Load.PM = 22500; % [lbs]
        ArgIn.Load.PS = 26000; % [lbs]
        
        ArgIn.Load.TD = 25000; % [lbs]
    case '7'
        ArgIn.DesignTruckName = 'Pedestrian';
    case '8'
        ArgIn.DesignTruckName = 'Railroad';
    case '0'
        ArgIn.DesignTruckName = 'Unknown';
    case 'A'
        ArgIn.DesignTruckName = 'HL-93'; 
        ArgIn.Tandem = 2;
        
        ArgIn.Load.A = [8000 32000 32000]; % [lbs]
        
        ArgIn.Load.S = [168 264 360]; % [inches]
        ArgIn.Load.FS = 168; % [inches]
        ArgIn.Load.TS = 48; % [inches]
        
        ArgIn.LaneLoad = 640/12; % [lbs/inch]
        
        ArgIn.Load.PM = 18000; % [lbs]
        ArgIn.Load.PS = 26000; % [lbs]
        
        ArgIn.Load.TD = 25000;
    case 'B'
        ArgIn.DesignTruckName = 'Greater than HL-93';
    case 'C'
        ArgIn.DesignTruckName = 'Other';
    otherwise
        ArgIn.DesignTruckName = 'Not recorded';
end
end %GetTruckLoad()