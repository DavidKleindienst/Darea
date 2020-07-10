function [min,max] = userGetContrast(image)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
h1=figure; imshow(image);

hfig=imcontrast(h1);

set(hfig, 'CloseRequestFcn', @(s,e)getValues(s))

function getValues(hfig)
    min = str2double(get(findobj(hfig, 'tag', 'window min edit'), 'String'));
    max = str2double(get(findobj(hfig, 'tag', 'window max edit'), 'String'));
    delete(hfig)
end

waitfor(hfig);
close all
end

