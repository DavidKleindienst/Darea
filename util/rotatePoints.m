function points = rotatePoints(rotCenter,points)
%% rotates points 90° around rotCenter
if isempty(points)
    return;
end

%Create rotation/translation matrix
T=[1,0,rotCenter(1);0,1,rotCenter(2);0,0,1];

rot=[0,-1,0;1,0,0;0,0,1];


rt=T*rot/T;

%Add a Z coordinate to points
points(:,3)=1;

%Do rotation
points=(rt*points')';

%Now remove new Z coordinate
points(:,3)=[];

end

