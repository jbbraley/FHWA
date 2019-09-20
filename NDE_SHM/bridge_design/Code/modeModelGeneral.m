function modeModelGeneral(ah,x,y,z,scale,C)
%% Plots the coordinate and modal amplitude data of the nodes from a st7 model
% ah - axes handle
% x, y - the x and y coordinates in vector form (nx1 with n = number of nodes)
% z - modal amplitude of every node (nx1)
% C - color vector equal in size to z
% scale - value by which the plot is scaled
% JBB - 6/30/2014


tri = delaunay(x,y);
    
hold(ah,'off');
axes(ah);
if ~isempty(C)
    trimesh(tri,x,y,z*scale,C);
else
    trimesh(tri,x,y,z*scale);
end

%         hold(ah,'on');
%     if ~isempty(testData)
%         validNode = ~isnan(testData.U(:,slideVal(2)));
%         x = testData.coord(validNode,1);
%         y = testData.coord(validNode,2);
%         z = testData.U(validNode,slideVal(2));
%         
%         %overlay DOF in red
%         plot3(ah,x,y,z,'marker','o',...
%             'markerfacecolor','r',...
%             'linestyle','none');
%     end

axis(ah,'fill');
axis(ah, 'equal')
          % set axes proportional
% Get coord extremes
xlim(ah,[min(x) max(x)]);
ylim(ah,[min(y) max(y)]);
%     zlim(ah,[-1, 1]);
set(ah,'ZTickLabel','','ZTick',[]);
set(ah,'view',[-48 18]);
hidden off

formatColorScheme(ah);