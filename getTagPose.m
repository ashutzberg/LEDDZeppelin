function [tagX, tagY, tagZ, tagYaw, tagLabel] = getTagPose(tfSub)

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
tags = zeros(1,8);
tag_label = -1;
x = zeros(1,BUFFER_SIZE);
y = zeros(1,BUFFER_SIZE);
z = zeros(1,BUFFER_SIZE);
yaw = zeros(1,BUFFER_SIZE);

% implement windowing
for i = 1:WINDOW_SIZE
    msg = message_buffer(i);
    tag = msg.Transforms.ChildFrameId;
    tag_num = str2num(cell2mat(regexp(tag, '\d*', 'Match')));
    if tag_num <= 7 && tag_num >= 0
        tags(tag_num + 1) = tags(tag_num + 1) + 1;
    end
end

j = 1;
for i = 1:WINDOW_SIZE
    msg = message_buffer(i);
    tag = msg.Transforms.ChildFrameId;
    tag_num = str2num(cell2mat(regexp(tag, '\d*', 'Match')));
    % throw out erroneous detections by making sure that there have been
    % atleast 4 detections of the same tag within the last WINDOW_SIZE
    % messages
    if tag_num <= 7 && tag_num >= 0 && tags(tag_num + 1) >= 4
        tag_label = tag_num;
        quat = msg.Transforms.Transform.Rotation;
        [~,yaw_trans,~] = quat2angle([quat.W quat.X quat.Y quat.Z], 'XYZ');
        x_trans = msg.Transforms.Transform.Translation.X
        y_trans = msg.Transforms.Transform.Translation.Y
        z_trans = msg.Transforms.Transform.Translation.Z
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
i = 1;
tagX = 0;
count = 0;
while i <= length(x)
    if x(i) ~= 0
        tagX = tagX + x(i);
    end
    count = count + 1;
    i = i + 1;
end
tagX = tagX / count;
i = 1;
tagY = 0;
count = 0;
while i <= length(y)
    if y(i) ~= 0
        tagY = tagY + y(i);
    end
    count = count + 1;
    i = i + 1;
end
tagY = tagY / count;
i = 1;
tagZ = 0;
count = 0;
while i <= length(z)
    if z(i) ~= 0
        tagZ = tagZ + z(i);
    end
    count = count + 1;
    i = i + 1;
end
tagZ = tagZ / count;
i = 1;
tagYaw = 0;
count = 0;
while i <= length(yaw)
    if yaw(i) ~= 0
        tagYaw = tagYaw + yaw(i);
    end
    count = count + 1;
    i = i + 1;
end
tagLabel = tag_label;