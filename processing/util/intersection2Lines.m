function S=intersection2Lines(A,B)
%% Computes the Point of intersection of two lines A and B described by two points each
%returns NaN if lines are parallel

%get lines in format y=kx+d
[k_A,d_A]=getLine(A);
[k_B,d_B]=getLine(B);

%get interception

if isnan(k_A) && isnan(k_B)     %Both lines parallel to y-Axis
    S=NaN;           %If lines are parallel, return NaN
    return
elseif isnan(k_A)  %line A parallel to y-Axis     
    x=d_A;
    y=k_B*x+d_B;
elseif isnan(k_B)   %line B parallel to y-Axis
    x=d_B;
    y=k_A*x+d_A;
elseif k_A-k_B==0
    S=NaN;          %If lines are parallel, return NaN
    return
else
    x=(d_B-d_A)/(k_A-k_B);
    y=k_A*x+d_A;
end

%Check if Interception point (x,y) is between the points describing the lines
flagA=0;        %FlagA==1 -> point lies on line A
flagB=0;        %FlagB==1 -> point lies on line B
if (x>=A(1,1) && x<=A(2,1)) || (x<=A(1,1) && x>=A(2,1))        
    if (y>=A(1,2) && y<=A(2,2)) || (y<=A(1,2) && y>=A(2,2))
        flagA=1;
    end
end
if (x>=B(1,1) && x<=B(2,1)) || (x<=B(1,1) && x>=B(2,1))        
    if (y>=B(1,2) && y<=B(2,2)) || (y<=B(1,2) && y>=B(2,2))
        flagB=1;
    end
end

if flagA==1 && flagB==1
    S=[x,y];
else
    S=NaN;
end
