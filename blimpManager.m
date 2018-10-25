function [] = blimpManager()

% call speech recognition code and decipher the user's destination
target_destination = 1

% initialize Ros
[tfSub, imageSub] = initializeRos();

% call classifier

[tagX, tagY, tagZ, tagYaw, tagLabels] = getTagPose(tfSub)
pause(2)

% if no tags within vicinity
while labLabels(1) == -1 && tagLabels(2) == -1
    % turn blimp in increasing spiral to increase chance of detecting tag
    [tagX, tagY, tagZ, tagYaw, tagLabels] = getTagPose(tfSub)
end

% call localization script
% work with eric to determine what info should be passed in
% which tag to pass in if two tags were detected
% take average of x,y,z,yaw?
[x,y,thetaglobal] = blimpLocalization(xTagtoBlimp,yTagtoBlimp,thetaTagtoBlimp,sigmaSensor);

% if correct tag is within camera frame
if tagLables(1) == target_destination
    
elseif tagLables(2) == target_destination
    
% if only incorrect tag is in camera frame
% based on global position, correct to point camera at destination tag
else
        
end

% call controls (potentially grab image?)
% controls calls classifier to correct navigation

% shutdown ros
rosshutdown