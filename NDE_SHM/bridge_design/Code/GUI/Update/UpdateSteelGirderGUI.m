function UpdateSteelGirderGUI(Parameters, Options, state)
% Get Parameters ----------------------------------------------------------
if isempty(Parameters)
    Parameters = getappdata(0, 'Parameters');
end

% Get Options -------------------------------------------------------------
if isempty(Options)
    Options = getappdata(0, 'Options');
end

% Girder Table Headings ---------------------------------------------------
if Parameters.Spans == 1
    % First column "Girder Properties" headers for single span model
    data = cell(10,3);
    data(:,1) = {'Girder Depth [in]'; 'Flange Width [in]'; 'Flange Thickness [in]';'Web Thickness [in]';...
        'Positive Capacity [lb-in]'; 'Moment of Inertia, Ix [in^4]'; 'Section Area [in^2]';'Dia Section';...
        'Controlling St1 Rating'; 'Controlling Sv2 Rating'};                    
else
    % First column "Girder Properties" headers for two span model
    data = cell(15,3);
    data(:,1) = {'Girder Depth [in]'; 'Flange Width [in]'; 'Flange Thickness [in]';...
    'Web Thickness [in]'; 'Cover Plate Length [in]'; 'Cover Plate Thickness [in]'; ...
    'Positive Capacity [lb-in]'; 'Negative Capacity [psi]'; 'Positive Ix [in^4]';...
    'Negative Ix [in^4]';'Positive Section Area [in^2]'; 'Negative Section Area [in^2]';...
    'Dia Section';'Controlling St1 Rating';'Controlling Sv2 Rating'};               
end

% Set initialization defaults/fields --------------------------------------
try
    handles = Options.handles.guiBuildRAMPSModel;
    switch state
        case 'Init'
            % NBI
            if isfield(Parameters, 'NBI')
                if ~isempty(Parameters.NBI)
                    % ASD
                    if strcmp(Parameters.NBI.DesignCode, 'ASD')
                        % Design Codes
                        set(handles.radiobtnDesign_ASD, 'Value', 1, 'enable', 'inactive');
                        set(handles.radiobtnDesign_LRFD, 'Value', 0, 'enable', 'on');
                        % Design Trucks
                        tempcd = pwd; cd('../');
                        load([pwd '\Tables\GUI\GuiInit.mat'], 'DesignTruckList'); cd(tempcd);
                        set(handles.popupDesignTruck, 'String', DesignTruckList);
                        % Design Load
                        if str2double(Parameters.NBI.DesignLoad) >= 1 && str2double(Parameters.NBI.DesignLoad) <= 6
                            set(handles.popupDesignTruck, 'Value', str2double(Parameters.NBI.DesignLoad));
                        else
                            set(handles.popupDesignTruck, 'Value', 6);
                        end
                    % LRFD
                    else
                        % Design Codes
                        set(handles.radiobtnDesign_ASD, 'Value', 0, 'enable', 'on');
                        set(handles.radiobtnDesign_LRFD, 'Value', 1, 'enable', 'inactive');
                        % Design Trucks
                        set(handles.popupDesignTruck, 'String', {'HL-93'});
                        set(handles.popupDesignTruck, 'Value', 1);
                    end
                    % Design Loads
                    Parameters.Design = GetTruckLoads(Parameters.Design);
                end
            end
            % Set Girder Table            
                set(handles.GirderTable,'data',data);
            % Set Defaults/fields
                % Model Type (Default = Automated)
                set(handles.Radiobtn_RAMPS, 'Value', 1);
                % Design Code (Default = LRFD)
                set(handles.radiobtnDesign_LRFD, 'Value', 1);
                % Design Truck (Default = HL-93)
                set(handles.popupDesignTruck, 'String', {'HL-93'});
                set(handles.popupDesignTruck, 'Value', 1);
                % Section Build Type (Default = Seperate)
                set(handles.Radiobtn_Seperate, 'Value', 1);
                % Span to Depth
                set(handles.editMaxSpantoDepth, 'String', 20);
                % Total width
                set(handles.textOutToOutWidth, 'String', Parameters.Width);
                % Cover plate
                if Parameters.Spans == 1
                    set(handles.editCoverPlateDesignLength, 'Value', 0, 'enable', 'off');
                    set(handles.textCPratio,'enable','off');
                    set(handles.checkboxCoverPlate, 'enable', 'off');
                    Parameters.Beam.CoverPlate.Ratio = 0;
                else
                    set(handles.editCoverPlateDesignLength, 'String', Options.Default.CoverPlateLength);
                end 
                % Set girder spacing to inactive if NBI data is applies
                if strcmp(Parameters.Geo,'NBI')
                    set(handles.editGirderSpacing, 'enable', 'off');
                end
            
