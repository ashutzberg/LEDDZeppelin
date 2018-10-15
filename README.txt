1. set up dual boot with linux ubuntu (v 17.0 or above)
2. install ros (melodic)
http://wiki.ros.org/melodic/Installation/Ubuntu
3. install catkin
4. copy github for april tags 2
5. make the following fix to apriltags2/src/image_f32.c
https://github.com/dmalyuta/apriltags2_ros/pull/21/commits/0b0fb50d12a377441bb6dbe18fe6147a042320df
6. compile using catkin-make
7.a) run ros
http://wiki.ros.org/rosbash#rosrun

7.b) print the correct images
april tags images + checkboard for calibration

8.a) calibrate the laptop camera
http://wiki.ros.org/camera_calibration/Tutorials/MonocularCalibration

8.b) calibrate the blimp camera

9.a) running classifier on a single image
roslaunch apriltags2_ros single_image_server.launch
roslaunch apriltags2_ros single_image_client.launch image_load_path:=<FULL PATH TO INPUT IMAGE> image_save_path:=<FULL PATH TO OUTPUT IMAGE>

9.b) running classifier continuously


ros opencv camera driver - for laptop camera to generate a ros node video stream, hook into april tag continuous dection, might work if attach receiver to device input

ros usb_cam - for logictech usb camera, ask zhang/q about purchasing hardware for a usb camera

matlab - wait until topics, listen to topic, translate data if necessary (Eric)

calibration once camera drivers working

