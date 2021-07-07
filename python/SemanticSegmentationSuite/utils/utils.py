from __future__ import print_function, division
import os,time,cv2, sys, math,argparse
import tensorflow as tf
slim=tf.contrib.slim
import numpy as np
import time, datetime
import os, random
from scipy.misc import imread
import ast
from sklearn.metrics import precision_score, \
    recall_score, confusion_matrix, classification_report, \
    accuracy_score, f1_score

from utils import helpers
NOT_ALLOWED_FILENAMES=['.DS_Store']
def prepare_class_data(dataset_dir,classes):
    '''Prepare Data for image classification
    Expected folder structure:
    dataset_dir
        ---class1
            ---train
            ---val
        ---class2
            ---train
            ---val
        ...
    '''
    train_images=[]
    train_labels=[]
    val_images=[]
    val_labels=[]
    cwd=os.getcwd()
    for i,c in enumerate(classes):
        for x in ['train', 'val']:
            for file in os.listdir(os.path.join(dataset_dir,c,x)):
                if file not in NOT_ALLOWED_FILENAMES:
                    if x=='train':
                        train_images.append(os.path.join(cwd,dataset_dir,c,x,file))
                        train_labels.append(i)
                    elif x=='val':
                        val_images.append(os.path.join(cwd,dataset_dir,c,x,file))
                        val_labels.append(i)
    return train_images, train_labels, val_images, val_labels

def prepare_data(dataset_dir,image_suffix=''):
    train_input_names=[]
    train_output_names=[]
    val_input_names=[]
    val_output_names=[]
    test_input_names=[]
    test_output_names=[]
    imtypes='train train_labels val val_labels test test_labels'.split()
    name_lists=(train_input_names,train_output_names,val_input_names,val_output_names,test_input_names,test_output_names)
    cwd = os.getcwd()
    for x,name_list in zip(imtypes, name_lists):
        for file in os.listdir(os.path.join(dataset_dir,x)):
            if file not in NOT_ALLOWED_FILENAMES and not file.startswith('.') and not os.path.isdir(file) and file.endswith(image_suffix):
                name_list.append(os.path.join(cwd, dataset_dir, x, file))
    train_input_names.sort(),train_output_names.sort(), val_input_names.sort(), val_output_names.sort(), test_input_names.sort(), test_output_names.sort()
    return train_input_names,train_output_names, val_input_names, val_output_names, test_input_names, test_output_names




def load_image(path):
    assert os.path.exists(path)
    try:
        image = cv2.cvtColor(cv2.imread(path,-1), cv2.COLOR_BGR2RGB)
        if image.dtype=='uint16':
            image=(image/256).astype('uint8')
        
    except:
        print(path)
        raise
    assert (image.dtype=='uint8'), "Image needs to be of type uint8 or uint16"
    
    return image

# Takes an absolute file path and returns the name of the file without th extension
def filepath_to_name(full_name,remove_Mod=False):
    file_name = os.path.basename(full_name)
    file_name = os.path.splitext(file_name)[0]
    if remove_Mod and file_name.endswith('_mod'):
        file_name=file_name[0:-4]
    return file_name

# Print with time. To console or file
def LOG(X, f=None):
    time_stamp = datetime.datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
    if not f:
        print(time_stamp + " " + X)
    else:
        f.write(time_stamp + " " + X)


# Count total number of parameters in the model
def count_params():
    total_parameters = 0
    for variable in tf.trainable_variables():
        shape = variable.get_shape()
        variable_parameters = 1
        for dim in shape:
            variable_parameters *= dim.value
        total_parameters += variable_parameters
    print("This model has %d trainable parameters"% (total_parameters))

# Subtracts the mean images from ImageNet
def mean_image_subtraction(inputs, means=[123.68, 116.78, 103.94]):
    inputs=tf.to_float(inputs)
    num_channels = inputs.get_shape().as_list()[-1]
    if len(means) != num_channels:
      raise ValueError('len(means) must match the number of channels')
    channels = tf.split(axis=3, num_or_size_splits=num_channels, value=inputs)
    for i in range(num_channels):
        channels[i] -= means[i]
    return tf.concat(axis=3, values=channels)

