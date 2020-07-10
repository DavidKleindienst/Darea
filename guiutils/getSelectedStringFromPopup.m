function string = getSelectedStringFromPopup(hObj)
%Get the selected string from an uicontrol hObj with Style popup
strs=get(hObj, 'String');
string=strs{get(hObj, 'Value')};

end

