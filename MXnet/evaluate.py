# CrowdCounting
#
# Created by Raelyn Lyu on 13/5/19.
# Copyright © 2019 Raelyn Lyu. All rights reserved.
import mxnet as mx
from mtcnn_detector import MtcnnDetector
import pickle
import cv2

f = open('val_path.txt', 'r')
array = [x.strip('\n') for x in f.readlines()]
f.close()


res = []
num = []
ct=1
detector = MtcnnDetector(model_folder='model', ctx=mx.cpu(0), num_worker = 4 , accurate_landmark = False)
for img in array:
    print(ct)
    ct+=1
    case = cv2.imread("model/images/"+img)
    results = detector.detect_face(case)

    if results is not None:
        total_boxes =(img,results[0])

        num.append(len(total_boxes))
        res.append(total_boxes)
    else:
        res.append((img,None))



with open('evalBBox.pkl', 'wb') as f:
    pickle.dump(res, f)

with open('evalNum.pkl', 'wb') as f:
    pickle.dump(num, f)

with open('evalBBox.pkl', 'rb') as f:
    x = pickle.load(f)
    print(x)