def str2bool(v):
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected. Gotten {}'.format(v))

def _lovasz_grad(gt_sorted):
    """
    Computes gradient of the Lovasz extension w.r.t sorted errors
    See Alg. 1 in paper
    """
    gts = tf.reduce_sum(gt_sorted)
    intersection = gts - tf.cumsum(gt_sorted)
    union = gts + tf.cumsum(1. - gt_sorted)
    jaccard = 1. - intersection / union
    jaccard = tf.concat((jaccard[0:1], jaccard[1:] - jaccard[:-1]), 0)
    return jaccard

def _flatten_probas(probas, labels, ignore=None, order='BHWC'):
    """
    Flattens predictions in the batch
    """
    if order == 'BCHW':
        probas = tf.transpose(probas, (0, 2, 3, 1), name="BCHW_to_BHWC")
        order = 'BHWC'
    if order != 'BHWC':
        raise NotImplementedError('Order {} unknown'.format(order))
    C = probas.shape[3]
    probas = tf.reshape(probas, (-1, C))
    labels = tf.reshape(labels, (-1,))
    if ignore is None:
        return probas, labels
    valid = tf.not_equal(labels, ignore)
    vprobas = tf.boolean_mask(probas, valid, name='valid_probas')
    vlabels = tf.boolean_mask(labels, valid, name='valid_labels')
    return vprobas, vlabels

def _lovasz_softmax_flat(probas, labels, only_present=True):
    """
    Multi-class Lovasz-Softmax loss
      probas: [P, C] Variable, class probabilities at each prediction (between 0 and 1)
      labels: [P] Tensor, ground truth labels (between 0 and C - 1)
      only_present: average only on classes present in ground truth
    """
    C = probas.shape[1]
    losses = []
    present = []
    for c in range(C):
        fg = tf.cast(tf.equal(labels, c), probas.dtype) # foreground for class c
        if only_present:
            present.append(tf.reduce_sum(fg) > 0)
        errors = tf.abs(fg - probas[:, c])
        errors_sorted, perm = tf.nn.top_k(errors, k=tf.shape(errors)[0], name="descending_sort_{}".format(c))
        fg_sorted = tf.gather(fg, perm)
        grad = _lovasz_grad(fg_sorted)
        losses.append(
            tf.tensordot(errors_sorted, tf.stop_gradient(grad), 1, name="loss_class_{}".format(c))
                      )
    losses_tensor = tf.stack(losses)
    if only_present:
        present = tf.stack(present)
        losses_tensor = tf.boolean_mask(losses_tensor, present)
    return losses_tensor

def lovasz_softmax(probas, labels, only_present=True, per_image=False, ignore=None, order='BHWC'):
    """
    Multi-class Lovasz-Softmax loss
      probas: [B, H, W, C] or [B, C, H, W] Variable, class probabilities at each prediction (between 0 and 1)
      labels: [B, H, W] Tensor, ground truth labels (between 0 and C - 1)
      only_present: average only on classes present in ground truth
      per_image: compute the loss per image instead of per batch
      ignore: void class labels
      order: use BHWC or BCHW
    """
    probas = tf.nn.softmax(probas, 3)
    labels = helpers.reverse_one_hot(labels)

    if per_image:
        def treat_image(prob, lab):
            prob, lab = tf.expand_dims(prob, 0), tf.expand_dims(lab, 0)
            prob, lab = _flatten_probas(prob, lab, ignore, order)
            return _lovasz_softmax_flat(prob, lab, only_present=only_present)
        losses = tf.map_fn(treat_image, (probas, labels), dtype=tf.float32)
    else:
        losses = _lovasz_softmax_flat(*_flatten_probas(probas, labels, ignore, order), only_present=only_present)
    return losses


