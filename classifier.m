% Create the video object.
cam = videoinput('winvideo',1,'YUY2_720x480');
set(cam,'ReturnedColorSpace','rgb');

% Capture one frame to get its size.
videoFrame = getsnapshot(cam);
videoFrameGray = rgb2gray(videoFrame);


% parse data from folder
% file name indicates label for that image

% extract features

% SVM classifier on images
% X is the image data/features and y is the labels
clf = fitcsvm(X,y)
% imgs is the image data/features and bag is the labels
clf = trainImageCategoryClassifier(imgs, bag)
% train

% test