setPath();


folder='/Users/dkleindienst/Documents/MATLAB/findSynapses/Peters_sample001/';
scale=0.61109;
py.gpdqConfigfromShotmeister.run(folder,scale);
datfile=fullfile(folder,'Config.dat');
makeIm16Bit(datfile);
defaults=readDefaults();
defaults=updateDefaults(getOptionsName(datfile),defaults);
[routes,scales] = readConfig(datfile);
partsizes=sort(defaults.particleTypes,'descend');
partsizes=[5];
minwanted=[5];

%Confirm contrast with user:
[~, im]=getBaseImages([fullfile(folder,routes{2}) '.tif']);
[minimum,maximum]=userGetContrast(im);

if 0
parfor img=1:numel(routes)
    fprintf(['Now processing ' routes{img} ' ...\n']);
    route=fullfile(folder, routes{img});
    [mask, im]=getBaseImages([route '.tif'], [route '_mod.tif']);
    mask=imcomplement(mask);
    imR=imref2d(size(im),scales(img),scales(img));
    centers=cell(1,numel(partsizes));
    particlesFound=zeros(1,numel(partsizes));
    for r=1:numel(partsizes)
       centers{r}=detectParticles(im,mask,imR,scales(img),defaults.sensitivity,partsizes(r)/2,defaults.marginNm,0,1);
       particlesFound(r)=numel(centers{r});
    end
    if all(particlesFound>=minwanted)
        figure;imshow(im,imR)
        fprintf(['found' routes{img} '\n']);
    end
end
end