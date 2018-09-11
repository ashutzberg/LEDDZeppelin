% Create the video object.
cam = videoinput('winvideo',1,'YUY2_720x480');
set(cam,'ReturnedColorSpace','rgb');

% Capture one frame to get its size.
videoFrame = getsnapshot(cam);
videoFrameGray = rgb2gray(videoFrame);
