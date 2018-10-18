rosinit('http://localhost:11311');
sub = rossubscriber('/tf');
msg = receive(sub, 10); % 10 s timeout until message
quat = msg.Transforms.Transform.Rotation;
rotm = quat2rotm([quat.W quat.X quat.Y quat.Z]);
eul = quat2eul([quat.W quat.X quat.Y quat.Z]);
deg = rad2deg(rotm);

sub_detections = rossubscriber('/tag_detections_image');
image = receive(sub_detections, 10);
img = readImage(image);
imshow(img);
