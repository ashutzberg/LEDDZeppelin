function [] = blimpManager()

% call speech recognition code and decipher the user's destination
target_destination = 1

% initialize Ros
[tfSub, imageSub] = initializeRos();

% call classifier

[tagX, tagY, tagZ, tagYaw, tagLabel] = getTagPose(tfSub)
pause(2)

% if no tags within vicinity, limit to number of attempts to poll
% surroundings before starting spiral pattern
while tagLabel == -1
    % turn blimp in increasing spiral to increase chance of detecting tag
    [tagX, tagY, tagZ, tagYaw, tagLabel] = getTagPose(tfSub)
end

% call localization script
% work with eric to determine what info should be passed in
% which tag to pass in if two tags were detected
% take average of x,y,z,yaw?
[x,y,thetaglobal] = blimpLocalization(xTagtoBlimp,yTagtoBlimp,thetaTagtoBlimp,sigmaSensor);

% if correct tag is within camera frame
if tagLable == target_destination
    
elseif tagLable != target_destination
    
% if only incorrect tag is in camera frame
% based on global position, correct to point camera at destination tag
else
        
end

% call controls (potentially grab image?)
% controls calls classifier to correct navigation

% shutdown ros
rosshutdown