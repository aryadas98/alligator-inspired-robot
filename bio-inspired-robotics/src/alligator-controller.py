#!/usr/bin/env python

import rospy
from std_msgs.msg import Int8
from sensor_msgs.msg import Image
import cv2
import numpy as np
from cv_bridge import CvBridge,CvBridgeError

bridge = CvBridge()

stop, straight, right, left = 0,1,2,3
dirr = stop

def callback(msg):
    img = bridge.imgmsg_to_cv2(msg)
    img = cv2.flip(img,0)
    imgf = cv2.inRange(img, (0,100,0), (50,255,50))

    count = cv2.countNonZero(imgf)
    cX, cY, dirr = -1,-1,stop

    if (count > 0):
        M = cv2.moments(imgf)

        cX = int(M["m10"] / M["m00"])
        cY = int(M["m01"] / M["m00"])

    if (count == 0):
        dirr = stop
    elif (cX < 11):
        dirr = left
    elif (cX > 21):
        dirr = right
    else:
        dirr = straight

    print("px count:", count, "centroid:",cX,cY, "direction:",dirr)
    pub.publish(dirr)

    newimgf = np.ones_like(img)*255
    newimgf = cv2.bitwise_or(newimgf,newimgf,mask=imgf)

    disp = np.concatenate((img,newimgf), axis=1)
    disp = cv2.resize(disp,(0,0),fx=10,fy=10,interpolation=cv2.INTER_NEAREST)

    cv2.imshow("Display", disp)
    cv2.waitKey(1)

rospy.init_node('controller', anonymous=True)
rospy.Subscriber('image', Image, callback)
pub = rospy.Publisher('alg_ctrl', Int8, queue_size=10)

rospy.spin()
