function [tfSub, imageSub] = initializeRos()

rosshutdown
rosinit('http://localhost:11311');
tfSub = rossubscriber('/tf');
imageSub = rossubscriber('/tag_detections_image');

% while (true)
%     msg = receive(tfSub, 10)
%     tag = msg.Transforms.ChildFrameId
%     quat = msg.Transforms.Transform.Rotation;
%     [~,yaw_trans,~] = quat2angle([quat.W quat.X quat.Y quat.Z], 'XYZ')
%     x_trans = msg.Transforms.Transform.Translation.X
%     y_trans = msg.Transforms.Transform.Translation.Y
%     z_trans = msg.Transforms.Transform.Translation.Z
% end