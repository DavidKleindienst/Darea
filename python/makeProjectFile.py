#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 21 13:21:32 2018

@author: dkleindienst
"""
import os
from shutil import copyfile
from file_utils import file_utils


def getMag(filename):
    mags=dict()
    with open(filename, 'r') as f:
        l=f.readline()
        while l!='':
            l=l.strip('\n')
            l=l.split('\t')
            mags[l[0]]=l[1]
            l=f.readline()
    return mags

def rchop(string, suffix):
    #Remove suffix from string
    if suffix and string.endswith(suffix):
        return string[:-len(suffix)]
    return string

def getImages(folder,subfolder,mags,output,onlyMod=False,separator='_',defaultMag=False):
    #DefaultMag only takes effect when using a dict for mags and no Magnification was found in image Name
    #defaultMag: False -> Image will be skipped
    #defaultMag: int, float or str -> This will be the Mag (even if the value is 0 or an empty string)
    #defaultMag: other type -> same as False
    files=os.listdir(os.path.join(folder,subfolder))
    files=sorted([f for f in files if not f.startswith('.')], key=lambda x:x.lower())
    for fn in files:
        if fn.endswith('.TIF'):
            os.rename(os.path.join(folder,subfolder,fn), os.path.join(folder,subfolder,fn[:-3]+'tif'))
            fn=fn[:-3]+'tif'
        elif fn.endswith('.TIFF'):
            os.rename(os.path.join(folder,subfolder,fn), os.path.join(folder,subfolder,fn[:-4]+'tif'))
            fn=fn[:-4]+'tif'
        elif fn.endswith('.tiff'):
            os.rename(os.path.join(folder,subfolder,fn), os.path.join(folder,subfolder,fn[:-4]+'tif'))
            fn=fn[:-4]+'tif'
        if onlyMod:
            if fn.endswith('?mod.tif'):
                os.rename(os.path.join(folder,subfolder,fn), os.path.join(folder,subfolder, rchop(fn,'?mod.tif')+'_mod.tif'))
            if fn.endswith('_mod.tif'):
                fn=rchop(fn,'_mod.tif')
                fs=fn.split(separator)
                found=False
                for x in fs:
                    if x in mags.keys():
                        output.append(subfolder +',\t' + subfolder+'/'+fn+',\t' + str(mags[x]))
                        found=True
                        break
                if not found and defaultMag is not False and type(defaultMag) in [int, float, str]:
                    output.append(subfolder +',\t' + subfolder+'/'+fn+',\t' + str(defaultMag))
        else:
            if fn.endswith('.tif'):
                if fn.endswith('_dupl_mod.tif'):
                    fn=rchop(fn,'_mod.tif')
                elif fn.endswith('_mod.tif'):
                    continue
                else:
                    fn=rchop(fn,'.tif')
                if type(mags) in [int, float, str]:
                    output.append(subfolder +',\t' + subfolder+'/'+fn+',\t' + str(mags))
                elif type(mags)==dict:
                    fs=fn.split(separator)
                    found=False;
                    for x in fs:
                        if x in mags.keys():
                            output.append(subfolder +',\t' + subfolder+'/'+fn+',\t' + str(mags[x]))
                            found=True;
                            break
                    if not found and defaultMag is not False and type(defaultMag) in [int, float, str]:
                        output.append(subfolder +',\t' + subfolder+'/'+fn+',\t' + str(defaultMag))
                    
    return output

def getSerialEMImages(folder,subfolder,output,ext='.st'):
    files=os.listdir(os.path.join(folder,subfolder))
    files=sorted([f for f in files if f.endswith(ext) and not f.startswith('.')], key=lambda x:x.lower())
    for fn in files:
        pixelsize,angles=readMdoc(os.path.join(folder,subfolder,fn+'.mdoc'))
        output.append(subfolder +',\t' + subfolder+'/'+fn+',\t' + str(pixelsize)+',\t' + ':'.join([str(a) for a in angles]) + ',\t'+ '0')
    
    return output

def _convertLineToNum(line):
    #Helper function for readMdoc
    #Extracts the part after the =
    #And converts to float
    return float(line.split('=')[1].strip())
    

def readMdoc(file):
    angles=[]
    pixelspacing=[]
    with open(file) as f:
        line=f.readline()
        
        while(line):
            if line.startswith('PixelSpacing'):
                pixelspacing.append(_convertLineToNum(line))
            elif line.startswith('TiltAngle'):
                angles.append(_convertLineToNum(line))
            line=f.readline()
            
    if len(set(pixelspacing))>1:
        raise ValueError('Image {} cannot be read as in contains multiple different pixelsizes'.format(file)) 
        
    pixelsize=pixelspacing[0]*0.1 #Pixelspacing is in Angstrom -> convert to nm
    
    return pixelsize,angles

def run(folder,mags=1,outputName='Config.dat',serialEM=False,**kwargs):
    subdirs = next(os.walk(folder))[1]
    if serialEM:
        output=['GROUP,\tROUTE,\tPIXELSIZE,\tANGLES,\tSELECTED']
    else:
        output=['GROUP,\tROUTE,\tPIXELSIZE']
    for d in subdirs:
        if d[0]!='.':
            if serialEM:
                output=getSerialEMImages(folder,d,output,**kwargs)
            else:
                output=getImages(folder,d,mags,output,**kwargs)
    if len(output)>1:
        output='\n'.join(output)
        with open(os.path.join(folder,outputName), 'w') as f:
            f.write(output)
            

def removeImage(configFile,index):
    '''Removes image with index from Darea project'''
    #index starts from 0
    
    if type(index)==int:
        index=[index]
    elif type(index)==list:
        index.sort(reverse=True)
    else:
        print('Index needs to be an integer or a list of integers. Got {} with type {}'.format(index,type(index)));
        return
    
    images=file_utils.file2dict(configFile,',\t')
    for idx in index:
        for i in images:
            del(images[i][idx])
    file_utils.dict2file(configFile,images,',\t')
    
def copyTestImages(all_configs,sourcefolder,destinationfolder,modsuffix=''):
    #Get the names of individual image files
    imgFiles=file_utils.file2dict(all_configs,';')['Name']
    for f in imgFiles:
        iPath=os.path.join(os.path.split(all_configs)[0],f[0:-3]+'csv')
        images=file_utils.file2dict(iPath,';')
        imgs=images['OriginalRoute']
        types=images['Type']
        imgs=[i for i,t in zip(imgs,types) if t=='test']
        sc=[os.path.join(sourcefolder,i) for i in imgs]
        dst=[os.path.join(destinationfolder,os.path.split(i)[1]) for i in imgs]
        
        for s,d in zip(sc,dst):
            copyfile(s+'.tif',d+'.tif')
            copyfile(s+'_mod.tif',d+'_mod'+modsuffix+'.tif')
    
def changeScale(configFile,index,newValue):
    images=file_utils.file2dict(configFile,',\t')
    images['PIXELSIZE'][index]=str(newValue)
    file_utils.dict2file(configFile,images,',\t')
    
def changeSelectedAngle(configFile,index,newValue):
    images=file_utils.file2dict(configFile,',\t')
    images['SELECTED'][index]=str(newValue)
    file_utils.dict2file(configFile,images,',\t')

def addImages(configFile,imagepaths,actualConfig=False):
    #configFile is the one modified, but if actualConfig is provided,
    #Relative path is taken from actualConfig
    print(configFile)
    print(imagepaths)
    print(actualConfig)
    images=file_utils.file2dict(configFile,',\t')
    imagepaths=[os.path.splitext(i)[0] for i in imagepaths]
    for i in imagepaths:
        print(i)
        if actualConfig:
            common_pref=os.path.commonprefix([i,actualConfig])
            im=os.path.relpath(i,common_pref)
        else:
            common_pref=os.path.commonprefix([i,configFile])
            im=os.path.relpath(i,common_pref)
        print(im)
        if im not in images['ROUTE']:
            images['ROUTE'].append(im)
            images['PIXELSIZE'].append('NaN')
            images['GROUP'].append(os.path.split(im)[0])
    file_utils.dict2file(configFile,images,',\t')

        
    
def duplicateImage(configFile,index,copyMod=False, duplicate_suffix='_dupl'):
    '''Duplicates image with index and adds duplicate to Darea project'''
    #index starts from 0
    images=file_utils.file2dict(configFile,',\t')
    imbasepath=os.path.join(os.path.dirname(configFile),images['ROUTE'][index])
    modbasepath=imbasepath
    while imbasepath.endswith('_dupl'):
        imbasepath=imbasepath[:-5]
    impath=imbasepath+'.tif'
    assert os.path.isfile(impath)
    
    #Find a path to copy the image to, by appending duplicat_suffix until it is not already taken
    cppath=imbasepath+duplicate_suffix
    while os.path.relpath(cppath,os.path.dirname(configFile)) in images['ROUTE']:
        cppath+=duplicate_suffix
    cproute=os.path.relpath(cppath,os.path.dirname(configFile)) #Will be written to config
    cproute=cproute.replace('\\','/') #Deal with windows issues
    if copyMod and os.path.isfile(modbasepath+'_mod.tif'):
        #Also duplicate _mod image if wanted and exists.
        copyfile(modbasepath+'_mod.tif',cppath+'_mod.tif')
    if copyMod and os.path.isfile(modbasepath+'dots.csv'):
        #Also duplicate dots file
        copyfile(modbasepath+'dots.csv',cppath+'dots.csv')
    
    #copyfile(impath,cppath+'.tif') #don't copy image to save space
    for k in images:
        lst=images[k][0:index+1]
        if k=='ROUTE':
            lst.append(cproute)
        else:
            lst.append(images[k][index])
        lst+=images[k][index+1:]
        images[k]=lst
    file_utils.dict2file(configFile,images,',\t')
    
    

def main():
    #--------------------------------------------------------
    # USER CHANGEABLE PARAMETERS
    onlyMod=False;
    folder='/Users/dkleindienst/Documents/test/Selected Folder/'
    mags=getMag('../Mags.txt')
    outputName='Config.dat'
    
    #--------------------------------------------------------
    
    #run(folder,mags,outputName,onlyMod=onlyMod,separator='_',defaultMag=False)

if __name__=='__main__':
    #main()
    pass