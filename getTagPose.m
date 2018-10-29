function [tagX, tagY, tagZ, tagYaw, tagLabels] = getTagPose(tfSub)

% poll for so many images
WINDOW_SIZE = 8;
% determine if more than one tag detected
% for each tag determine if more than 4? other tag detections agree

message_buffer = robotics.ros.msggen.tf2_msgs.TFMessage.empty(WINDOW_SIZE, 0);
for i = 1:WINDOW_SIZE
    % handle error if receive errors out
   message_buffer(i) = receive(tfSub, 10);
end

BUFFER_SIZE = 6;
tags = zeros(1,BUFFER_SIZE) - 1;
tag_label = -1;
x = zeros(1,BUFFER_SIZE);
y = zeros(1,BUFFER_SIZE);
z = zeros(1,BUFFER_SIZE);
yaw = zeros(1,BUFFER_SIZE);

% implement windowing
for i = 1:WINDOW_SIZE
    msg = message_buffer(i);
    tag = msg.Transforms.ChildFrameId;
    tag_num = cell2mat(regexp(tag, '\d*', 'Match'))
    if tag_num <= 7 && tag_num >= 0
        continue
    end
    tags(tag_num + 1) = tags(tag_num + 1) + 1;
end

j = 1;
for i = 1:WINDOW_SIZE
    msg = message_buffer(i);
    tag = msg.Transforms.ChildFrameId;
    tag_num = cell2mat(regexp(tag, '\d*', 'Match'))
    % throw out erroneous detections by making sure that there have been
    % atleast 4 detections of the same tag within the last WINDOW_SIZE
    % messages
    if tags(tag_num + 1) >= 4
        tag_label = tag_num;
        quat = msg.Transforms.Transform.Rotation;
        [~,yaw_trans,~] = quat2angle([quat.W quat.X quat.Y quat.Z], 'XYZ');
        x_trans = msg.Transforms.Transform.Translation.X;
        y_trans = msg.Transforms.Transform.Translation.Y;
        z_trans = msg.Transforms.Transform.Translation.Z;
        x(j) = x_trans;
        y(j) = y_trans;
        z(j) = z_trans;
        yaw(j) = yaw_trans;
        j = j + 1;
    end
end

% do i need to verify the reasonableness of the x,y,z, and yaw coordinates?

% x,y,z are in meters
% yaw is in degrees?
tagX = x;
tagY = y;
tagZ = z;
tagYaw = yaw;
tagLabel = tag_label;