% Restore Previous Options/fields -----------------------------------------
        case 'Update'
            % Restore button options
                % Model Type
                if strcmp(Parameters.ModelType, 'RAMPS Design')
                    set(handles.Radiobtn_RAMPS, 'Value', 1);
                    set(handles.Radiobtn_Manual, 'Value', 0);
                else
                    set(handles.Radiobtn_Manual, 'Value', 1);
                    set(handles.Radiobtn_RAMPS, 'Value', 0);
                end
                % Design Code
                if strcmp(Parameters.Design.Code, 'LRFD')
                    Code = 'LRFD';
                    set(handles.radiobtnDesign_LRFD, 'Value', 1);
                    set(handles.radiobtnDesign_ASD, 'Value', 10);
                    set(handles.popupDesignTruck, 'String', {'HL-93'});
                    set(handles.popupDesignTruck, 'Value', 1);
                else
                    Code = 'ASD';
                    set(handles.radiobtnDesign_ASD, 'Value', 1);
                    set(handles.radiobtnDesign_LRFD, 'Value', 0);
                end
                % Section Build Type
                if strcmp(Parameters.Beam.Des, 'Separate Section')
                    set(handles.Radiobtn_Seperate, 'Value', 1);
                else
                    set(handles.Radiobtn_all, 'Value', 1);
                end
            % Restore Girder criteria
                set(handles.editNumGirder,'string',num2str(Parameters.NumGirder));
                set(handles.editGirderSpacing,'string',num2str(Parameters.GirderSpacing));
                set(handles.textTotalWidth,'string',num2str(Parameters.TotalWidth));
                set(handles.textOverhang,'string',num2str(Parameters.Overhang));
            % Resotre girder table data
                Section = {'Int';'Ext'};
                if Parameters.Spans == 1
                    for jj = 1:2
                        data(:,jj+1) = {Parameters.Beam.(Section{jj}).d; Parameters.Beam.(Section{jj}).bf; Parameters.Beam.(Section{jj}).tf; Parameters.Beam.(Section{jj}).tw;...
                            Parameters.Beam.(Section{jj}).Mn_pos; Parameters.Beam.(Section{jj}).I.Ix; Parameters.Beam.(Section{jj}).A; Parameters.Dia.SectionName;...
                            [num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).St1.RFInv_pos)) '/' num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).St1.RFOp_pos))];...
                            [num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Sv2.RFInv_pos)) '/' num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Sv2.RFOp_pos))]};          
                    end
                else
                    for jj = 1:2
                        data(:,jj+1) = {Parameters.Beam.(Section{jj}).d; Parameters.Beam.(Section{jj}).bf; Parameters.Beam.(Section{jj}).tf; Parameters.Beam.(Section{jj}).tw;...
                            Parameters.Beam.(Section{jj}).CoverPlate.Length; Parameters.Beam.(Section{jj}).CoverPlate.t;...
                            Parameters.Beam.(Section{jj}).Mn_pos; Parameters.Beam.(Section{jj}).Fn_neg; Parameters.Beam.(Section{jj}).I.Ix;Parameters.Beam.(Section{jj}).CoverPlate.I.Ix;...
                            Parameters.Beam.(Section{jj}).A; Parameters.Beam.(Section{jj}).CoverPlate.A; Parameters.Dia.SectionName;...
                            [num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).St1.Inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).St1.Op))];...
                            [num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Sv2.Inv)) '/' num2str(min(Parameters.Rating.(Code).SL.(Section{jj}).Sv2.Op))]};         
                    end
                end
                set(handles.GirderTable,'data',data);
            % Restore coverplate option
            if ~strcmp(Parameters.ModelType, 'Manual') && Parameters.Spans > 1
                if Parameters.Beam.Int.CoverPlate.Length > 0
                    set(handles.checkboxCoverPlate, 'value', 1);
                    set(handles.editCoverPlateDesignLength, 'string', Parameters.Beam.Int.CoverPlate.Ratio);
                end
            end
            
    end
catch
end

end