%Code for demo

%GTSR Blimp test code
 %f = 334.62;
  f = 175;
 widthM=0.19;
 set_point_distance=0.6;
close all
delete(instrfindall);
% Object Creaationa
blimp = serial('COM6','BaudRate',19200,'InputBufferSize',4096);
% Serial communication initialization
fopen(blimp);
% Create the face detector object.
profileDetector = vision.CascadeObjectDetector('haarcascade_profileface.xml', 'MinSize', [50,50], 'MaxSize', [250,250], 'ScaleFactor', 1.6, 'MergeThreshold', 4);
faceDetector = vision.CascadeObjectDetector('haarcascade_frontalface_alt.xml', 'MinSize', [50,50], 'MaxSize', [250,250], 'ScaleFactor', 1.6, 'MergeThreshold', 4);
% Create the point tracker object.a
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
% Create the video object.
cam = videoinput('winvideo',1,'YUY2_720x480');
set(cam,'ReturnedColorSpace','rgb');
 %Create video writer
x = VideoWriter('GT_demo_0925.avi');
% +
x.FrameRate = 10;
% 
open(x);
% Capture one frame to get its size.
videoFrame = getsnapshot(cam);
frameSize = size(videoFrame);
% Create the video player object.
videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);

% Constants and Parameters
V2thrust = 1/127 * (3.8) * (2) * 1 / 116.59; % Thrust converting factor
d2r=pi/180;
dt=0.111; 
s1 = '$01'; s2 = ',SETM,'; b = ',';
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
% PID Gains 
% % Height Controller
% Kp_z=1.3120;
% Ki_z=0.0174;
% Kd_z=1.4704;
% % Kp_z=0.057907;
% % Ki_z=0.0005447;
% % Kd_z=0.28098;
% 
% % Heading Controller
% Kp_yaw=0.1955; 
% Ki_yaw=0;      
% Kd_yaw=0.192;  
% % Range Controller
% Kp_dist=0.0125;
% Ki_dist=1.0472e-04;
% Kd_dist=0.0658;
% % Kp_dist=0.006271;
% % Ki_dist=1.0472e-04;
% % Kd_dist=0.03288;

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

runLoop = true;
numPts = 0;
frameCount = 0;

triggerconfig(cam,'manual');
start(cam);

