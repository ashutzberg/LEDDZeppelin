function [] = scenario1()

% open connection to blimp
close all
clear all 
% Object Creaation
blimp = serial('COM3','BaudRate',19200,'InputBufferSize',4096);
% Serial communication initialization
fopen(blimp);

% call speech recognition code and decipher the user's destination
[immediate_command, target_destination] = VoicePollingScript()

% keep asking for a new command until a destination is given
while immediate_command ~= 1
    % perform the action given by immediate command
    if val == 119     % forward, w
        fprintf(blimp,'$01,SETM,300,300,255,255,255,255');
    elseif val == 115 % backward, s
        fprintf(blimp,'$01,SETM,200,200,255,255,255,255');
    elseif val == 97  % left, a
        fprintf(blimp,'$01,SETM,200,300,255,255,255,255');
    elseif val == 100 % right, d
        fprintf(blimp,'$01,SETM,300,200,255,255,255,255');
    elseif val == 30  % up
        fprintf(blimp,'$01,SETM,255,255,300,300,255,255');
    elseif val == 31  % down
        fprintf(blimp,'$01,SETM,255,255,200,200,255,255');
    elseif val == 116 % t
        fprintf(blimp,'$01,SETM,255,255,200,200,100,255');
    elseif val == 99  % c close serial port
        fclose(blimp);
        break;
    else
        fprintf(blimp,'$01,SETM,255,255,255,255,255?255');
    end
    [immediate_command, target_destination] = VoicePollingScript()
end

% initialize Ros
[tfSub, imageSub] = initializeRos();

% call classifier
[tagX, tagY, tagZ, tagYaw, tagLabel] = getTagPose(tfSub)
pause(2)

% if no tags within vicinity, limit to number of attempts to poll
% surroundings before starting spiral pattern
while tagLabel == -1
    % turn blimp in increasing circle to increase chance of detecting tag
    tic;
    t = toc;
    % go forward for 5 seconds
    while t < 5
        fprintf(blimp,'$01,SETM,300,300,255,255,255,255');
        t = toc;
    end
    tic;
    t = toc;
    % turn right for 3 seconds
    while t < 3
        fprintf(blimp,'$01,SETM,300,200,255,255,255,255');
        t = toc;
    end
    [tagX, tagY, tagZ, tagYaw, tagLabel] = getTagPose(tfSub)
end

%if tag is located left or right
margin = 0; %specify error margin
while abs(tagX) ~= margin || abs(tagY) ~= margin   
    if tagX < -1*margin %tag left
        fprintf(blimp,'$01,SETM,200,300,255,255,255,255');%move left
    elseif tagX > margin %tag right
        fprintf(blimp,'$01,SETM,300,200,255,255,255,255');%move right
    end
    [tagX, tagY, tagZ, tagYaw, tagLabel] = getTagPose(tfSub); %refresh after move

    if tagY < -1*margin %tag down
        fprintf(blimp,'$01,SETM,255,255,200,200,255,255');%move down
    elseif tagY > margin %tag up
        fprintf(blimp,'$01,SETM,255,255,300,300,255,255');%move up
    end
    [tagX, tagY, tagZ, tagYaw, tagLabel] = getTagPose(tfSub); % refresh after move
end

rosshutdown
