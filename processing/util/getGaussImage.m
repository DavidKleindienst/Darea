function  gaussIm= getGaussImage(particles,sigma,range)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
numP=size(particles,1);
if numP<1
    gaussIm=zeros(range);
    gaussIm=gaussIm';
    return
end
gaussIm=gauss2d(particles(1,:),sigma,range);
for i=2:numP
    gaussIm=max(gaussIm,gauss2d(particles(i,:),sigma,range));
end
end

