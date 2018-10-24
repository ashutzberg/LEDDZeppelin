function [tfSub, imageSub] = initializeRos()

rosshutdown
rosinit('http://localhost:11311');
tfSub = rossubscriber('/tf');
imageSub = rossubscriber('/tag_detections_image');