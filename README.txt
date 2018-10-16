Basic Environment Setup
1. set up dual boot with linux ubuntu (v 17.0 or above)
2. install ros (melodic)
http://wiki.ros.org/melodic/Installation/Ubuntu
3. install catkin
4. set up a catkin workspace, i called mine apriltags_ws
   create a src folder inside apriltags_ws
   inside src, git clone https://github.com/dmalyuta/apriltags2_ros.git
5. inside src, make the following fix to apriltags2/src/image_f32.c
https://github.com/dmalyuta/apriltags2_ros/pull/21/commits/0b0fb50d12a377441bb6dbe18fe6147a042320df

6. compile using catkin_make

Calibration
1. using opencv
ros opencv camera driver - for laptop camera to generate a ros node video stream, hook into april tag continuous dection, might work if attach receiver to device input
1. using webcam
https://help.ubuntu.com/community/Webcam
2. figure out camera id ls /dev/video*
to launch video stream with opencv ~/apriltags_ws/src/video_stream_opencv/scripts$ ./test_video_resource.py 0
3. create a publisher node for opencv
http://wiki.ros.org/image_transport/Tutorials/PublishingImages
4. use opencv on publisher node
https://github.com/ros-drivers/video_stream_opencv

2. using ros usb_cam - for logictech usb camera, ask zhang/q about purchasing hardware for a usb camera

3. calibrating a monocular camera using the checkerboard
http://wiki.ros.org/camera_calibration/Tutorials/MonocularCalibration

4. calibrating using april tags ros

Running the April Tags ROS Nodes

Running the Matlab ROS Nodes
- wait until topics, listen to topic, translate data if necessary (Eric)

Linking the April Tags and Matlab Nodes Together


Extra Information
how to run ros
http://wiki.ros.org/rosbash#rosrun

use the images from the 16h5 family
https://april.eecs.umich.edu/software/apriltag.html

how to run classifier on a single image
roslaunch apriltags2_ros single_image_server.launch
roslaunch apriltags2_ros single_image_client.launch image_load_path:=<FULL PATH TO INPUT IMAGE> image_save_path:=<FULL PATH TO OUTPUT IMAGE>
how to run classifier continuously
roslaunch apriltags2_ros continuous_detection.launch
