function formatColorScheme(fh)
%% function formatColorScheme(fh)
% fh = figure handle (hObject if in opening function)
%
% jdv 2/24/14
% 
%% Color Scheme
foreC = [1 1 1];                    % default foreground color
backC = [.3137 .3137 .3137];        % default background color
pbBackC = [.2353 .2353 .2353];      % pushbutton background color
shadowC = [.5 .5 .5];               % shadow color for UI panel
axesC = [.8 .8 .8];                 % axes color
tabBackC = [.9 .9 .9; .8 .8 .8];    % table background color w/ row striping 
tabForeC = [0 0 0];                 % table data color
slidForeC = [1 1 1];
slidBackC = [.8 .8 .8];

%% Figure
set(fh,'color', backC);         % set figure color


%% UI Panels
panH = findall(fh,'type','uipanel');        % get handles of ui panels

set(panH,'foregroundColor',foreC,...        % assign values
         'backgroundColor',backC,...
         'shadowcolor'    ,shadowC);
     
%% Slider control
slidH = findall(fh,'style','slider');

set(slidH,'foregroundcolor',slidForeC,...
          'backgroundcolor',slidBackC);
     
%% Listbox
listH = findall(fh,'style','listbox');

set(listH,'backgroundcolor',axesC);
     
%% UI Table
tabH = findall(fh,'type','uitable');

set(tabH,'foregroundcolor',tabForeC,...
         'backgroundcolor',tabBackC);
     
%% Axes and labels
ah = findall(fh,'type','axes');

set(ah,'color' ,axesC,...
       'xcolor',foreC,...
       'ycolor',foreC,...
       'zcolor',foreC);

%% Pushbuttons
pushH = findall(fh,'style','pushbutton');   

set(pushH,'foregroundcolor',foreC,...       
          'backgroundcolor',pbBackC);
      
%% Edit text
editH = findall(fh,'style','edit');

set(editH,'backgroundcolor',axesC);

%% Radiobuttons
radH = findall(fh,'style','radiobutton');

set(radH,'foregroundcolor',foreC,...
         'backgroundcolor',backC);
     
%% Text
textH = findall(fh,'style','text');

set(textH,'foregroundcolor',foreC,...
          'backgroundcolor',backC);
      
