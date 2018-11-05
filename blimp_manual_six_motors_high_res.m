%GTSR Blimp test code

close all
clear all 
% Object Creaatiossscn
fclose(instrfindall);
blimp = serial('/dev/ttyUSB0','BaudRate',19200,'InputBufferSize',4096);
% Serial communication initialization
fopen(blimp);
% loop 
while(true)
  val = getkey;
  %For Blimp
  if val == 119 %w
      fprintf(blimp,'$01,SETM,300,300,255,255,255,255');
  elseif val == 115 %s
      fprintf(blimp,'$01,SETM,200,200,255,255,255,255');
  elseif val == 97 %a
      fprintf(blimp,'$01,SETM,200,300,255,255,255,255');
  elseif val == 100 %d
     fprintf(blimp,'$01,SETM,300,200,255,255,255,255');
  elseif val == 30 % up
      fprintf(blimp,'$01,SETM,255,255,300,300,255,255'); 
  elseif val == 31 % down
     fprintf(blimp,'$01,SETM,255,255,200,200,255,255'); 
  elseif val == 116 % t
     fprintf(blimp,'$01,SETM,255,255,200,200,100,255'); 
  elseif val == 99 % c close serial port
      fclose(blimp);
      break;
  else
      fprintf(blimp,'$01,SETM,255,255,255,255,255?255');
  end   
  
  
    %% read from blimp
  if blimp.BytesAvailable>0
      buf=fscanf(blimp,'%s') %display data rceived
      %disp(buf);
  end
           
end

    
