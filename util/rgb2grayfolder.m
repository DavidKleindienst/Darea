function rgb2grayfolder(inputfolder,outputfolder)
fs=dir(inputfolder);
safeMkdir(outputfolder);
for i=1:numel(fs)
   image_in=fullfile(inputfolder,fs(i).name);
   if ~startsWith(fs(i).name,'.') && isfile(image_in)
       try
       im=imread(image_in);
       catch
           image_in
       end
       im=rgb2gray(im);
       imwrite(im,fullfile(outputfolder,fs(i).name));
   end
end

end