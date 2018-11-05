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
	4. make a new catkin_ws for opencv and make a src inside that new catkin_ws then catkin make
	3. git clone the video_stream_opencv to the opencv_ws/src
https://github.com/ros-drivers/video_stream_opencv
go back to opencv_ws and catkin_make
run:
source /home/user_name/image_transport_ws/devel/setup.bash
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

4. might need intermediate image_proc node to rectify the image
already have image_proc from setting up image_pipeline ws
https://github.com/ros-perception/image_pipeline
to run, go to image_pipeline_ws:
ROS_NAMESPACE=camera rosrun image_proc image_proc
to view the rectified image in a separate terminal, set up rqt_image_view ws:
https://github.com/ros-visualization/rqt_image_view
run:
rosrun rqt_image_view rqt_image_view

cant use the image_pipeline image_view due to opencv issue
https://github.com/ros-perception/image_pipeline/issues/201

5. set April Tag settings
inside config/settings.yaml
change tag family to 'tag16h5'
set publish_tf to true

inside config/tags.yaml
standalone_tags:
  [
    {id: 0, size: 0.168, name: "Tag 0"},
    {id: 1, size: 0.168, name: "Tag 1"},
    {id: 2, size: 0.168, name: "Tag 2"},
    {id: 3, size: 0.168, name: "Tag 3"},
    {id: 4, size: 0.168, name: "Tag 4"},
    {id: 5, size: 0.168, name: "Tag 5"},
    {id: 6, size: 0.168, name: "Tag 6"},
    {id: 7, size: 0.168, name: "Tag 7"},
  ]

inside continuous_detection.launch
<launch>
  <arg name="launch_prefix" default="" /> <!-- set to value="gdbserver localhost:10000" for remote debugging -->
  <arg name="node_namespace" default="apriltags2_ros_continuous_node" />
  <arg name="camera_name" default="/camera" />
  <arg name="camera_frame" default="camera" />
  <arg name="image_topic" default="image_rect" />

  <!-- Set parameters -->
  <rosparam command="load" file="$(find apriltags2_ros)/config/settings.yaml" ns="$(arg node_namespace)" />
  <rosparam command="load" file="$(find apriltags2_ros)/config/tags.yaml" ns="$(arg node_namespace)" />
  
  <node pkg="apriltags2_ros" type="apriltags2_ros_continuous_node" name="$(arg node_namespace)" clear_params="true" output="screen" launch-prefix="$(arg launch_prefix)" >
    <!-- Remap topics from those used in code to those on the ROS network -->
    <remap from="image_rect" to="$(arg camera_name)/$(arg image_topic)" />
    <remap from="camera_info" to="$(arg camera_name)/camera_info" />

    <param name="camera_frame" type="str" value="$(arg camera_frame)" />
    <param name="publish_tag_detections_image" type="bool" value="true" />      <!-- default: false -->
  </node>
</launch>

6. to run the classifier with the video stream
have the opencv video stream and the image_proc already running
to run the detector in the apriltags_ws:
roslaunch apriltags2_ros continuous_detection.launch
if it cant find apriltags2_ros run:
source devel/setup.bash

use /tag_detections_image to see image with tag highlighted
use /tf to get detected tag and tag bundle poses

Important: Make sure that you print yours tags surrounded by at least a 1 bit wide white border. The core AprilTag 2 algorithm samples this surrounding white border for creating a light model over the tag surface so do not e.g. cut or print the tags out flush with their black border. 

install rviz. should be installed with ros melodic
http://wiki.ros.org/rviz/UserGuide

to run rviz:
rosrun rviz rviz


7. Running the Matlab ROS Nodes
- wait until topics, listen to topic, translate data if necessary (Eric)

8. Linking the April Tags and Matlab Nodes together
Running the April Tags ROS Nodes

9. april tags simulation?
https://github.com/xenobot-dev/apriltags_ros

10. usb_cam-test.launch

11. mapviz? or rviz?
https://github.com/swri-robotics/mapviz


Everything set up
in apriltags_ws
roslaunch apriltags2_ros continuous_detection.launch
in image_transport_ws
roslaunch video_stream_opencv camera.launch video_stream_provider:=1
in image_pipeline_ws
ROS_NAMESPACE=camera rosrun image_proc image_proc
in rqt_image_view_ws
rosrun rqt_image_view rqt_image_view
in usb_cam_ws
./set_ntsc /dev/video1
roslaunch usb_cam usb_cam-test.launch video_device:=1 camera_info_url:="file:///home/kristen/.ros/camera_info/usb_camera.yaml" camera_name:=camera
in camera_calibration_ws
rosrun camera_calibtion cameracalibrator.py --size 8x6 --square 0.30 image:=/usb_cam/image_raw camera:=/usb_cam 

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

