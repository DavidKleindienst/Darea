function overlaidImage=overlayImage(image,overlayColor,transparency)
    %% Creates a color overlay over the image
    % Input arguments
    % image - the image to be overlaid
    % overlayColor - The rgb color code for the overlay
    % transparancy - Value between 0 and 1 to indicate the transparency of the overlay color
    %Make rgb image matrix of same size as image with each element
    %px being overlayColor
    overlay=reshape(repelem(overlayColor,size(image,1),size(image,2)),size(image));
    overlay=im2uint16(overlay);
    %Devide image and color by 2 to avoid capping problem later
    image=image./2;
    overlay=overlay./2;
    %Overlaid image is the weighted mean (weight=transparency) of
    %Original Color and overlay at each px
    weightImage=2*transparency;
    weightColor=2*(1-transparency);

    overlaidImage=mean(cat(4,image.*weightImage,overlay.*weightColor),4);
    overlaidImage=overlaidImage.*2;   %Multiply with 2 to get back to original colors
    overlaidImage=round(overlaidImage);     %Image pxs are integers
end