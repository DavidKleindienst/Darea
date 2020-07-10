#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 19 16:00:58 2018

@author: dkleindienst
"""

import os
import random




def getRandImages(folder,nrSelectedImages=False):
    '''Returns relative imagepaths of nrSelectedImages randomly selected images in folder
    if nrSelectedImages==False, returns all imagePaths'''
    images=[i for i in os.listdir(folder) if i.endswith('.tif')]
    if nrSelectedImages:
        images=random.sample(images,nrSelectedImages)
    images=[i[0:-4] for i in images]
    return images
def imRename(folder):
    '''Renames all .tiff images in folder to .tif'''
    files=os.listdir(folder)
    for x in files:
        if x.endswith('.tiff'):
            os.rename(os.path.join(folder,x), os.path.join(folder,x[0:-1]))
def makeConfig(folder,images,scale,outputName):
    output=['GROUP,\tROUTE,\tPIXELSIZE']
    for i in sorted(images):
        output.append('images,\t%s,\t%g' %(i,scale))
        
    output='\n'.join(output)
    with open(os.path.join(folder,outputName),'w') as f:
        f.write(output)

def run(folder,scale,nr_images=False, outputName='Config.dat'):
    imRename(folder)
    images=getRandImages(folder, nr_images)
    makeConfig(folder, images, scale,outputName)
    
def main():     
    folder='/Users/dkleindienst/Desktop/IST-Net-Shares/shigegrp/David/Marijos Images/GluA4/DIST RADIATUM/Shot023/'
    scale=0.61109
    nr_images=30
    run(folder,scale)     

if __name__=='__main__':
    main()