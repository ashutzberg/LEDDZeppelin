function [x,y,thetaglobal] = blimpLocalization(detectedTag,tagLocs,sigmaSensor)
%function [x,y,thetaglobal] = blimpLocalization(xTagtoBlimp,yTagtoBlimp,thetaTagtoBlimp,sigmaSensor);

% good input choices would be
% x = 50*sqrt(2), y = 0, rtheta = -3*pi/4, sigmaSensor = 2
% [x,y,theta]

xTagtoBlimp = detectedTag.x;
yTagtoBlimp = detectedTag.y;
thetaTagtoBlimp = detectedTag.yaw;
number = detectedTag.number;

%knowns
tagPose = tagLocs{number + 1};
thetatg1 = tagPose(3); % -pi/2;  % theta of the tag relative to the global frame
xtg1 = tagPose(1);     % x-coordinate of tag 1
ytg1 = tagPose(2);     % y-coordinate of tag 1

sigma = sigmaSensor;
% sensor readings
rtheta = thetaTagtoBlimp;
rx = xTagtoBlimp + (randn*sigma);
ry = yTagtoBlimp + (randn*sigma);

% True location of blimp
true_rtheta = thetaTagtoBlimp;
true_rx = xTagtoBlimp;
true_ry = yTagtoBlimp;

% Transformation matrix between Tag 1 and the Global frame
tagglobal1 = [cos(thetatg1) -sin(thetatg1) xtg1; sin(thetatg1) cos(thetatg1) ytg1; 0 0 1];

% T-matrix of Blimp WITH ERROR to the Tag 1 Frame
blimptag1 = [cos(rtheta) -sin(rtheta) rx; sin(rtheta) cos(rtheta) ry; 0 0 1];

% T-matrix of Blimp withOUT error to the Tag 1 Frame
blimptag1_TRUE = [cos(true_rtheta) -sin(true_rtheta) true_rx; sin(true_rtheta) cos(true_rtheta) true_ry; 0 0 1];

% Multiplaication between 
blimpglobal = tagglobal1 * blimptag1^-1;
blimpglobal_TRUE = tagglobal1 * blimptag1_TRUE^-1;

% Estimated Sensor values of Local Position of Blimp
blimpx = blimpglobal(1,3);
blimpy = blimpglobal(2,3);
blimbThetaGlobal = asin(blimpglobal(2,1));

% True Location of Blimp ( Simulation Only Result )
blimpx_TRUE = blimpglobal_TRUE(1,3)
blimpy_TRUE = blimpglobal_TRUE(2,3)
blimbThetaGlobal_true = asin(blimpglobal_TRUE(2,1))

% figure
% plot(xtg1,ytg1,'rv')
% grid on;
% hold on
% plot(blimpx,blimpy,'g*')
% plot(blimpx_TRUE,blimpy_TRUE,'bl*')
% plot(0,0,'ko')
% pbaspect([1 1 1])
% legend('Tag 1','Measured Blimp Location','True Blimp Location','Global Origin','Location','Northeastoutside')

x = blimpx;
y = blimpy;
thetaglobal = blimbThetaGlobal;