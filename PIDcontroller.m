function [thrust,thrust_i]=PIDcontroller(Kp,Ki,Kd,error,prev_error,thrust_i,dt)

  thrust_p=Kp*error;
  thrust_i=thrust_i+Ki*dt*error;
  thrust_d=Kd*(error-prev_error)/dt;
  thrust=thrust_p+thrust_i+thrust_d;

end