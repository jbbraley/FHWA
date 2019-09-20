function PlotMAC(plotType)
try
% get data from root
Options = getappdata(0,'Options');
meshData = getappdata(0,'meshData');
testData = getappdata(0,'testData');

handles = Options.handles.ModelExperimentComparison_gui;

x = testData.x;
y = testData.y;
xB = testData.xB;
yB = testData.yB;

% Repopulate experimental mode shape plot
switch plotType
    case 'Ana'
        Parameters = getappdata(0,'Parameters');

        gridSize = max([Parameters.Model.OMeshSize, Parameters.Model.WMeshSize, Parameters.Model.LMeshSize]);
        xmin = min(meshData.x);
        ymin = min(meshData.y);
        xmax = max(meshData.x);
        ymax = max(meshData.y);

        MAC = meshData.MAC;

        % Build 3-d colormap for MAC
        RGB_high = colormap;
        RGB_high_ind = ceil(MAC*length(RGB_high));
        MAC_new = zeros(size(MAC,1), size(MAC,2), 3);
        for i=1:size(MAC,1)
            for j=1:size(MAC,2)
                MAC_new(i,j,:) = RGB_high(RGB_high_ind(i,j),:);
            end
        end
        
        % add low saturation colors in unwanted mode rows
        RGB_low = RGB_high;
        HSV = rgb2hsv(RGB_high);
        HSV_2 = 0.3*(rgb2hsv(RGB_high));
        HSV(:,2) = HSV_2(:,2);
        RGB_low = hsv2rgb(HSV);
        RGB_low_ind = ceil(MAC*length(RGB_low));
        for i=1:size(MAC,1)
            if i~=Options.Correlation.expModes
                for j=1:size(MAC,2)
                    MAC_new(i,j,:) = RGB_low(RGB_low_ind(i,j),:);
                end
            end
        end

        ah1 = handles.axesExpAnaMAC;
        ah2 = handles.axesExpAnaCOMAC;
        imData1 = MAC_new;
        imData2 = meshData.COMAC;
    case 'Exp'
        gridSize = 36; 
        xmin = min(testData.x);
        ymin = min(testData.y);
        xmax = max(testData.x);
        ymax = max(testData.y);
        
        ah1 = handles.axesExpExpMAC;
        ah2 = handles.axesExpExpCOMAC;
        imData1 = testData.MAC;
        imData2 = testData.COMAC;       
end
axes(ah1)
imagesc(imData1);
colorbar('EastOutside');
caxis([0 1]) 

%% COMAC Interpolation
% Define the resolution of the grid:
xres=round((xmax - xmin)/gridSize);
yres=round((ymax - ymin)/gridSize);

% Define the range and spacing of the x- and y-coordinates,
% and then fit them into X and Y:
xv = linspace(xmin, xmax, xres);
yv = linspace(ymin, ymax, yres);
[Xinterp,Yinterp] = meshgrid(xv,yv);

% Calculate Z in the X-Y interpolation space, which is an
% evenly spaced grid:
Zinterp_ana = griddata(x,y,imData2,Xinterp,Yinterp,'v4');

% mask out COMAC
xVec = [xB(1) xB(length(xB)/2) xB(end)  xB(length(xB)/2+1) ];
yVec = [min(yB) max(yB) max(yB) min(yB)];
maskCOMAC = inpolygon(Xinterp,Yinterp,xVec-gridSize,yVec);

Z = Zinterp_ana.*maskCOMAC;
% Generate the mesh plot (CONTOUR can also be used):
axes(ah2)
imagesc(Z)
set(gca,'YDir','normal');
hold on
scatter((x-xmin)/gridSize, (y-ymin)/gridSize, 20, imData2, 'fill', 'MarkerEdgeColor', 'k')
scatter((xB-xmin)/gridSize, (yB-ymin)/gridSize, 10, 'k', 'fill')
colorbar('EastOutside');
caxis([0 1]) 
catch
end
end