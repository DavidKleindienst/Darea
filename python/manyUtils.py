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
    try:
        import numpy, matplotlib, tensorflow, cv2, time, random, subprocess, datetime, argparse, csv
        import ast, scipy, sklearn, shutil
        return True
    except:
        print(traceback.format_exc())
        return False


def test_tensorflow_installation():
    '''Checks if tensorflow installation works, whether a GPU is available and if cudnn is properly installed
    returns cpu, gpu, cudnn
    if cpu is False, tensorflow was not installed properly
    if cpu is true but gpu is false, tensorflow was installed properly and runs on the cpu, but no gpu support
    if cpu and gpu are true but cudnn is false, tensorflow was installed properly, the gpu is visible,
            but due to the lack of cudnn, computations will run on the cpu
    if all of them are true, tensorflow was installed properly and can use the gpu'''
    try:
        import tensorflow as tf
    except:
        print(traceback.format_exc())
        return False, False, False
    
    devices = tf.config.list_physical_devices()
    device_types = [x.device_type for x in devices]
    if not 'GPU' in device_types:
        if 'CPU' in device_types:
            return True, False, False
        else:
            return False,False,False
    
   
    import subprocess,os
    
    x=subprocess.run(['python', os.path.abspath(__file__), '--function','cudnn_test'], capture_output=True)
    
    string=x.stderr.decode('utf-8')
    return True, True, 'Loaded cuDNN version' in string
    

def cudnn_test():
    import tensorflow as tf
    import numpy as np
    from tensorflow.keras import layers
    from tensorflow.keras.models import Sequential
    

    x = np.random.normal(size=(10, 28, 28, 1)).astype(np.float32)
    y = np.zeros([10, 10], dtype=np.float32)
    y[:, 1] = 1.
    
    train_ds = tf.data.Dataset.from_tensor_slices((x, y)).shuffle(buffer_size=10).batch(4)
    num_classes = 10
    
    model = Sequential([
      layers.Conv2D(16, 3, padding='same', activation='relu'),
      layers.MaxPooling2D(),
      layers.Flatten(),
      layers.Dense(32, activation='relu'),
      layers.Dense(num_classes)
    ])
    model.compile(optimizer='adam',
                  loss=tf.keras.losses.CategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])
    epochs=1
    model.fit(
      train_ds,
      epochs=epochs
    )
    

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
    print('Sdf')
    parser=argparse.ArgumentParser()
    parser.add_argument('--function', type=str, help='Function that should be executed. (packages_available)')
    args=parser.parse_args()
    if args.function=='packages_available':
        print(all_packages_available())
    elif args.function=='cudnn_test':
        cudnn_test()
    