# -*- coding: utf-8 -*-
"""
Created on Thu Oct 15 09:20:26 2020

@author: tvips
"""
import sys
import os
import predict_while

nav=sys.argv[1]
folder=os.path.split(nav)[0]
navname=os.path.split(os.path.splitext(nav)[0])[1]
checkpoints='C:/Users/tvips.000.001/Documents/SerialEM/py-EM/scripts/checkpoints/'
predict_while.main(['--image', folder,
                    '--checkpoint_path', os.path.join(checkpoints,'SpineFinder_2048.ckpt'),
                    '--downscale_factor', '0.5', 
                    '--image_suffix', '.tif',
                    '--file_suffix', '.tif',
                    '--outpath', os.path.join(folder,'predictions'),
                    '--coords_filename', os.path.join('../',navname)])

