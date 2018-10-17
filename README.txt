Basic Environment Setup
1. set up dual boot with linux ubuntu (v 17.0 or above)
2. install ros (melodic)
http://wiki.ros.org/melodic/Installation/Ubuntu
3. install catkin
4. set up a catkin workspace, i called mine apriltags_ws
http://wiki.ros.org/catkin/Tutorials/create_a_workspace
   create a src folder inside apriltags_ws
   inside src, git clone https://github.com/dmalyuta/apriltags2_ros.git
5. inside src, make the following fix to apriltags2/src/image_f32.c
https://github.com/dmalyuta/apriltags2_ros/pull/21/commits/0b0fb50d12a377441bb6dbe18fe6147a042320df

6. compile using catkin_make

Calibration
1.a) using opencv
	ros opencv camera driver - for laptop camera to generate a ros node video stream, hook into april tag continuous dection, might work if attach receiver to device input
	1. using webcam
	https://help.ubuntu.com/community/Webcam
	2. figure out camera id using ls /dev/video*
	3. git clone the video_stream_opencv to the apriltags_ws/src
https://github.com/ros-drivers/video_stream_opencv
go back to apriltags_ws and catkin_make
run source /home/user_name/apriltags_ws/devel/setup.bash
to open a publisher node where 0 is the number of the camera device and my_camera is the name of the camera node
 roslaunch video_stream_opencv camera.launch video_stream_provider:=0 # camera_name:=my_camera
which produces
rostopic list
/camera/camera_info
/camera/image_raw
/camera/image_raw/compressed
/camera/image_raw/compressed/parameter_descriptions
/camera/image_raw/compressed/parameter_updates
/camera/image_raw/compressedDepth
/camera/image_raw/compressedDepth/parameter_descriptions
/camera/image_raw/compressedDepth/parameter_updates
/camera/image_raw/theora
/camera/image_raw/theora/parameter_descriptions
/camera/image_raw/theora/parameter_updates
/rosout
/rosout_agg

1.b) using ros usb_cam - for logictech usb camera, ask zhang/q about purchasing hardware for a usb camera
http://wiki.ros.org/usb_cam

2. calibrating a monocular camera using the checkerboard
http://wiki.ros.org/camera_calibration
set up a separate catkin ws for the calibration code, same process as before
git clone down the repo to the src then run catkin_make
print out the checkboard on camera_calibration
start up the the opencv publisher first then in a separate terminal in the camera_calibration ws run:
rosrun camera_calibtion cameracalibrator.py --size 8x6 --square 0.30 image:=/camera/image_raw camera:=/camera
then hold up the checkerboard to the camera
- want to hold it on the left, right, top, bottom, and on a tilt
- hold until the checkerboard is highlighted in the calibration window
- once calibrate lights up, press it to collect results
- then press save, then commit after calibration has finished and those buttons light up
- calibration data will be saved to /tmp/calibrationdata.tar.gz
and will be writen to /home/kristen/.ros/camera_info/camera.yaml

3. dont need to do bundle calibration since dont plan to have more than one tag visible in the camera frame at any time
http://wiki.ros.org/apriltags2_ros/Tutorials/Bundle%20calibration

4. set April Tag settings

5. detection in a video stream
http://wiki.ros.org/apriltags2_ros/Tutorials/Detection%20in%20a%20video%20stream
be already running the opencv video stream node

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
http://wiki.ros.org/apriltags2_ros/Tutorials/Detection%20in%20a%20Single%20Image
roslaunch apriltags2_ros single_image_server.launch
roslaunch apriltags2_ros single_image_client.launch image_load_path:=<FULL PATH TO INPUT IMAGE> image_save_path:=<FULL PATH TO OUTPUT IMAGE>

how to run classifier continuously
http://wiki.ros.org/apriltags2_ros/Tutorials/Detection%20in%20a%20video%20stream
roslaunch apriltags2_ros continuous_detection.launch
