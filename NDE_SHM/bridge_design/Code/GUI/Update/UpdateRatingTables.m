function UpdateRatingTables(Parameters, Options, State)
if isempty(Parameters)
    Parameters = getappdata(0, 'Parameters');
end
if isempty(Options)
    Options = getappdata(0, 'Options');
end

try
    handles = Options.handles.UserInputDeck_gui;
    
    switch State
        case 'Init'
    
% crawl steps
set(handles.editCrawlSteps, 'String', str2double(Options.LoadPath.CrawlSteps));

end 