import os,time,cv2
import tensorflow as tf
import argparse
import numpy as np

from utils import utils, helpers
from builders import model_builder

def ttest():
    return 'yes'

def main(args=None):
    #If args is None, will parse command line arguments
    #Otherwise args needs to be list with arguments, like
    # ['--image', 'imageFolder', '--model', 'FC-DenseNet103'] 
    parser = argparse.ArgumentParser()
    parser.add_argument('--image', type=str, default=None, required=True, help='The image or folder with images you want to predict on. ')
    parser.add_argument('--checkpoint_path', type=str, default=None, required=False, help='The path to the latest checkpoint weights for your model. Will guess based on model and dataset if not specified')
    parser.add_argument('--crop_height', type=int, default=512, help='Height of cropped input image to network')
    parser.add_argument('--crop_width', type=int, default=512, help='Width of cropped input image to network')
    parser.add_argument('--model', type=str, default="FC-DenseNet103", required=False, help='The model you are using')
    parser.add_argument('--dataset', type=str, default="CamVid", required=False, help='The dataset you are using')
    parser.add_argument('--outpath', type=str, default='./', required=False, help='Folder where predicted images should be saved to')
    parser.add_argument('--file_suffix', type=str, default='_pred.png', required=False, help='Suffix appended to input image name for output image')
    parser.add_argument('--darea_call', type=utils.str2bool, default=False, required=False, help='Set to true when you call it from Darea software')
    if args is None:
        args=parser.parse_args()
    else:
        args=parser.parse_args(args)
    if args.darea_call:
        os.chdir(os.path.dirname(os.path.realpath(__file__)))
    class_names_list, label_values = helpers.get_label_info(os.path.join(args.dataset, "class_dict.csv"))
    
    num_classes = len(label_values)
    

    print("\n***** Begin prediction *****")
    print("Dataset -->", args.dataset)
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
    
    if os.path.isdir(args.image):
        folder=args.image
        not_allowed_filenames=['.DS_Store']
        images=[os.path.join(folder,file) for file in os.listdir(folder) if file not in not_allowed_filenames]
    else:
        images=[args.image]
    
    if not os.path.isdir(args.outpath):
        os.mkdir(args.outpath)

    print('Performing predictions...')
    for image in images:
        if not args.darea_call:
            print("Testing image {}".format(image))
        
        loaded_image = utils.load_image(image)
        resized_image =cv2.resize(loaded_image, (args.crop_width, args.crop_height))
        input_image = np.expand_dims(np.float32(resized_image[:args.crop_height, :args.crop_width]),axis=0)/255.0
        
        st = time.time()
        output_image = sess.run(network,feed_dict={net_input:input_image})
        
        run_time = time.time()-st
        
        output_image = np.array(output_image[0,:,:,:])
        output_image = helpers.reverse_one_hot(output_image)
        
        out_vis_image = helpers.colour_code_segmentation(output_image, label_values)
        file_name = "{}{}".format(utils.filepath_to_name(image),args.file_suffix)
        cv2.imwrite(os.path.join(args.outpath,file_name),cv2.cvtColor(np.uint8(out_vis_image), cv2.COLOR_RGB2BGR))
        if not args.darea_call:
            print("Wrote image {}".format(file_name))
            print("")
    if not args.darea_call:
        print("Finished!")
    
if __name__=='__main__':
    main(None)