function [] = blimpManager(voice_destination)

% call speech recognition code and decipher the user's destination
[immediate_command, target_destination] = VoicePollingScript()

% keep asking for a new command until a destination is given
while immediate_command ~= 1
    % perform the action given by immediate command
    
    [immediate_command, target_destination] = VoicePollingScript()
end

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
detectedTag.x = tagX;
detectedTag.y = tagY;
detectedTag.z = tagZ;
detectedTag.yaw = tagYaw;
detectedTag.number = tagLabel;
% tags.tag_number = [x m, y m, theta radians] all relative to global frame
zero = [0,0,0];
one = [1,1,1];
two = [2,2,2];
three = [3,3,3];
four = [4,4,4];
five = [5,5,5];
six = [6,6,6];
seven = [7,7,7];
tagLocs = [zero, one, two, three, four, five, six, seven];
sigmaSensor = 2;
[x,y,thetaglobal] = blimpLocalization(detectedTag,tagLocs,sigmaSensor);

% if correct tag is within camera frame
if detectedTag.label == target_destination
    % call controls code to go to tag
    
% if correct tag is not within the camera frame    
else
    % start turning the blimp
    % keep calling the classifier and turning until the destination tag is
    % within the frame
        
end

% call controls (potentially grab image?)
% controls calls classifier to correct navigation

% shutdown ros
rosshutdown
