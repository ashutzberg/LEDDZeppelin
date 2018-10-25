function [tagX, tagY, tagZ, tagYaw, tagLabels] = getTagPose(tfSub)

% poll for so many images
WINDOW_SIZE = 12;
% determine if more than one tag detected
% for each tag determine if more than 4? other tag detections agree

message_buffer = robotics.ros.msggen.tf2_msgs.TFMessage.empty(WINDOW_SIZE, 0);
for i = 1:WINDOW_SIZE
    % handle error if receive errors out
   message_buffer(i) = receive(tfSub, 10);
end

BUFFER_SIZE = 8;
TAG_COUNT = 2;
tags = zeros(1,BUFFER_SIZE);
tag_labels = [-1, -1];
first_tag_x = zeros(1,BUFFER_SIZE);
first_tag_y = zeros(1,BUFFER_SIZE);
first_tag_z = zeros(1,BUFFER_SIZE);
first_tag_yaw = zeros(1,BUFFER_SIZE);

second_tag_x = zeros(1,BUFFER_SIZE);
second_tag_y = zeros(1,BUFFER_SIZE);
second_tag_z = zeros(1,BUFFER_SIZE);
second_tag_yaw = zeros(1,BUFFER_SIZE);

% implement windowing
for i = 1:WINDOW_SIZE
    msg = message_buffer(i);
    tag = msg.Transforms.ChildFrameId;
    tag_num = cell2mat(regexp(tag, '\d*', 'Match'))
    if tag_num <= 7 && tag_num >= 0
        continue
    end
    tags(tag_num) = tags(tag_num) + 1;
end

first_i = 1;
second_i = 1;
for i = 1:WINDOW_SIZE
    msg = message_buffer(i);
    tag = msg.Transforms.ChildFrameId;
    tag_num = cell2mat(regexp(tag, '\d*', 'Match'))
    % throw out erroneous detections by making sure that there have been
    % atleast 4 detections of the same tag within the last WINDOW_SIZE
    % messages
    if tags(tag_num) >= 4
        if first_i == 1
            tag_labels(1) = tag_num
        else
            tag_labels(2) = tag_num
        end
        quat = msg.Transforms.Transform.Rotation;
        [~,yaw,~] = quat2angle([quat.W quat.X quat.Y quat.Z], 'XYZ');
        x = msg.Transforms.Transform.Translation.X;
        y = msg.Transforms.Transform.Translation.Y;
        z = msg.Transforms.Transform.Translation.Z;
        if tag_num == tag_labels(1)
            first_tag_x(first_i) = x;
            first_tag_y(first_i) = y;
            first_tag_z(first_i) = z;
            first_tag_yaw(first_i) = yaw;
            first_i = first_i + 1;
        else
            second_tag_x(second_i) = x;
            second_tag_y(second_i) = y;
            second_tag_z(second_i) = z;
            second_tag_yaw(second_i) = yaw;
            second_i = second_i + 1;
        end
    end
end

% do i need to verify the reasonableness of the x,y,z, and yaw coordinates?

% x,y,z are in meters
% yaw is in degrees?
tagX = [first_tag_x; second_tag_x]
tagY = [first_tag_y; second_tag_y]
tagZ = [first_tag_z, second_tag_z]
tagYaw = [first_tag_yaw; second_tag_yaw]
tagLabels = tag_labels