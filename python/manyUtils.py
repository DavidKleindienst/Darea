#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 15 10:43:11 2019

@author: dkleindienst
"""
import os
import traceback
import shutil
from file_utils import file_utils

def all_packages_available():
    '''Checks if all neccessary python packages for deeplearning are available'''
    answer=True
    try:
        import numpy, matplotlib, tensorflow, cv2, time, random, subprocess, datetime, argparse, csv
        import ast, scipy, sklearn, shutil
    except Exception as e:
        print(traceback.format_exc())
        answer=False
    return answer
def getMaxIntFromNumberedFiles(path,file_ext):
    '''In a folder that contains numbered files (e.g. 1.tif, 2.tif, and so on)
    finds the maximum integer. Returns 0 if no numbered files are there'''
    files=[os.path.splitext(os.path.split(x)[1])[0] for x in os.listdir(path) if x.endswith(file_ext)]
    numberedFiles=[int(f) for f in files if f.isdigit()]
    numberedFiles.append(0) #So that 0 is returned if list is empty
    return max(numberedFiles)

def copyImagesfromChooser(destination,choiceFile,choicesToCopy,keepStructure=False,file_ext='.tif'):
    ''' Copys files chosen with matlab filechooser to destination folder
    destination: destination Folder
    choiceFile: Path to choice file made with matlab gpdq filechooser
    choicesToCopy: List of strings specifying the choices which images should be copied
    keepStructure: keeps Original folder structure. If False, will modify file names, numbering then will be 1.tif, 2.tif ...; If numbered files already at destination, 
                        will increment numbers rather than overwriting files
    file_ext: fileextenstion of images (in choice file, no fileextensions are saved) '''
    
    
    file_utils.safe_mkdir(destination)
    
    choices=file_utils.file2dict(choiceFile,delimiter='\t')
    filesToCopy=[f + file_ext for i,f in enumerate(choices['Image']) if choices['Choice'][i] in choicesToCopy]
    print(filesToCopy)
    if not filesToCopy:
        return
    
    if keepStructure:
        #Needs to be implemented Still
        pass
    else:
        nr_start=1+getMaxIntFromNumberedFiles(destination,file_ext)
        fileDests=[os.path.join(destination,str(nr_start+i)+file_ext) for i,_ in enumerate(filesToCopy)]
        
    for x,y in zip(filesToCopy,fileDests):
        shutil.copyfile(x,y)
        
def copyImages(configFile, destination, onlyImage=True, prefix=''):
    #Copys all images in configFile to destination folder
    #Original folder will be used as prefix
    #set onlyImage to False to also copy _mod.tif and dots.csv files
    if not os.path.isdir(destination):
        os.mkdir(destination)
    config=file_utils.file2dict(configFile,',\t')
    folder=os.path.split(configFile)[0]
    originImages=[x+'.tif' for x in config['ROUTE'] if not x.endswith('_dupl')]
    destinationImages=[prefix+x.replace('/', '__') for x in originImages] #Subfolders names are used as prefix seperated by __
    _copyFilesFromList(folder,originImages,destination,destinationImages)
    
    if not onlyImage:
        originMod=[x+'_mod.tif' for x in config['ROUTE'] if os.path.isfile(os.path.join(folder,x)+'_mod.tif')]
        originDots=[x+'dots.csv' for x in config['ROUTE'] if os.path.isfile(os.path.join(folder,x)+'dots.csv')]
        destinationMod=[prefix+x.replace('/', '__') for x in originMod]
        destinationDots=[prefix+x.replace('/', '__') for x in originMod]
        
        _copyFilesFromList(folder,originMod,destination,destinationMod)
        _copyFilesFromList(folder,originDots,destination,destinationDots)
        
    
    
def _copyFilesFromList(originFolder,originFiles, destinationFolder,destinationFiles):
    for origin, dest in zip(originFiles, destinationFiles):
        shutil.copyfile(os.path.join(originFolder,origin),os.path.join(destinationFolder,dest))
        
if __name__=='__main__':
    import argparse
    parser=argparse.ArgumentParser()
    parser.add_argument('--function', type=str, help='Function that should be executed. (packages_available)')
    args=parser.parse_args()
    if args.function=='packages_available':
        print(all_packages_available())
    