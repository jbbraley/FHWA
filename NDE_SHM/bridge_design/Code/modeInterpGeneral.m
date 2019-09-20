function modeInterpGeneral(ah,x, y, z, xb, yb, zb, scale,C)
% SYNTAX: modeInterp(ah, x, y, z, xb, yb, zb, scale, C)
%
%   Creates 4th order interpolation plot from incomplete modal/spatial
%   data. Returns figure handle
%  
%   ah      axes handle
%   x       DOFi x coordinates      (vector)
%   y       DOFi y coordinates      (vector)
%   z       DOFi modal amplitude    (vector)
%   xb      x boundary coordinates  (vector)
%   yb      y boundary coordinates  (vector)
%   scale   modal scaling factor (visual only)
%   C       color vector equal length as z
%  
%   jdv  /   johndevitis@gmail.com   /    11/26/2012; 2/3/13;


%concat geometry
xTot = [x;xb];
yTot = [y;yb];
zTot = [z;zb];
CTot = [C;ones(length(xb),1)];

%define resolution
xres = 75;
yres = 75;

%interp
xv = linspace(min(xTot), max(xTot),xres);
yv = linspace(min(yTot), max(yTot),yres);
[xInterp,yInterp] = meshgrid(xv,yv);
zInterp = griddata(xTot,yTot,zTot,xInterp,yInterp,'v4');
if isempty(C)
    CInterp = zInterp;
else
CInterp = griddata(xTot,yTot,CTot,xInterp,yInterp,'v4');
end

%plot initial mesh

mesh(ah,xInterp,yInterp,zInterp*scale,CInterp);       %draw mesh
axis(ah,'equal');                             %set axes proportional
% xlabel(ah,'X-Coordinate [ft]');               %clean up  
% ylabel(ah,'Y-Coordinate [ft]');
% zlabel(ah,'Modal Amplitude'); 
set(ah,'ZTickLabel','','ZTick',[]);
hold(ah,'on');        

%overlay DOF in red
plot3(ah,x,y,z*scale,'marker','o',...              
                     'markerfacecolor','r',...
                     'linestyle','none')
              
%overlay boundaries in black
plot3(ah,xb,yb,zb, 'marker','.',...
                   'color','k',...
                   'linestyle','none');
hidden off
hold(ah,'off');

% set default view angle
set(ah,'view',[-48 18]);

formatColorScheme(ah);