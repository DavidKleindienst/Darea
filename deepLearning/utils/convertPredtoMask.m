function mask = convertPredtoMask(image,targetSize,backgroundColor)
%CONVERTPREDTOMASK Summary of this function goes here
%   Detailed explanation goes here
if nargin<3
    backgroundColor=50;
end
image=rgb2gray(image);
mask=zeros(size(image));
mask(image==backgroundColor)=1;

mask=imresize(mask,targetSize);
mask=uint16(mask);
mask(mask==1)=65535;
mask(mask==0)=10000;

end

