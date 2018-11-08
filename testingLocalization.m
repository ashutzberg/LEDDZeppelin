rosshutdown
rosinit('http://localhost:11311');
tfSub = rossubscriber('/tf');
imageSub = rossubscriber('/tag_detections_image');

zero = [0,2.7686,0];
one = [1,1,1];
two = [2,2,2];
three = [3,3,3];
four = [4,4,4];
five = [5,5,5];
six = [6,6,6];
seven = [7,7,7];
tagLocs = {zero one two three, four, five, six, seven};
sigmaSensor = 2;

while (1)
    [tagX, tagY, tagZ, tagYaw, tagLabel] = getSingleTagPose(tfSub)
    detectedTag.x = tagX;
    detectedTag.y = tagY;
    detectedTag.z = tagZ;
    detectedTag.yaw = tagYaw;
    detectedTag.number = tagLabel;
    
    [x,y,thetaglobal] = blimpLocalization(detectedTag,tagLocs,sigmaSensor)
end