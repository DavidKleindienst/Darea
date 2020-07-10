%% 
% Copyright (C) 2015 Javier C??zar (*), David Kleindienst (#), Luis de la Ossa (*), Jes??s Mart??nez (*) and Rafael Luj??n (+).
%
%   (*) Intelligent Systems and Data Mining research group - I3A -Computing Systems Department
%       University of Castilla-La Mancha - Albacete - Spain
%
%   (#) Institute of Science and Technology (IST) Austria
%
%   (+) Celular Neurobiology Lab - Faculty of Medicine
%       University of Castilla-La Mancha - Albacete - Spain
%
%  Contact: Luis de la Ossa: luis.delaossa@uclm.es
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%  
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%  
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

function intersect=polygonIntersection(polyA,polyB)
%% Computes the outlining points of the overlapping area of polygon A and polygon B

pAx=polyA(:,1);
pAy=polyA(:,2);
pBx=polyB(:,1);
pBy=polyB(:,2);

if numel(pAx)<3 || numel(pAy)<3
    error('Polygons must have at least 3 points');
end

% Get all points of A inside B and vice versa
AinB=[];
BinA=[];
for p=1:size(pAx)
    if inpolygon(pAx(p),pAy(p),pBx,pBy)
        AinB=[AinB;polyA(p,:)];
    end
end
for p=1:size(pBx)
    if inpolygon(pBx(p),pBy(p),pAx,pAy)
        BinA=[BinA;polyB(p,:)];
    end
end

if isempty(AinB) && isempty(BinA)       %If there are no points of A in B or vice versa, return NaN
    intersect=NaN;
elseif isequal(AinB,polyA)          %If one of the polygons lies within the other, return that polygon
    intersect=polyA;
elseif isequal(BinA,polyB)
    intersect=polyB;
else                
    %get Outline particles
    chA=convhull(pAx,pAy);
    chB=convhull(pBx,pBy);
    OutlineA=[pAx(chA),pAy(chA)];
    
    OutlineB=[pBx(chB),pBy(chB)];

    S=[];
    for idxA=2:size(OutlineA,1)         
        for idxB=2:size(OutlineB,1)
            s=intersection2Lines(OutlineA(idxA-1:idxA,:),OutlineB(idxB-1:idxB,:));  %compute intersections for all pairs of lines
            if ~isnan(s)
                S=[S;s];        %if the intersection exits, save the intersection point
            end
        end
    end

    intersect=[AinB;BinA;S];    %the particles that form the outline of the intersection

end
    