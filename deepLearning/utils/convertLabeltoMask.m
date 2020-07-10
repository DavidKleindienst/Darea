function mask = convertLabeltoMask(originalIm,labeledIm,largestComponentOnly)
%% Converts a labeled image received from the deepLearning back to a usable mask with same size as original image
mask=zeros(size(labeledIm));
mask(labeledIm=='background')=1;
origSize=size(originalIm);
if any(size(mask)~=origSize)
    %Proportional resize of square image to smaller dimension of original
    [~, idx]=min(origSize./size(mask));
    mask=imresize(mask,[origSize(idx) origSize(idx)]);
    if any(size(mask)~=origSize)
       %Fill remaining part of image with zeros
       idx=abs(idx-2)+1; %if idx is 1, make 2 and vice versa
       toFill=origSize(idx)-size(mask,idx);
       %If uneven, fill one more row at the higher index (as prepareImage.m
       %would cut one more at the higher index)
       fillLeft=zeros(floor(toFill/2));
       fillRight=zeros(ceil(toFill/2));
       if idx==1
           mask=[fillLeft mask fillRight];
       else
           mask=[fillLeft'; mask; fillRight'];
       end
    end
end    
assert(all(size(mask)==origSize))

if largestComponentOnly
    mask=imcomplement(mask);
    CC = bwconncomp(mask);
    numOfPixels = cellfun(@numel,CC.PixelIdxList);
    [~,indexOfMax] = max(numOfPixels);
    biggest = zeros(size(mask));
    biggest(CC.PixelIdxList{indexOfMax}) = 1;
    mask=imcomplement(biggest);
end


mask=uint16(mask);
mask(mask==1)=65535;
mask(mask==0)=10000;
end

