function g = gauss2d(mu,sigma,range)
%Mu: [x, y]
%range: [x, y]
x=1:range(1); 
y=1:range(2); y=y';
g=exp(-((x-mu(1)).^2/(2*sigma^2) + (y-mu(2)).^2/(2*sigma^2)));
end

