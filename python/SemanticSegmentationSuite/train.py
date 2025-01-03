from __future__ import print_function
import os,time,datetime,cv2, sys, math,shutil
import tensorflow.compat.v1 as tf
tf.disable_v2_behavior()
import numpy as np
import argparse
import random


# use 'Agg' on matplotlib so that plots could be generated even without Xserver
# running
import matplotlib
matplotlib.use('Agg')

from utils import utils, helpers
from builders import model_builder

import matplotlib.pyplot as plt


def data_augmentation(input_image, output_image,args,backgroundValue=None):
    if args.downscale_factor and args.downscale_factor!=1:
        #Downscale image
        dim=(int(input_image.shape[0]*args.downscale_factor), int(input_image.shape[1]*args.downscale_factor))
        input_image=cv2.resize(input_image,dim,interpolation=cv2.INTER_CUBIC)
        output_image=cv2.resize(output_image,dim,interpolation=cv2.INTER_NEAREST)
        #These interpolations are same as used by Darea in matlab when preparing for prediction
    
    input_image, output_image = utils.random_crop(input_image, output_image, args.crop_height, args.crop_width, args.biased_crop,backgroundValue)

    if args.h_flip and random.randint(0,1):
        input_image = cv2.flip(input_image, 1)
        output_image = cv2.flip(output_image, 1)
    if args.v_flip and random.randint(0,1):
        input_image = cv2.flip(input_image, 0)
        output_image = cv2.flip(output_image, 0)
    if args.brightness:
        factor = 1.0 + random.uniform(-1.0*args.brightness, args.brightness)
        table = np.array([((i / 255.0) * factor) * 255 for i in np.arange(0, 256)]).astype(np.uint8)
        input_image = cv2.LUT(input_image, table)
    if args.rotation:
        #Does not work
        #network does not improve during training when specified
        #FIX ME!
        angle = random.uniform(-1*args.rotation, args.rotation)
        M = cv2.getRotationMatrix2D((input_image.shape[1]//2, input_image.shape[0]//2), angle, 1.0)
        input_image = cv2.warpAffine(input_image, M, (input_image.shape[1], input_image.shape[0]), flags=cv2.INTER_NEAREST)
        output_image = cv2.warpAffine(output_image, M, (output_image.shape[1], output_image.shape[0]), flags=cv2.INTER_NEAREST)
    if args.rotation_perpendicular:
        angle=math.floor(random.uniform(0,4))   #Random value between 0 and 3

        for i in range(angle):
            input_image=np.rot90(input_image)
            output_image=np.rot90(output_image)
#        if angle:
#            input_image=np.rot90(input_image,angle)
#            output_image=np.rot90(output_image,angle)

    return input_image, output_image

def main(args=None):
    #If args is None, will parse command line arguments
    #Otherwise args needs to be list with arguments, like
    # ['--dataset', 'CamVid', '--model', 'FC-DenseNet103']
    parser = argparse.ArgumentParser()
    parser.add_argument('--num_epochs', type=int, default=300, help='Number of epochs to train for')
    parser.add_argument('--epoch_start_i', type=int, default=0, help='Start counting epochs from this number')
    parser.add_argument('--checkpoint_step', type=int, default=5, help='How often to save checkpoints (epochs)')
    parser.add_argument('--validation_step', type=int, default=1, help='How often to perform validation (epochs)')
    parser.add_argument('--continue_training', type=utils.str2bool, default=False, help='Whether to continue training from a checkpoint')
    parser.add_argument('--continue_from', type=str, default='', help='From which checkpoint to continue. Only relevant with darea_call.')
    parser.add_argument('--dataset', type=str, default="CamVid", help='Dataset you are using.')
    parser.add_argument('--dataset_path', type=str, default="", help='Path to Dataset folder.')
    parser.add_argument('--image_suffix', type=str, default='', required=False, help='Only files with this extension should be included. You should specify it if some non-image files will be in the same folder') 
    parser.add_argument('--crop_height', type=int, default=512, help='Height of cropped input image to network')
    parser.add_argument('--crop_width', type=int, default=512, help='Width of cropped input image to network')
    parser.add_argument('--biased_crop', type=float, default=0, help='Probability of making a biased cropped. Biased crops always contain some foreground portion. Only works if one of the classes is named "Background".')
    parser.add_argument('--downscale_factor', type=float, default=0, required=False, help='Shrink image by this factor. E.g. if image is 1024x1024 and downscale_factor is 0.5, downscaled image will be 512x512. This is applied before cropping.')
    parser.add_argument('--batch_size', type=int, default=1, help='Number of images in each batch')
    parser.add_argument('--num_val_images', type=int, default=20, help='The number of images to used for validations. If -1 -> use all')
    parser.add_argument('--h_flip', type=utils.str2bool, default=False, help='Whether to randomly flip the image horizontally for data augmentation')
    parser.add_argument('--v_flip', type=utils.str2bool, default=False, help='Whether to randomly flip the image vertically for data augmentation')
    parser.add_argument('--brightness', type=float, default=None, help='Whether to randomly change the image brightness for data augmentation. Specifies the max bightness change as a factor between 0.0 and 1.0. For example, 0.1 represents a max brightness change of 10%% (+-).')
    parser.add_argument('--rotation', type=float, default=None, help='DOES NOT WORK! Whether to randomly rotate the image for data augmentation. Specifies the max rotation angle in degrees.')
    parser.add_argument('--rotation_perpendicular', type=utils.str2bool, default=False, help='Randomly rotates by 0, 90, 180 or 270 degrees')
    parser.add_argument('--model', type=str, default="FC-DenseNet103", help='The model you are using. See model_builder.py for supported models')
    parser.add_argument('--frontend', type=str, default="None", help='The frontend you are using. See frontend_builder.py for supported models')
    parser.add_argument('--save_best', type=utils.str2bool, default=False, help='Saves model with smallest loss rather than last model')
    parser.add_argument('--learn_rate', type=float, default=0.0001, help='The learning rate')
    parser.add_argument('--chkpt_prefix', type=str, default='', help='Prefix in front of checkpoint (intended for distinguishing same models ran with different parameters)')
    parser.add_argument('--darea_call', type=utils.str2bool, default=False, required=False, help='Set to true when you call it from Darea software')
    parser.add_argument('--save_path', type=str, default='checkpoints', required=False, help='Name of saved model. Only used when darea_call is true.')
    parser.add_argument('--makePlots', type=utils.str2bool, default=True, required=False, help='Whether plots should be made')

    
    if args is None:
        args = parser.parse_args()
    else:
        args = parser.parse_args(args)
    if args.darea_call: os.chdir(os.path.dirname(os.path.realpath(__file__)))
    
    # Get the names of the classes so we can record the evaluation results
    class_names_list, label_values = helpers.get_label_info(os.path.join(args.dataset_path,args.dataset, "class_dict.csv"))
    class_names_string = ', '.join(class_names_list)
    
    if 'Background' not in class_names_list:
        args.biased_crop=0
        backgroundValue=None
    else:
        backgroundValue=label_values[class_names_list.index('Background')]
    
    num_classes = len(label_values)
    
    config = tf.ConfigProto()
    config.gpu_options.allow_growth = True
    sess=tf.Session(config=config)
    
    
    # Compute your softmax cross entropy loss
    net_input = tf.placeholder(tf.float32,shape=[None,None,None,3])     #Try setting to 1 for grayscale, think theres no other changes needed.
    net_output = tf.placeholder(tf.float32,shape=[None,None,None,num_classes])
    
    network, init_fn = model_builder.build_model(model_name=args.model,
                                                frontend=args.frontend,
                                                net_input=net_input,
                                                num_classes=num_classes,
                                                crop_width=args.crop_width,
                                                crop_height=args.crop_height,
                                                is_training=True)
    
    loss = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits_v2(logits=network, labels=net_output))
    
    opt = tf.train.RMSPropOptimizer(learning_rate=args.learn_rate, decay=0.995).minimize(loss, var_list=[var for var in tf.trainable_variables()])
    
    saver=tf.train.Saver(max_to_keep=500)
    sess.run(tf.global_variables_initializer())
    
    utils.count_params()
    
    # If a pre-trained ResNet is required, load the weights.
    # This must be done AFTER the variables are initialized with sess.run(tf.global_variables_initializer())
    if init_fn is not None:
        init_fn(sess)
    
    # Load a previous checkpoint if desired    
    if args.darea_call:
        if args.continue_training and args.continue_from:
            model_checkpoint_name='../../deepLearning/checkpoints/' + args.continue_from + '.ckpt'
            if os.path.isfile(model_checkpoint_name+'.index'):
                print('Loading latest model checkpoint...')
                saver.restore(sess, model_checkpoint_name)
                print('successfully loaded {}'.format(model_checkpoint_name))
            else:
                print('Specified checkpoint {} not found. Starting fresh one'.format(os.path.abspath(model_checkpoint_name)))
        if args.save_path:
            model_checkpoint_name=os.path.join(args.save_path, args.dataset + '.ckpt')
    else:
        if args.continue_training:
            if args.continue_from:
                model_checkpoint_name=args.continue_from
                if not model_checkpoint_name.endswith('.ckpt'):
                    model_checkpoint_name+='.ckpt'
            else:
                model_checkpoint_name = os.path.join(args.save_path,"latest_model_" + args.chkpt_prefix + args.model + "_" + args.dataset + ".ckpt")
            if os.path.isfile(model_checkpoint_name+'.index'):
                print('Loading latest model checkpoint...')
                saver.restore(sess, model_checkpoint_name)
                print('successfully loaded {}'.format(model_checkpoint_name))
            else:
                print('{} not found. Starting a fresh training'.format(args.continue_from))
        model_checkpoint_name = os.path.join(args.save_path,"latest_model_" + args.chkpt_prefix + args.model + "_" + args.dataset + ".ckpt")
    
    # Load the data
    print("Loading the data ...")
    train_input_names,train_output_names, val_input_names, val_output_names, test_input_names, test_output_names = \
                                    utils.prepare_data(dataset_dir=os.path.join(args.dataset_path,args.dataset),image_suffix=args.image_suffix)
    
    
    
    print("\n***** Begin training *****")
    print("Dataset -->", args.dataset)
    print("Model -->", args.model)
    if args.downscale_factor:
        print("Downscale Factor -->", args.downscale_factor)
    print("Crop Height -->", args.crop_height)
    print("Crop Width -->", args.crop_width)
    print("Num Epochs -->", args.num_epochs)
    print("Batch Size -->", args.batch_size)
    print("Num Classes -->", num_classes)
    print("Learn Rate -->", args.learn_rate)
    print("Validation Step -->", args.validation_step)
    
    print("Data Augmentation:")
    print("\tVertical Flip -->", args.v_flip)
    print("\tHorizontal Flip -->", args.h_flip)
    print("\tBrightness Alteration -->", args.brightness)
    print("\tRotation -->", args.rotation)
    print("\tPerpendicular Rotation -->", args.rotation_perpendicular)
    print("", flush=True)
    
    avg_loss_per_epoch = []
    avg_scores_per_epoch = []
    avg_iou_per_epoch = []
    
    
    if args.num_val_images==-1:
        #Use all validation images if so wanted by users
        val_indices=range(0,len(val_input_names))
    else:
        # Which validation images do we want
        val_indices = []
        num_vals = min(args.num_val_images, len(val_input_names))
        # Set random seed to make sure models are validated on the same validation images.
        # So you can compare the results of different models more intuitively.
        random.seed(16)
        val_indices=random.sample(range(0,len(val_input_names)),num_vals)
    
    #Copy class file with same name as checkpoint
    shutil.copyfile(os.path.join(args.dataset_path,args.dataset, "class_dict.csv"), 
                    os.path.splitext(model_checkpoint_name)[0]+'.classes')
    # Do the training here
    for epoch in range(args.epoch_start_i, args.num_epochs):
    
        current_losses = []
    
        cnt=0
    
        # Equivalent to shuffling
        id_list = np.random.permutation(len(train_input_names))
    
        num_iters = int(np.floor(len(id_list) / args.batch_size))
        st = time.time()
        epoch_st=time.time()
        for i in range(num_iters):
            # st=time.time()
    
            input_image_batch = []
            output_image_batch = []
    
            # Collect a batch of images
            for j in range(args.batch_size):
                index = i*args.batch_size + j
                id = id_list[index]
                input_image = utils.load_image(train_input_names[id])
                output_image = utils.load_image(train_output_names[id])
    
                with tf.device('/cpu:0'):
                    input_image, output_image = data_augmentation(input_image, output_image, args, backgroundValue)
                    if 0:
                        #Debugging: 
                        try:
                            os.mkdir('imagesinTrain')
                            'kj'
                        except:
                            pass
                        try:
                            os.mkdir('imagesinTrain/%04d'%(epoch))
                        except:
                            pass
                        file_name = utils.filepath_to_name(train_input_names[id])
                        file_name = os.path.splitext(file_name)[0]
                        cv2.imwrite("%s/%04d/%s_im.png"%("imagesinTrain",epoch, file_name),cv2.cvtColor(np.uint8(input_image), cv2.COLOR_RGB2BGR))
                        cv2.imwrite("%s/%04d/%s_gt.png"%("imagesinTrain",epoch, file_name),cv2.cvtColor(np.uint8(output_image), cv2.COLOR_RGB2BGR))
                    # Prep the data. Make sure the labels are in one-hot format
                    input_image = np.float32(input_image) / 255.0
                    output_image = np.float32(helpers.one_hot_it(label=output_image, label_values=label_values))
                    if 0:
                        #Debugging: 
                        try:
                            os.mkdir('imagesinTrain')
                        except:
                            pass
                        try:
                            os.mkdir('imagesinTrain/%04d'%(epoch))
                        except:
                            pass
                        file_name = utils.filepath_to_name(train_input_names[id])
                        file_name = os.path.splitext(file_name)[0]
                        print("%s/%04d/%s_im.png"%("imagesinTrain",epoch, file_name))
                        cv2.imwrite("%s/%04d/%s_im.png"%("imagesinTrain",epoch, file_name),cv2.cvtColor(np.uint8(input_image), cv2.COLOR_RGB2BGR))
                        #cv2.imwrite("%s/%04d/%s_gt.png"%("imagesinTrain",epoch, file_name),cv2.cvtColor(np.uint8(output_image), cv2.COLOR_RGB2BGR))
                    input_image_batch.append(np.expand_dims(input_image, axis=0))
                    output_image_batch.append(np.expand_dims(output_image, axis=0))
    
            if args.batch_size == 1:
                input_image_batch = input_image_batch[0]
                output_image_batch = output_image_batch[0]
                
            else:
                input_image_batch = np.squeeze(np.stack(input_image_batch, axis=1))
                output_image_batch = np.squeeze(np.stack(output_image_batch, axis=1))

            # Do the training
            _,current,output_image=sess.run([opt,loss,network],feed_dict={net_input:input_image_batch,net_output:output_image_batch})
            current_losses.append(current)
            cnt = cnt + args.batch_size
            if cnt % 25 == 0:
                string_print = "Epoch = %d Count = %d Current_Loss = %.4f Time = %.2f"%(epoch,cnt,current,time.time()-st)
                utils.LOG(string_print)
                st = time.time()
            
            if 0:
                #For Debugging
                output_image = np.array(output_image[0,:,:,:])
                output_image = helpers.reverse_one_hot(output_image)
                out_vis_image = helpers.colour_code_segmentation(output_image, label_values)
                cv2.imwrite("%s/%04d/%s_pred.png"%("imagesinTrain",epoch, file_name),cv2.cvtColor(np.uint8(out_vis_image), cv2.COLOR_RGB2BGR))

    
        mean_loss = np.mean(current_losses)
        avg_loss_per_epoch.append(mean_loss)
    
        # Create directories if needed
        if not os.path.isdir("%s/%04d"%("checkpoints",epoch)):
            os.makedirs("%s/%04d"%("checkpoints",epoch))
    
        # If latest checkpoint should be saved, save now to same file name,
        if not args.save_best:
            print("Saving latest checkpoint")
            saver.save(sess,model_checkpoint_name)
    
        if val_indices != 0 and epoch % args.checkpoint_step == 0:
            print("Saving checkpoint for this epoch")
            saver.save(sess,"%s/%04d/model.ckpt"%(args.save_path,epoch))
    
    
        if epoch % args.validation_step == 0:
            if epoch==0:
                best_avg_iou=0
            print("Performing validation")
            target=open("%s/%04d/val_scores.csv"%("checkpoints",epoch),'w')
            target.write("val_name, avg_accuracy, precision, recall, f1 score, mean iou, %s\n" % (class_names_string))
    
    
            scores_list = []
            class_scores_list = []
            precision_list = []
            recall_list = []
            f1_list = []
            iou_list = []
    
    
            # Do the validation on a small set of validation images
            for ind in val_indices:

                input_image = utils.load_image(val_input_names[ind])
                gt = utils.load_image(val_output_names[ind])
                if args.downscale_factor and args.downscale_factor !=1:
                    dim=(int(input_image.shape[0]*args.downscale_factor), int(input_image.shape[1]*args.downscale_factor))
                    input_image=cv2.resize(input_image,dim,interpolation=cv2.INTER_CUBIC)
                    gt=cv2.resize(gt,dim,interpolation=cv2.INTER_NEAREST)
                
                #input_image, gt = data_augmentation(input_image, gt, args)
                    
                    
                gt = helpers.reverse_one_hot(helpers.one_hot_it(gt, label_values))
                
                crop_height=args.crop_height
                crop_width=args.crop_width
                
                if input_image.shape[0]>crop_height or input_image.shape[1]>crop_width:
                    #rectangle in bottom right corner smaller than cropped im will not be used
                    nrCroppingsY=input_image.shape[0]//crop_height
                    nrCroppingsX=input_image.shape[1]//crop_width
                    output_image=np.zeros([nrCroppingsY*crop_height,nrCroppingsX*crop_width])
                    gt=gt[0:nrCroppingsY*crop_height,0:nrCroppingsX*crop_width]
                    for yi in range(nrCroppingsY):
                        row=np.zeros([crop_height,nrCroppingsX*crop_width])
                        for xi in range(nrCroppingsX):
                            inputIm=input_image[yi*crop_height:(1+yi)*crop_height,xi*crop_width:(1+xi)*crop_width,:]
                            inputIm=np.expand_dims(np.float32(inputIm)/255.0,axis=0)
                            out=sess.run(network,feed_dict={net_input:inputIm})
                            out = np.array(out[0,:,:,:])
                            out=helpers.reverse_one_hot(out)
                            row[:,xi*crop_width:(1+xi)*crop_width]=out
                        output_image[yi*crop_height:(1+yi)*crop_height,:]=row
                # st = time.time()                    
                    
                else:
                    input_image=np.expand_dims(np.float32(input_image)/255.0,axis=0)
                    output_image = sess.run(network,feed_dict={net_input:input_image})
                    output_image = np.array(output_image[0,:,:,:])
                    output_image = helpers.reverse_one_hot(output_image)
    
                
                out_vis_image = helpers.colour_code_segmentation(output_image, label_values)
                accuracy, class_accuracies, prec, rec, f1, iou, class_iou = utils.evaluate_segmentation(pred=output_image, label=gt, num_classes=num_classes)
    
                file_name = utils.filepath_to_name(val_input_names[ind])
                target.write("%s, %f, %f, %f, %f, %f"%(file_name, accuracy, prec, rec, f1, iou))
                for item in class_accuracies:
                    target.write(", %f"%(item))
                target.write("\n")
    
                scores_list.append(accuracy)
                class_scores_list.append(class_accuracies)
                precision_list.append(prec)
                recall_list.append(rec)
                f1_list.append(f1)
                iou_list.append(iou)
    
                gt = helpers.colour_code_segmentation(gt, label_values)
    
                file_name = os.path.basename(val_input_names[ind])
                file_name = os.path.splitext(file_name)[0]
                cv2.imwrite("%s/%04d/%s_pred.png"%("checkpoints",epoch, file_name),cv2.cvtColor(np.uint8(out_vis_image), cv2.COLOR_RGB2BGR))
                cv2.imwrite("%s/%04d/%s_gt.png"%("checkpoints",epoch, file_name),cv2.cvtColor(np.uint8(gt), cv2.COLOR_RGB2BGR))
    
    
            target.close()
    
            avg_score = np.mean(scores_list)
            class_avg_scores = np.mean(class_scores_list, axis=0)
            avg_scores_per_epoch.append(avg_score)
            avg_precision = np.mean(precision_list)
            avg_recall = np.mean(recall_list)
            avg_f1 = np.mean(f1_list)
            avg_iou = np.mean(iou_list)
            avg_iou_per_epoch.append(avg_iou)
            
            
    
            print("\nAverage validation accuracy for epoch # %04d = %f"% (epoch, avg_score))
            print("Average per class validation accuracies for epoch # %04d:"% (epoch))
            for index, item in enumerate(class_avg_scores):
                print("%s = %f" % (class_names_list[index], item))
            print("Validation precision = ", avg_precision)
            print("Validation recall = ", avg_recall)
            print("Validation F1 score = ", avg_f1)
            print("Validation IoU score = ", avg_iou, flush=True)
            if args.save_best and avg_iou>best_avg_iou:
                #Save model if best model is wanted and it is the best or if it is first evaluation
                print("Saving best checkpoint with iou {}".format(avg_iou))
                saver.save(sess,model_checkpoint_name)
                best_avg_iou=avg_iou
                #Save an info file
                with open(model_checkpoint_name[:-5]+'.info', 'w') as f:
                    f.write('Epoch\t{}\nValidation IoU score\t{}'.format(epoch,avg_iou))
        epoch_time=time.time()-epoch_st
        remain_time=epoch_time*(args.num_epochs-1-epoch)
        m, s = divmod(remain_time, 60)
        h, m = divmod(m, 60)
        if s!=0:
            train_time="Remaining training time = %d hours %d minutes %d seconds\n"%(h,m,s)
        else:
            train_time="Remaining training time : Training completed.\n"
        utils.LOG(train_time)
        scores_list = []
        
    with open(model_checkpoint_name[:-5]+'.info', 'a+') as f:
        #Save some info on filesizes
        f.write('\nimageSize\t{}'.format([args.crop_height,args.crop_width]))
        f.write('\nTraining completed\t{}'.format(datetime.datetime.now().strftime("%d-%b-%Y %H:%M:%S")))

    if not args.darea_call and args.makePlots:
        fig1, ax1 = plt.subplots(figsize=(11, 8))
    
        ax1.plot(range(epoch+1), avg_scores_per_epoch)
        ax1.set_title("Average validation accuracy vs epochs")
        ax1.set_xlabel("Epoch")
        ax1.set_ylabel("Avg. val. accuracy")
    
    
        plt.savefig('accuracy_vs_epochs.png')
    
        plt.clf()
    
        fig2, ax2 = plt.subplots(figsize=(11, 8))
    
        ax2.plot(range(epoch+1), avg_loss_per_epoch)
        ax2.set_title("Average loss vs epochs")
        ax2.set_xlabel("Epoch")
        ax2.set_ylabel("Current loss")
    
        plt.savefig('loss_vs_epochs.png')
    
        plt.clf()
    
        fig3, ax3 = plt.subplots(figsize=(11, 8))
    
        ax3.plot(range(epoch+1), avg_iou_per_epoch)
        ax3.set_title("Average IoU vs epochs")
        ax3.set_xlabel("Epoch")
        ax3.set_ylabel("Current IoU")

        plt.savefig('iou_vs_epochs.png')
            

    
if __name__=='__main__': 
    main(None)
