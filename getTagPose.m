function [tagX, tagY, tagZ, tagYaw, tagLabel] = getTagPose(tfSub)

% poll for so many images
% determine if more than one tag detected
% for each tag determine if more than 4? other tag detections agree

message_buffer = zeros(1,20)
for i = 1:20
   message_buffer(i) = receive(tfSub, 10);
end
tags = zeros(1,8)
for i = 1:20
    msg = message_buffer(i)
    tag = msg.Transforms.ChildFrameId
    tag_num = regexp(tag, '\d*', 'Match');
    
    quat = msg.Transforms.Transform.Rotation;
    [pitch,yaw,roll] = quat2angle([quat.W quat.X quat.Y quat.Z], 'XYZ');
    x = msg.Transforms.Transform.Translation.X;
    y = msg.Transforms.Transform.Translation.Y;
    z = msg.Transforms.Transform.Translation.Z;
    
end
msg = receive(tfSub, 10); % 10 s timeout until message
quat = msg.Transforms.Transform.Rotation;
rotm = quat2rotm([quat.W quat.X quat.Y quat.Z]);
%[roll,pitch,yaw] = quat2angle([quat.W quat.X quat.Y quat.Z], 'XYZ')
[pitch,yaw,roll] = quat2angle([quat.W quat.X quat.Y quat.Z], 'XYZ');
x = msg.Transforms.Transform.Translation.X
y = msg.Transforms.Transform.Translation.Y
z = msg.Transforms.Transform.Translation.Z
tag_num = msg.Transforms.ChildFrameId