# Randomly crop the image to a specific size. For data augmentation
def random_crop(image, label, crop_height, crop_width,biased_crop=0,backgroundValue=None):
    if (image.shape[0] != label.shape[0]) or (image.shape[1] != label.shape[1]):
        raise Exception('Image and label must have the same dimensions!')
    
    if crop_width == image.shape[1] and crop_height == image.shape[0]:
        #Nothing to crop, return inputs
        return image, label    
        
    if crop_width > image.shape[1] or crop_height > image.shape[0]:
        raise Exception('Crop shape (%d, %d) exceeds image dimensions (%d, %d)!' % (crop_height, crop_width, image.shape[0], image.shape[1]))
        
        
    if biased_crop and backgroundValue is not None and random.random()<biased_crop:
        #Carry out biased cropping which should contain some foreground pixels
        #First check whether image contains any foreground pixels
        arr=label!=backgroundValue
        if arr.any():
            #Carry out biased cropping
            foreground=np.transpose(np.nonzero(arr.any(axis=2)))
            #foreground is a 2 by n list of foregroundpixels
            #Select a random one of them
            y,x=foreground[random.randint(0,foreground.shape[0]-1),:]
            y=_get_crop_start_from_center(y,crop_height,image.shape[0])
            x=_get_crop_start_from_center(x,crop_width,image.shape[1])
            if len(label.shape) == 3:
                cropped_im=image[y:y+crop_height, x:x+crop_width, :], label[y:y+crop_height, x:x+crop_width, :]
            else:
                cropped_im=image[y:y+crop_height, x:x+crop_width], label[y:y+crop_height, x:x+crop_width]
            return cropped_im
    
    x = random.randint(0, image.shape[1]-crop_width)
    y = random.randint(0, image.shape[0]-crop_height)

    if len(label.shape) == 3:
        cropped_im=image[y:y+crop_height, x:x+crop_width, :], label[y:y+crop_height, x:x+crop_width, :]
    else:
        cropped_im=image[y:y+crop_height, x:x+crop_width], label[y:y+crop_height, x:x+crop_width]
    return cropped_im

def _get_crop_start_from_center(a,crop_size,image_size):
    #a should be coordinate of the center of the crop 
    #a can be either x or y coordinate, but choose crop_size and image_size along same dimension
    #returns b which is left or uppermost coordinate of the crop
    #So final crop can then be b:b+crop_size
    b=a-math.floor(crop_size/2)
    if b<0:
        b=0
    if b+crop_size>image_size:
        b=image_size-crop_size
    return b

# Compute the average segmentation accuracy across all classes
def compute_global_accuracy(pred, label):
    total = len(label)
    count = 0.0
    for i in range(total):
        if pred[i] == label[i]:
            count = count + 1.0
    return float(count) / float(total)

# Compute the class-specific segmentation accuracy
def compute_class_accuracies(pred, label, num_classes):
    total = []
    for val in range(num_classes):
        total.append((label == val).sum())

    count = [0.0] * num_classes
    for i in range(len(label)):
        if pred[i] == label[i]:
            count[int(pred[i])] = count[int(pred[i])] + 1.0

    # If there are no pixels from a certain class in the GT, 
    # it returns NAN because of divide by zero
    # Replace the nans with a 1.0.
    accuracies = []
    for i in range(len(total)):
        if total[i] == 0:
            accuracies.append(1.0)
        else:
            accuracies.append(count[i] / total[i])

    return accuracies


def compute_mean_iou(pred, label):

    unique_labels = np.unique(label)
    num_unique_labels = len(unique_labels);

    I = np.zeros(num_unique_labels)
    U = np.zeros(num_unique_labels)

    for index, val in enumerate(unique_labels):
        pred_i = pred == val
        label_i = label == val

        I[index] = float(np.sum(np.logical_and(label_i, pred_i)))
        U[index] = float(np.sum(np.logical_or(label_i, pred_i)))

    
    mean_iou = np.mean(I / U)
    return mean_iou 

def compute_class_iou(pred, labels,num_classes):
    
    

    I = np.zeros(num_classes)
    U = np.zeros(num_classes)

    for  val in range(num_classes):
        pred_i = pred == val
        label_i = labels == val

        I[val] = float(np.sum(np.logical_and(label_i, pred_i)))
        U[val] = float(np.sum(np.logical_or(label_i, pred_i)))
        if U[val]==I[val]==0:
            #Avoid division by 0 if the class is not in image
            U[val]=1;
            I[val]=1;

    class_iou=I/U
    
    return class_iou

