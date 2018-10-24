function [] = blimpManager()

% call speech recognition code and decipher the user's destination

% initialize Ros
[tfSub, imageSub] = initializeRos();

% call classifier
while (true)
   [tagX, tagY, tagZ, tagYaw, tagLabel] = getTagPose(tfSub)
   pause(2)
end

% if no tags within vicinity

% if only incorrect tag is in camera frame
% call localization script
% based on global position, correct to point camera at destination tag

% if correct tag is within camera frame
% call localization script

% call controls
% controls calls classifier to correct navigation

% shutdown ros
rosshutdown