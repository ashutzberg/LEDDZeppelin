function [tagX, tagY, tagZ, tagYaw, tagLabel] = getSingleTagPose(tfSub)

msg = receive(tfSub, 10);

tag = msg.Transforms.ChildFrameId;
tag_num = str2num(cell2mat(regexp(tag, '\d*', 'Match')));
tag_label = tag_num;
quat = msg.Transforms.Transform.Rotation;
[~,yaw,~] = quat2angle([quat.W quat.X quat.Y quat.Z], 'XYZ');
x = msg.Transforms.Transform.Translation.X;
y = msg.Transforms.Transform.Translation.Y;
z = msg.Transforms.Transform.Translation.Z;

tagX = x;
tagY = y;
tagZ = z;
tagYaw = yaw;
tagLabel = tag_label;