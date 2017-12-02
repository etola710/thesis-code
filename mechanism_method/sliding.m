clearvars
close all
%Sliding Motion
%Object is Rectangular
addpath(genpath('mechanism_method'))
%finger dimensions
links = [.08 .05]; %m
mass = [.5 .3 .3]; %kg
I = [(mass(1)*links(1)^2)/12 (mass(2)*links(2)^2)/12]; %moment of inertias kg m^2
%object dimensions
dim = [.03 .05]; %m [height length]
dt = .01;
mu = [.3 .9]; %friction coefficents [object/floor , finger/object]
time = .5; %s time for motion
pos = [.1 .05]; %m x coordinate [inital final]
%generate sliding motion plan
[p_j,accel,R,alpha,svaj_curves,tp,xbox,ybox]=sliding_motion(links,pos,dim,time,dt);
svaj_plot(tp,svaj_curves);
%lp dynamics
x=cell(1,length(svaj_curves));
fval=1:length(svaj_curves);
for i=1:length(svaj_curves)
[lp,fval,exitflag] = lp_dynamics_sliding(mass,accel(:,i),alpha,R(:,i),mu,svaj_curves(2,i),svaj_curves(3,i),I);
x{i} = lp;
exitflag
end
torque_plot(tp,x);
filename ='sliding.gif';
sliding_plot(p_j(1:2,:),p_j(3:4,:),xbox,ybox,length(x),filename);