def evaluate_segmentation_on_files(imageFile1,imageFile2, class_dict):
    _, label_values = helpers.get_label_info(class_dict)
    im1 = load_image(imageFile1)
    im1 = helpers.reverse_one_hot(helpers.one_hot_it(im1,label_values))
    im2 = load_image(imageFile2)
    im2 = helpers.reverse_one_hot(helpers.one_hot_it(im2,label_values))
    global_accuracy, class_accuracies, prec, rec, f1, iou, class_iou = evaluate_segmentation(im1,im2,len(label_values))
    return global_accuracy, class_accuracies, prec, rec, f1, iou, class_iou
    
    
def evaluate_segmentation(pred, label, num_classes, score_averaging="weighted"):
    flat_pred = pred.flatten()
    flat_label = label.flatten()

    global_accuracy = compute_global_accuracy(flat_pred, flat_label)
    class_accuracies = compute_class_accuracies(flat_pred, flat_label, num_classes)

    prec = precision_score(flat_pred, flat_label, average=score_averaging)
    rec = recall_score(flat_pred, flat_label, average=score_averaging)
    f1 = f1_score(flat_pred, flat_label, average=score_averaging)

    iou = compute_mean_iou(flat_pred, flat_label)
    class_iou=compute_class_iou(flat_pred,flat_label, num_classes)

    return global_accuracy, class_accuracies, prec, rec, f1, iou, class_iou

    
def compute_class_weights(labels_dir, label_values):
    '''
    Arguments:
        labels_dir(list): Directory where the image segmentation labels are
        num_classes(int): the number of classes of pixels in all images

    Returns:
        class_weights(list): a list of class weights where each index represents each class label and the element is the class weight for that label.

    '''
    image_files = [os.path.join(labels_dir, file) for file in os.listdir(labels_dir) if file.endswith('.png')]

    num_classes = len(label_values)

    class_pixels = np.zeros(num_classes) 

    total_pixels = 0.0

    for n in range(len(image_files)):
        image = imread(image_files[n])

        for index, colour in enumerate(label_values):
            class_map = np.all(np.equal(image, colour), axis = -1)
            class_map = class_map.astype(np.float32)
            class_pixels[index] += np.sum(class_map)

            
        print("\rProcessing image: " + str(n) + " / " + str(len(image_files)), end="")
        sys.stdout.flush()

    total_pixels = float(np.sum(class_pixels))
    index_to_delete = np.argwhere(class_pixels==0.0)
    class_pixels = np.delete(class_pixels, index_to_delete)

    class_weights = total_pixels / class_pixels
    class_weights = class_weights / np.sum(class_weights)

    return class_weights

def getCoordsFromPrediction(image,foregroundcolors,downscale_factor=False,open_dim=4,close_dim=512,open2_dim=24):
    
    bw=np.zeros(image.shape,dtype=image.dtype)
    for c in foregroundcolors:
        bw[image==c]=1

    if downscale_factor:
        #If image was downscaled, also reduce number of pixels for morph operations
        open_dim=round(open_dim*downscale_factor)
        close_dim=round(close_dim*downscale_factor)
        #Set pixels on the border to 0 to allow for opening away from the border
        bw[[0,1,-1,-2],:]=0
        bw[:,[0,1,-1,-2]]=0
        open2_dim=round(open2_dim*downscale_factor)
    bw=cv2.morphologyEx(bw,cv2.MORPH_OPEN,np.ones((open_dim,open_dim),np.uint8))
    bw=cv2.morphologyEx(bw,cv2.MORPH_CLOSE,np.ones((close_dim,close_dim),np.uint8))
    bw=cv2.morphologyEx(bw,cv2.MORPH_OPEN,np.ones((open2_dim,open2_dim),np.uint8))
    
    nr_labels,labels,stats,centroids=cv2.connectedComponentsWithStats(bw)
    if downscale_factor:
        centroids=[[x/downscale_factor for x in c] for c in centroids]
    
    targets=[list(c) for c,s in zip(centroids,stats) if s[0]!=0 and s[1]!=0]
    return targets,bw

# Compute the memory usage, for debugging
def memory():
    import os
    import psutil
    pid = os.getpid()
    py = psutil.Process(pid)
    memoryUse = py.memory_info()[0]/2.**30  # Memory use in GB
    print('Memory usage in GBs:', memoryUse)