import os,time,cv2
import tensorflow.compat.v1 as tf
tf.disable_v2_behavior()
import argparse
import numpy as np

from utils import utils, helpers
from builders import model_builder

parser = argparse.ArgumentParser()
parser.add_argument('--checkpoint_path', type=str, default=None, required=True, help='The path to the latest checkpoint weights for your model.')
parser.add_argument('--crop_height', type=int, default=512, help='Height of cropped input image to network')
parser.add_argument('--crop_width', type=int, default=512, help='Width of cropped input image to network')
parser.add_argument('--model', type=str, default='FC-DenseNet103', required=False, help='The model you are using')
parser.add_argument('--output_path', type=str, default='Test', required=False, help='Path to the folder for outputs')
parser.add_argument('--dataset', type=str, default="CamVid", required=False, help='The dataset you are using')
parser.add_argument('--dataset_path', type=str, default="", help='Path to Dataset folder.')
parser.add_argument('--darea_call', type=utils.str2bool, default=False, required=False, help='Set to true when you call it from Darea software')

args = parser.parse_args()
if args.darea_call:
    os.chdir(os.path.dirname(os.path.realpath(__file__)))

# Get the names of the classes so we can record the evaluation results
print("Retrieving dataset information ...")
class_names_list, label_values = helpers.get_label_info(os.path.join(args.dataset_path,args.dataset, "class_dict.csv"))


class_names_acc=[x + ' accuracy' for x in class_names_list]
class_names_iou=[x + ' iou' for x in class_names_list]

num_classes = len(label_values)

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

print('Loading model checkpoint weights ...')
saver=tf.train.Saver(max_to_keep=1000)
saver.restore(sess, args.checkpoint_path)

# Load the data
print("Loading the data ...")
train_input_names,train_output_names, val_input_names, val_output_names, test_input_names, test_output_names = utils.prepare_data(dataset_dir=os.path.join(args.dataset_path,args.dataset))

# Create directories if needed
if args.output_path!='' and not os.path.isdir(args.output_path):
    os.mkdir(args.output_path)


target=open(os.path.join(args.output_path, 'test.csv'),'w')
target.write("test_name,test_accuracy,precision,recall,f1 score,mean iou,%s,%s" % (','.join(class_names_acc), ','.join(class_names_iou)))
scores_list = []
class_scores_list = []
precision_list = []
recall_list = []
f1_list = []
iou_list = []
run_times_list = []

# Run testing on ALL test images
for ind in range(len(test_input_names)):
    print("Running test image %d / %d"%(ind+1, len(test_input_names)),flush=True)
    
    #st = time.time()

    input_image = np.expand_dims(np.float32(utils.load_image(test_input_names[ind])[:args.crop_height, :args.crop_width]),axis=0)/255.0
    gt = utils.load_image(test_output_names[ind])[:args.crop_height, :args.crop_width]
    gt = helpers.reverse_one_hot(helpers.one_hot_it(gt, label_values))

    #print('Loaded image, took {}'.format(time.time()-st))
    st = time.time()
    output_image = sess.run(network,feed_dict={net_input:input_image})

    run_times_list.append(time.time()-st)
    #print('Predicted image, took {}'.format(time.time()-st))
    #st = time.time()

    output_image = np.array(output_image[0,:,:,:])
    output_image = helpers.reverse_one_hot(output_image)
    out_vis_image = helpers.colour_code_segmentation(output_image, label_values)
    #print('Computed output images, took {}'.format(time.time()-st))
    #st = time.time()

    accuracy, class_accuracies, prec, rec, f1, iou, class_iou = utils.evaluate_segmentation(pred=output_image, label=gt, num_classes=num_classes)
    #print('Computed metrics, took {}'.format(time.time()-st))
    #st = time.time()

    file_name = utils.filepath_to_name(test_input_names[ind])
    target.write("\n%s,%g,%g,%g,%g,%g"%(file_name, accuracy, prec, rec, f1, iou))
    for item in class_accuracies:
        target.write(",%g"%(item))
    for item in class_iou:
        target.write(",%g"%(item))

    scores_list.append(accuracy)
    class_scores_list.append(class_accuracies)
    precision_list.append(prec)
    recall_list.append(rec)
    f1_list.append(f1)
    iou_list.append(iou)
    
    #print('Wrote metrics, took {}'.format(time.time()-st))
    #st = time.time()
    cv2.imwrite("%s/%s_pred.tif"%(args.output_path, file_name),cv2.cvtColor(np.uint8(out_vis_image), cv2.COLOR_RGB2BGR))

    if not args.darea_call:
        gt = helpers.colour_code_segmentation(gt, label_values)
        cv2.imwrite("%s/%s_gt.tif"%(args.output_path, file_name),cv2.cvtColor(np.uint8(gt), cv2.COLOR_RGB2BGR))
    
    #print('Saved Images, took {}'.format(time.time()-st), flush=True)
    #st = time.time()
    

target.close()

avg_score = np.mean(scores_list)
class_avg_scores = np.mean(class_scores_list, axis=0)
avg_precision = np.mean(precision_list)
avg_recall = np.mean(recall_list)
avg_f1 = np.mean(f1_list)
avg_iou = np.mean(iou_list)
avg_time = np.mean(run_times_list)
print("Average test accuracy = ", avg_score)
print("Average per class test accuracies = \n")
for index, item in enumerate(class_avg_scores):
    print("%s = %f" % (class_names_list[index], item))
print("Average precision = ", avg_precision)
print("Average recall = ", avg_recall)
print("Average F1 score = ", avg_f1)
print("Average mean IoU score = ", avg_iou)
print("Average run time = ", avg_time)
