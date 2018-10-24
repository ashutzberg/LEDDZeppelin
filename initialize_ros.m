rosshutdown
rosinit('http://localhost:11311');
tf_sub = rossubscriber('/tf');
image_sub = rossubscriber('/tag_detections_image');

while true
    msg = receive(tf_sub, 10); % 10 s timeout until message
    quat = msg.Transforms.Transform.Rotation;
    rotm = quat2rotm([quat.W quat.X quat.Y quat.Z]);
    %[roll,pitch,yaw] = quat2angle([quat.W quat.X quat.Y quat.Z], 'XYZ')
    [pitch,yaw,roll] = quat2angle([quat.W quat.X quat.Y quat.Z], 'XYZ');
    x = msg.Transforms.Transform.Translation.X
    y = msg.Transforms.Transform.Translation.Y
    z = msg.Transforms.Transform.Translation.Z
    tag_num = msg.Transforms.ChildFrameId
    pause(0.5)
end


sub_detections = rossubscriber('/tag_detections_image');
image = receive(sub_detections, 10);
img = readImage(image);
imshow(img);
