#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May 18 16:31:25 2021

@author: dkleindienst
"""

import os, sys, cv2, json
import numpy as np
from scipy.spatial import distance
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages


sys.path.insert(0, os.path.join(os.getcwd(), 'SemanticSegmentationSuite'))

from file_utils import file_utils
from utils import utils

def getCoordinatesFromFiles(images, outputPath=False, downscale_factor=False, background='white', saveMorphImage=True):
    
    coordinates=dict()
    for img in images:
        if not os.path.isfile(img):
            coordinates[utils.filepath_to_name(img,True)]=[]
            continue
        image=cv2.cvtColor(cv2.imread(img),cv2.COLOR_RGB2GRAY)
        if np.min(image)==np.max(image):
            #Whole image is same color i.e. everything is background
            coordinates[utils.filepath_to_name(img,True)]=[]
            continue
        if background=='white':
            foregroundcolor=[np.min(image)]
        elif background=='black':
            foregroundcolor=[np.max(image)]
        else:
            raise ValueError('Only black and white are allowed as values for background (it was {})'.format(background))
        coordinates[utils.filepath_to_name(img,True)], morphImage = utils.getCoordsFromPrediction(image,foregroundcolor,downscale_factor,close_dim=384); #open_dim=8,,open2_dim=32
        if saveMorphImage:
            outMorph=np.ones(morphImage.shape,dtype=np.uint8)*np.iinfo(np.uint8).max
            outMorph[morphImage==0]=0
            cv2.imwrite(img[0:-4]+'_morph.tif',cv2.cvtColor(np.uint8(outMorph), cv2.COLOR_RGB2BGR))
    if outputPath:
        if not outputPath.endswith('.json'):
            outputPath = outputPath + '.json'
        with open(outputPath, 'w') as f:
            json.dump(coordinates,f)

    return coordinates, images

def getCoordinatesFromConfig(configFile,outputPath=False,downscale_factor=False):
    config=file_utils.file2dict(configFile,',\t')
    folder=os.path.split(configFile)[0]
    
    images=[os.path.join(folder,x)+'_mod.tif' for x in config['ROUTE']]
    
    return getCoordinatesFromFiles(images,outputPath,downscale_factor)

def getCoordinatesFromFolder(folder, outputPath=False, downscale_factor=False):
    files = [os.path.join(folder,f) for f in os.listdir(folder) if not f.startswith('.') and f.endswith('.tif') and not f.endswith('_morph.tif')]
    return getCoordinatesFromFiles(files,outputPath,downscale_factor,'black')


def getCoordinates(file, downscale_factor=False):
    if file.endswith('.json'):
        with open(file, 'r') as f:
            coordinates=json.load(f)
        return coordinates, False
    elif os.path.isdir(file):
        return getCoordinatesFromFolder(file,downscale_factor=downscale_factor)
    else:
        return getCoordinatesFromConfig(file)
        

def compareCoordinates(file1,file2,json1=False,json2=False, reportPath=False, downscale_factor1=False, downscale_factor2=False):
    #If a json already exists, supply that to make it much quicker
    if json1:
        coord1,_ = getCoordinates(json1, downscale_factor1)
    else:
        coord1, images1 = getCoordinates(file1, downscale_factor1)
    if json2:
        coord2,_ = getCoordinates(json2, downscale_factor2)
    else:
        coord2, images2 = getCoordinates(file2, downscale_factor2)
    try:
        assert coord1.keys()==coord2.keys()
    except:
        print(coord1)
        print(coord2)
        assert coord1.keys()==coord2.keys()
    
    correct, f_positive, f_negative = compareCoordLists(coord1,coord2)
                
    print('Correct: {}\nFalse Negative: {} ({}%)\nFalse Positive: {} ({}%)'.format(len(correct),len(f_negative),round(100*len(f_negative)/(len(correct)+len(f_negative))),len(f_positive),round(100*len(f_positive)/(len(correct)+len(f_positive)))))
    
    if not reportPath:
        return correct, f_positive, f_negative
    if (not json1 and not images1) or (not json2 and not images2):
        print('For making report, inputs need to be either prediction folder or config file')
        return correct, f_positive, f_negative
    
    nrPlotsperPage=7
    cols=['Image', 'Human', 'Human_morphed', 'Darea', 'Darea_morphed']
    for l, name in zip([correct,f_positive, f_negative], ['correct', 'false positive', 'false negative']):
        with PdfPages(os.path.join(reportPath, name + '_report.pdf')) as pdf:
            
            for i,line in enumerate(l):
                plots=compareDemVis(file1,file2,line,plot=False)
                pn=i % nrPlotsperPage
                if pn==0:
                    fig, ax=plt.subplots(nrPlotsperPage,5,figsize=(8.27, 11.69), dpi=400)
                    
                for j, plot in enumerate(plots):
                    if plot is None:
                        continue
                    if j==0:
                        ax[pn,j].imshow(plot,cmap='gray')
                        ax[pn,j].text(-50, plot.shape[1]/2,line[0], horizontalalignment='right', fontsize=8);
                    else:
                        ax[pn,j].imshow(plot,cmap='gray', vmin=0, vmax=255)
                
                if pn == nrPlotsperPage - 1 or i==len(l)-1:
                    
                    for a, col in zip(ax[0], cols):
                        a.set_title(col)
                                        
                    for a in ax.flat:
                        a.axis('off')
                    pdf.savefig(fig)
                    plt.close(fig)
    return correct, f_positive, f_negative
 
def compareDemVis(configFile,prediction_folder,line, plot=True,cropsize=768):    
    config=file_utils.file2dict(configFile,',\t')
    folder=os.path.split(configFile)[0]
    images=[os.path.join(folder,x)+'.tif' for x in config['ROUTE']]
    image=[f for f in images if f.endswith(line[0]+'.tif')][0]
    modImage=image[:-4]+'_mod.tif'
    prediction=os.path.join(prediction_folder,os.path.split(image)[1])
    
    img = cv2.cvtColor(cv2.imread(image),cv2.COLOR_RGB2GRAY)
    if os.path.isfile(modImage):
        modImg = cv2.cvtColor(cv2.imread(modImage),cv2.COLOR_RGB2GRAY)
    else:
        modImg = np.ones(img.shape, dtype=np.uint8)*np.iinfo(np.uint8).max
        
    if os.path.isfile(modImage[0:-4]+'_morph.tif'):
        morphModImg=invertImage(cv2.cvtColor(cv2.imread(modImage[0:-4]+'_morph.tif'),cv2.COLOR_RGB2GRAY))
    else: 
        morphModImg=None
      
    
    pred = invertImage(cv2.cvtColor(cv2.imread(prediction),cv2.COLOR_RGB2GRAY))
    
    if os.path.isfile(prediction[0:-4]+'_morph.tif'):
        morphPred=invertImage(cv2.cvtColor(cv2.imread(prediction[0:-4]+'_morph.tif'),cv2.COLOR_RGB2GRAY))
    else: 
        morphPred=None
    
    
    if pred.shape!=img.shape:
        #Upscale prediction
        pred = cv2.resize(pred,img.shape,cv2.INTER_NEAREST)
        
        if morphPred is not None:
            morphPred = cv2.resize(morphPred,img.shape,cv2.INTER_NEAREST)
        
    cropY1=max(0,round(line[1][0]-cropsize/2))
    cropY2=min(img.shape[1],round(line[1][0]+cropsize/2))
    cropX1=max(0,round(line[1][1]-cropsize/2))
    cropX2=min(img.shape[0],round(line[1][1]+cropsize/2))
    
    plotted_images=[img[cropX1:cropX2,cropY1:cropY2], modImg[cropX1:cropX2,cropY1:cropY2]]
    
    if morphModImg is not None: 
        plotted_images.append(morphModImg[cropX1:cropX2,cropY1:cropY2])
    else:
        plotted_images.append(None)
    
    plotted_images.append(pred[cropX1:cropX2,cropY1:cropY2])
    
    if morphPred is not None:
        plotted_images.append(morphPred[cropX1:cropX2,cropY1:cropY2])
    else:
        plotted_images.append(None)
    
    if not plot:
        return plotted_images
        
    plt.figure()
    plt.imshow(plotted_images[0],cmap='gray')
    for i,x in enumerate(plotted_images):
        if x is None:
            continue
        
        plt.figure()
        plt.imshow(x,cmap='gray', vmin=0, vmax=255)
   
def invertImage(image):
    if np.min(image)<0:
        return image*-1
    try:
        return image*-1+np.iinfo(image.dtype).max
    except:
        #dtype was not int, try float
        return image*-1+np.finfo(image.dtype).max

def compareCoordLists(coord1,coord2):
    max_dist=630
    
    if type(coord1)==list:
        coord1=convertCoordListToDict(coord1)
    if type(coord2)==list:
        coord2=convertCoordListToDict(coord2)
    
    f_positive=[]   #In 2 but not 1
    f_negative=[]   #In 1 but not 2
    correct=[]      #In both
    
    for k in coord1.keys():
        if not coord1[k] and (k not in coord2 or not coord2[k]):
            #both are empty
            continue
        if not coord1[k]:
            f_positive+=[[k,tuple(x)] for x in coord2[k]]
            continue
        if k not in coord2 or not coord2[k]:
            f_negative+=[[k,tuple(x)] for x in coord1[k]]
            continue
        
        dist=distance.cdist(coord1[k],coord2[k])
        
        good=dist<max_dist
        
        if not good.any():
            #None of the points in the two sets correspond
            f_positive+=[[k,tuple(x)] for x in coord2[k]]
            f_negative+=[[k,tuple(x)] for x in coord1[k]]
            continue
            
        #Find out which points correspond
        good=np.argwhere(dist<max_dist)     #Indices of coordinates that are same in both sets
        
        
        
        for i,x in enumerate(coord1[k]):
            if i in good[:,0]:
                correct.append([k,tuple(x)])
            else:
                f_negative.append([k,tuple(x)])
        
        for i,x in enumerate(coord2[k]):
            if i not in good[:,1]:
                #No need to do correct ones as they would be ~same as in coord1
                f_positive.append([k,tuple(x)])
    return correct, f_positive, f_negative
  
def convertCoordListToDict(lst):
    d=dict()
    for k, coords in lst:
        if k in d:
            d[k].append(list(coords))
        else:
            d[k]=[list(coords)]
            
    return d
    
