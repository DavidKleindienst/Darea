function tMatrix = findRigidTransform(p,q)
simple=1;
assert(all(size(p)==size(q)));
if simple
%% Simple 2 point version
% If more than 2 points are given, only first 2 are used

%get angles between the two points of each image
rP=[p(1,1),p(2,2)];     %Missing point for a rectangular Triangle
hyp=sqrt((p(1,1)-p(2,1))^2+(p(1,2)-p(2,2))^2);
a=sqrt((rP(1)-p(2,1))^2+(rP(2)-p(2,2))^2);
angleP=asind(a/hyp);


if (p(1,1)>p(2,1) && p(1,2)<p(2,2)) || (p(1,1)<p(2,1) && p(1,2)>p(2,2))
    %correct angle if in quadrant 2 or 3
    angleP=180-angleP;
end

%same for points q

rQ=[q(1,1),q(2,2)];
hyp=sqrt((q(1,1)-q(2,1))^2+(q(1,2)-q(2,2))^2);
a=sqrt((rQ(1)-q(2,1))^2+(rQ(2)-q(2,2))^2);
angleQ=asind(a/hyp);

if (q(1,1)>q(2,1) && q(1,2)<q(2,2)) || (q(1,1)<q(2,1) && q(1,2)>q(2,2))
    angleQ=180-angleQ;
end


rotationAngle=angleQ-angleP;

%apply the rotation
R=[cosd(rotationAngle), sind(rotationAngle);-sind(rotationAngle),cosd(rotationAngle)];
R=[R;0,0];
R=[R [0;0;1]];
q=transformPointsForward(affine2d(R),q);

%Now work out tranlation
t=[(p(1,1)-q(1,1)+p(2,1)-q(2,1))/2, (p(1,2)-q(1,2)+p(2,2)-q(2,2))/2];       %Translate such that first points of each image are on top of each other
%make the tranformation matrix

T=[1,0,0;0,1,0;t,1];
%Final Transformation Matrix is made up of both translation and rotation
tMatrix=R*T;

else
%Works for any number of points, but doesn't work at all (probably something wrong with translation caused by rotation not being accounted for).

centroid1=mean(p)
centroid2=mean(q)



N = size(p,1);
p - repmat(centroid1, N, 1)
q - repmat(centroid2, N, 1)

H = (p - repmat(centroid1, N, 1))' * ((q - repmat(centroid2, N, 1)))

[u,~,v]=svd(H)

R=v*u'

if det(R) < 0
    'msg'
    v(:,2) = v(:,2)*-1;     %Changed from (:,3) to (:,2) to adapt for 2d, however not sure if that's correct way
    R = v*u';                %->extensive testing should be done
end

t = -R*centroid1' + centroid2'

tMatrix=[R;t'];
tMatrix=[tMatrix [0;0;1]];
end
end