while runLoop
    % Get the next frame.
    videoFrame = getsnapshot(cam); 
   % step(videoPlayer, videoFrame);
    videoFrameGray = rgb2gray(videoFrame);
    frameCount = frameCount + 1;

    if numPts < 10 || frameCount<10
        % Detection mode.
        bboxfront = step(faceDetector, videoFrameGray);
        bboxprofile = step(profileDetector, videoFrameGray);
        bbox = [];
        % Determine frontal or profile or none
        if ~isempty(bboxfront)
            bbox = bboxfront;
        elseif ~isempty(bboxprofile)
            bbox = bboxprofile;
        end
        if ~isempty(bbox)
            widthP = bbox(3);
            distanceToCam = f*widthM/widthP;
            % Find corner points inside the detected region.
            points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));
            % Re-initialize the point tracker.
            xyPoints = points.Location;
            numPts = size(xyPoints,1);
            release(pointTracker);
            initialize(pointTracker, xyPoints, videoFrameGray);
            % Save a copy of the points.
            oldPoints = xyPoints;
            % Convert the rectangle represented as [x, y, w, h] into an
            % M-by-2 matrix of [x,y] coordinates of the four corners. This
            % is needed to be able to transform the bounding box to display
            % the orientation of the face.
            bboxPoints = bbox2points(bbox(1, :));
            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);
            % Display a bounding box around the detected face.
            videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
            % Display detected corners.
            videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
            label = strcat('Face, distance: ', num2str(distanceToCam), ' meters');
            videoFrame = insertText(videoFrame, [0,0], label, 'FontSize', 30, 'BoxColor', 'yellow', 'TextColor', 'white');
            videoFrame = insertObjectAnnotation(videoFrame, 'rectangle', bbox, 'Face', 'LineWidth', 3);
            
        end
    else
        % Tracking mode.
        frontFound = false;
        rightProfileFound = false;
        leftProfileFound = false;
        [xyPoints, isFound] = step(pointTracker, videoFrameGray);
        visiblePoints = xyPoints(isFound, :);
        oldInliers = oldPoints(isFound, :);
        numPts = size(visiblePoints, 1);
        tbbox = step(faceDetector, videoFrameGray);
        if ~isempty(tbbox)
            frontFound = true;
        else
            tbbox = step(profileDetector, videoFrameGray);
            if ~isempty(tbbox)
                rightProfileFound = true;
                label = strcat('Left Face');
                videoFrame = insertText(videoFrame, [0,80], label, 'FontSize', 30, 'BoxColor', 'red', 'TextColor', 'white');
            else
                tbbox = step(profileDetector, flip(videoFrameGray,2));
                if ~isempty(tbbox)
                    leftProfileFound = true;
                    label = strcat('Right Face');
                    videoFrame = insertText(videoFrame, [0,80], label, 'FontSize', 30, 'BoxColor', 'red', 'TextColor', 'white');
                end
            end
        end
        
        if numPts >= 10
            % Estimate the geometric transformation between the old points
            % and the new points.
            [xform, oldInliers, visiblePoints] = estimateGeometricTransform(oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
            % Apply the transformation to the bounding box.
            bboxPoints = transformPointsForward(xform, bboxPoints);
            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);
            
            
            %widthP = abs((bboxPolygon(1)+bboxPolygon(7))/2 - (bboxPolygon(3)+bboxPolygon(5))/2);
            widthP = sqrt(((bboxPolygon(1)+bboxPolygon(7))/2 - (bboxPolygon(3)+bboxPolygon(5))/2)^2+((bboxPolygon(2)+bboxPolygon(8))/2 - (bboxPolygon(4)+bboxPolygon(6))/2)^2);
            
            distanceToCam = f*widthM/widthP;
            label = strcat('Tracked Face, distance: ', num2str(distanceToCam), ' meters');
            % Display a bounding box around the face being tracked.
            videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
            % Display tracked points.
            videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');
            videoFrame = insertText(videoFrame, [0,0], label, 'FontSize', 30, 'BoxColor', 'yellow', 'TextColor', 'white'); 
            L_met = widthM;
            L_pix = widthP;
            ratio = L_met/L_pix;
            range = distanceToCam;
            center_frame_z = 240;
            center_face_z = mean(bboxPoints(:,2));
            center_frame_x = 360;
            center_face_x = mean(bboxPoints(:,1));
            
            
            % Calculate yaw
            yaw = asin((center_face_x - center_frame_x)*ratio/range)/pi*180;
            yaw = -yaw;
            % Height of human in meters
            h_human = 1.60;
            reference_z = h_human;
            reference_yaw = 0;
            % Height of blimp in meters
            h_blimp = ratio*(center_face_z - center_frame_z) + h_human;
           
            % PID for z-axis (height)
            error_z=reference_z-h_blimp;  
            [thrust_z,thrust_i_z] = PIDcontroller(Kp_z,Ki_z,Kd_z,error_z,prev_error_z,thrust_i_z,dt);
            thrust_z = thrust_z / V2thrust;
            if thrust_z>0
                thrust_z=thrust_z*0.8;
            end
            prev_error_z=error_z;%update error_z
           
            % PID for Yaw
            error_yaw = calc_yaw_error(reference_yaw,yaw)*d2r; 
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
            % Send commands
            t = int2str(thrust_z_PWM); l = int2str(left_PWM); r = int2str(right_PWM);
            side = int2str(thrust_side);
            cmd = strcat(s1,s2,l,b,r,b,t,b,t,b,side,b,'255');
            fprintf(blimp,cmd);
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
            
        end
    end
    %if max(range(videoFrameGray)) ~= 75
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    writeVideo(x,videoFrame);
    %end
    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
end
% Clean up.
close all;
objects=imaqfind;
delete(objects);
clear cam;
close(x);
release(videoPlayer);
release(pointTracker);
release(faceDetector);
release(profileDetector);
delete(instrfindall);
delete(blimp)
clear blimp;

close all;
objects=imaqfind;
delete(objects);