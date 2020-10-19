import os,time,cv2,json
import tensorflow as tf
import argparse
import numpy as np
import math as m

from utils import utils, helpers
from builders import model_builder

#This is file is similar to predict.py,
#but is intended for running in parallel with image acquisition
#So rather than making a file list in the beginning
#The folder has to be constantly monitored for new files being added which will then be predicted on
#The process quits if no images are added for more than args.waitfor minutes

def ttest():
    return 'yes'

def getUnfinishedImages(folder,finished_images,image_suffix):
    images=[os.path.join(folder,file) for file in os.listdir(folder) if not file.startswith('.') and not os.path.isdir(file) and file.endswith(image_suffix)]
    images=[file for file in images if file not in finished_images]
    return images
    

def main(args=None):
    #If args is None, will parse command line arguments
    #Otherwise args needs to be list with arguments, like
    # ['--image', 'imageFolder', '--model', 'FC-DenseNet103'] 
    parser = argparse.ArgumentParser()
    parser.add_argument('--image', type=str, default=None, required=True, help='The image or folder with images you want to predict on. ')
    parser.add_argument('--classes', type=str, required=True, help='Path to class_dict.csv')
    parser.add_argument('--checkpoint_path', type=str, default=None, required=False, help='The path to the latest checkpoint weights for your model. Will guess based on model and dataset if not specified')
    parser.add_argument('--crop_height', type=int, default=512, help='Height of cropped input image to network')
    parser.add_argument('--crop_width', type=int, default=512, help='Width of cropped input image to network')
    parser.add_argument('--downscale_factor', type=float, default=0, required=False, help='Shrink image by this factor. E.g. if image is 1024x1024 and downscale_factor is 0.5, downscaled image will be 512x512. This is applied before cropping.')
    parser.add_argument('--model', type=str, default="FC-DenseNet103", required=False, help='The model you are using')
    parser.add_argument('--image_suffix', type=str, default='', required=False, help='Only files with this extension should be included. You should specify it if some non-image files will be in the same folder') 
    parser.add_argument('--outpath', type=str, default='./', required=False, help='Folder where predicted images should be saved to')
    parser.add_argument('--file_suffix', type=str, default='_pred.png', required=False, help='Suffix appended to input image name for output image')
    parser.add_argument('--save_predictionImage', type=utils.str2bool, default=True, required=False, help='Whether predictions should be saved as images')
    parser.add_argument('--save_coordinates', type=utils.str2bool, default=True, required=False, help='Whether coordinates of predicted structures should be saved')
    parser.add_argument('--coords_filename', type=str, default='coordinates',required=False, help='Filename of the coordinates file (without filextension).')
    parser.add_argument('--coords_class'), type=str, default=None, required=False, help='Specify class to generate coordinates from. (Default is all classes). Separate multiple classes by comma to pool them.'
    parser.add_argument('--wait_time', type=float, default=1, required=False, help='Time (in s) to wait for new images to appear in folder')
    
    if args is None:
        args=parser.parse_args()
    else:
        args=parser.parse_args(args)
    class_names_list, label_values = helpers.get_label_info(os.path.join(args.classes))
    
    num_classes = len(label_values)
    assert os.path.isdir(args.image), "Argument image needs to be a folder"

    if args.save_coordinates:
        if args.coords_class is None:
            foregroundcolors=[c[0] for c in label_values[1:]]
            #Labels are in RGB, but we only need grayscale value
        else:
            target_classes=args.coords_class.split(',')
            foregroundcolors=[label_values[i][0] for i,c in enumerate(class_names_list) if c in target_classes]
            if len(foregroundcolors)<1:
                raise ValueError('None of the specified --coords_class found in class dict.\nSpecified classes were {}\nExisting classes are {}'.format(target_classes,class_names_list))
            
            
    print("\n***** Begin prediction *****")
    #print("Dataset -->", args.dataset)
    print("Model -->", args.model)
    print("Crop Height -->", args.crop_height)
    print("Crop Width -->", args.crop_width)
    print("Num Classes -->", num_classes)
    print("Image -->", args.image)
    if args.checkpoint_path is None:
        args.checkpoint_path = "checkpoints/latest_model_" + args.model + "_" + args.dataset + ".ckpt"
    
        # Initializing network
    config = tf.ConfigProto()
    config.gpu_options.allow_growth = True
    sess=tf.Session(config=config)
    net_input = tf.placeholder(tf.float32,shape=[None,None,None,3])
    net_output = tf.placeholder(tf.float32,shape=[None,None,None,num_classes]) 
    
    network, _ = model_builder.build_model(args.model, net_input=net_input,
                                            num_classes=num_classes,
                                            crop_width=args.crop_width,
                                            crop_height=args.crop_height,
                                            is_training=False)
    
    sess.run(tf.global_variables_initializer())
    
    print('Loading model checkpoint weights')
    saver=tf.train.Saver(max_to_keep=1000)

    saver.restore(sess, args.checkpoint_path)
    #time.sleep(args.wait_time*3)
    folder=args.image
    finished_images=[]
    images=getUnfinishedImages(folder,finished_images,args.image_suffix)
    
    if not os.path.isdir(args.outpath):
        os.mkdir(args.outpath)
    
    if args.save_coordinates:
        coordinates=dict()
    print('Performing predictions...')
    
    while images:
        time.sleep(args.wait_time)
        for index,image in enumerate(images):
            print("Predicting image {} (image {} out of {})".format(image,index+1, len(images)))
            
            input_image = utils.load_image(image)
            if args.downscale_factor and args.downscale_factor !=1:
                dim=(int(input_image.shape[0]*args.downscale_factor), int(input_image.shape[1]*args.downscale_factor))
                input_image=cv2.resize(input_image,dim,interpolation=cv2.INTER_CUBIC)
            
            st = time.time()
            crop_height=args.crop_height
            crop_width=args.crop_width
            
            if input_image.shape[0]>crop_height or input_image.shape[1]>crop_width:
                #rectangle in bottom right corner smaller than cropped im will not be used
                nrCroppingsY=m.ceil(input_image.shape[0]/crop_height)
                nrCroppingsX=m.ceil(input_image.shape[1]/crop_width)
                output_image=np.zeros([nrCroppingsY*crop_height,nrCroppingsX*crop_width])
                for yi in range(nrCroppingsY):
                    row=np.zeros([crop_height,nrCroppingsX*crop_width])
                    cropYstart=yi*crop_height;
                    cropYstop=(1+yi)*crop_height
                    if cropYstop>=input_image.shape[0]:
                        cropYstop=input_image.shape[0]-1
                        cropYstart=cropYstop-crop_height
                    for xi in range(nrCroppingsX):
                        cropXstart=xi*crop_width;
                        cropXstop=(1+xi)*crop_width
                        if cropXstop>=input_image.shape[1]:
                            cropXstop=input_image.shape[1]-1
                            cropXstart=cropXstop-crop_width
                        inputIm=input_image[cropYstart:cropYstop,cropXstart:cropXstop,:]
                        inputIm=np.expand_dims(np.float32(inputIm)/255.0,axis=0)
                        #print(inputIm.shape)
                        out=sess.run(network,feed_dict={net_input:inputIm})
                        out = np.array(out[0,:,:,:])
                        out=helpers.reverse_one_hot(out)
                        if (1+xi)*crop_width>=input_image.shape[1]:
                            row[:,xi*crop_width:]=out
                        else:
                            row[:,xi*crop_width:(1+xi)*crop_width]=out
                    if (1+yi)*crop_height>=input_image.shape[0]:
                        output_image[yi*crop_height:,:]=row
                    else:
                        output_image[yi*crop_height:(1+yi)*crop_height,:]=row
            # st = time.time()                    
                
            else:
                input_image=np.expand_dims(np.float32(input_image)/255.0,axis=0)
                output_image = sess.run(network,feed_dict={net_input:input_image})
                output_image = np.array(output_image[0,:,:,:])
                output_image = helpers.reverse_one_hot(output_image)
            
            run_time = time.time()-st
            
            
            out_vis_image = helpers.colour_code_segmentation(output_image, label_values)
            if args.save_predictionImage:
                file_name = "{}{}".format(utils.filepath_to_name(image),args.file_suffix)
                cv2.imwrite(os.path.join(args.outpath,file_name),cv2.cvtColor(np.uint8(out_vis_image), cv2.COLOR_RGB2BGR))
                print("Wrote image {}".format(file_name))

            
            if args.save_coordinates:
                coordinates[utils.filepath_to_name(image)]=utils.getCoordsFromPrediction(cv2.cvtColor(np.uint8(out_vis_image), cv2.COLOR_RGB2GRAY),foregroundcolors,args.downscale_factor);
                
            print("", flush=True)
        #Finished predicting all images in list
        finished_images+=images
        #Now check if new images appeared in folder, if so, repeat, else wait, retry then finish
        images=getUnfinishedImages(folder,finished_images,args.image_suffix)
        if images:
            continue
        print("Waiting for new images", flush=True)
        time.sleep(args.wait_time)
        images=getUnfinishedImages(folder,finished_images,args.image_suffix)
        if not images:
            break
            
        
    if args.save_coordinates:
        with open(os.path.join(args.outpath,'{}.json'.format(args.coords_filename)), 'w') as f:
            json.dump(coordinates,f)
        
    print("Finished!")
    
if __name__=='__main__':
    
    main(None)