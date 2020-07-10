function rotateSavedImage(route,scale,angle,rotateMod,rotateDots)
%ROTATESAVEIMAGE Summary of this function goes here
%   Angle has to be a multiple of 90

angle=mod(angle,360);
if ~angle
    %angle is a multiple of 360, do nothing
    return;
end

image=imread([route '.tif']);
imwrite(imrotate(image,-angle),[route '.tif']);

if rotateDots && isfile([route 'dots.csv'])
    dotsfile=[route 'dots.csv'];
    P=(size(image)+1)./2.*scale;    %Centerpoint of rotation in nm
    [centers,radii,teorRadii,numParticles]=readDotsFile(dotsfile);
    
    for i=1:angle/90
        %rotate i times by 90°
        centers=rotatePoints(P,centers);
    end
    
    fid = fopen(dotsfile, 'wt');     
    for i=1:numParticles
        fprintf(fid,'%.4f, %.4f, %.4f, %.1f\n',centers(i,1), centers(i,2), radii(i),teorRadii(i));
    end
    fclose(fid);  
end

if rotateMod && isfile([route '_mod.tif'])
   image=imread([route '_mod.tif']);
   imwrite(imrotate(image,-angle),[route '_mod.tif']);
end

end

