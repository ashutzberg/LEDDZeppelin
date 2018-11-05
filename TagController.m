
function TagController
% Yaw is angle in x-y given from ROS (blimp to tag)
% distance is the range displacement from blimp to tag in the x-y plane given from ROS
% height is the vertical displacement from blimp to tag given from ROS




% Object Creaation
blimp = serial('ttyUSB0','BaudRate',19200,'InputBufferSize',4096);
% Serial communication initialization
fopen(blimp);

%Initialize ROS
[tfSub,imageSub] = initializeROS();

V2thrust = 1/127 * (3.8) * (2) * 1 / 116.59; % Thrust converting factor
d2r=pi/180;
dt=0.111;
s1 = '$01'; s2 = ',SETM,'; b = ',';

set_point_distance=0.5;

% Initial Values
x_cal=0;
y_cal=0;
z_cal=0;
thrust_x=0;
thrust_z_PWM=255;
left_PWM=255;
right_PWM=255;
prev_error_z=0;
prev_error_yaw=0;
prev_error_dist=0;
thrust_i_yaw=0;
thrust_i_z=0;
thrust_i_dist=0;

% Height Controller
Kp_z=1.3120/2;
Ki_z=0.0174;
Kd_z=1.4704;

% Heading Controller
Kp_yaw=0.3910;
Ki_yaw=0;
Kd_yaw=0.3840;

% Range Controller
Kp_dist=0.0125;
Ki_dist=1.0472e-04;
Kd_dist=0.0658;

while(1)
 
[tagX, tagY, tagZ, tagYaw, tagLabels] = getTagPose(tfSub);

range = sqrt(tagX^2 + tagY^2 + tagZ^2);              % Input from ROS
zdisp = tagY;               % Input Z height from ROS
yaw = tagYaw;                      %Input from ROS

% Calculate yaw
reference_yaw = pi;

% Height of Tag in meters
h_tag = 2.45;           % the average height of the tag will be 8 feet, or about 2.45 meters
reference_z = h_tag;

% Height of blimp in meters
h_blimp = zdisp + h_tag;


% PID for z-axis (height)
error_z=reference_z-h_blimp;
[thrust_z,thrust_i_z] = PIDcontroller(Kp_z,Ki_z,Kd_z,error_z,prev_error_z,thrust_i_z,dt);
thrust_z = thrust_z / V2thrust;
if thrust_z>0
thrust_z=thrust_z*0.8;
end
prev_error_z=error_z;%update error_z

% PID for Yaw

% Angle Wrapping ...
yaw = -yaw;


error_yaw = reference_yaw - yaw;
if error_yaw > pi
    error_yaw  = error_yaw - 2*pi;
end
if error_yaw < -pi
    error_yaw = error_yaw + 2*pi;
end  


[thrust_yaw,thrust_i_yaw] = PIDcontroller(Kp_yaw,Ki_yaw,Kd_yaw,error_yaw,prev_error_yaw,thrust_i_yaw,dt);
thrust_yaw = thrust_yaw /V2thrust;
prev_error_yaw=error_yaw;%update previous yaw_error

% PID to Reduce Error Distance from Current Position to a Waypoint
error_dist_previous = range-set_point_distance;
error_dist = error_dist_previous;
[thrust_dist,thrust_i_dist] = PIDcontroller(Kp_dist,Ki_dist,Kd_dist,error_dist,prev_error_dist,thrust_i_dist,dt);
prev_error_dist=error_dist;
thrust_dist=thrust_dist/V2thrust;
if (thrust_dist<0)
thrust_dist=thrust_dist*2;
end
if (abs(reference_yaw-yaw)<30)
thrust_x=thrust_dist;
else
thrust_x=0;
end
% change PID output to PWM motor command
thrust_z_PWM=thrust_z+256;
left_PWM =(thrust_x+256)+thrust_yaw;
right_PWM=(thrust_x+256)-thrust_yaw;
thrust_side = 255;
%             if leftProfileFound
%                 thrust_side = 305;
%             elseif rightProfileFound
%                 thrust_side = 155;
%             end
% Saturation for X-Y motor
if (left_PWM>511)
left_PWM=511;
end
if (left_PWM<0)
left_PWM=0;
end
if (right_PWM>511)
right_PWM=511;
end
if (right_PWM<0)
right_PWM=0;
end
if (thrust_z_PWM<0)
thrust_z_PWM=0;
end
if (thrust_z_PWM>511)
thrust_z_PWM=511;
end

% Send commands
t = int2str(thrust_z_PWM); l = int2str(left_PWM); r = int2str(right_PWM);
%side = int2str(thrust_side);
cmd = strcat(s1,s2,l,b,r,b,t,b,t,b,'255',b,'255') % this is the command to feed the arduino controller ...
fprintf(blimp,cmd);
% oldPoints = visiblePoints;
% setPoints(pointTracker, oldPoints);
end
end