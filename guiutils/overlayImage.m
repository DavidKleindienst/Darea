function overlaidImage=overlayImage(im,overlayColor,transparency)
    %Make rgb image matrix of same size as image with each element
    %px being overlayColor
    overlay=reshape(repelem(overlayColor,size(im,1),size(im,2)),size(im));
    overlay=im2uint16(overlay);
    %Devide image and color by 2 to avoid capping problem later
    im=im./2;
    overlay=overlay./2;
    %Overlaid image is the weighted mean (weight=transparency) of
    %Original Color and overlay at each px
    weightImage=2*transparency;
    weightColor=2*(1-transparency);

    overlaidImage=mean(cat(4,im.*weightImage,overlay.*weightColor),4);
    overlaidImage=overlaidImage.*2;   %Multiply with 2 to get back to original colors
    overlaidImage=round(overlaidImage);     %Image pxs are integers
end