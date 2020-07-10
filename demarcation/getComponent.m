function componentImage = getComponent(componentImage,coordinates)
%% Returns the connected Component that is at the coordinates
% Gets rid of all other connected components
% returns false if no component is at these coordinates
comp=bwlabel(componentImage);
%Get component id
cNr=comp(coordinates(2),coordinates(1));
if cNr==0
    componentImage=NaN;
    return
end
componentImage(comp~=cNr)=0;

end

