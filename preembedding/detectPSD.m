function detectPSD(images,x,y,z)
%DETECTPSD Summary of this function goes here
%   Detailed explanation goes here

im=images{z};

figure;imshow(im)
figure;imshow(imguidedfilter(im))
figure;imshow(edge(im))
end

