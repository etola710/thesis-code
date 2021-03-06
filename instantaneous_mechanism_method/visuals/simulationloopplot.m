function simulationloopplot(mp)
switch mp.ver
    case('s')
        F_14x = mp.lp(1,:);
        F_14y = mp.lp(2,:);
        F_12x = mp.lp(3,:);
        F_12y = mp.lp(4,:);
        F_23x = mp.lp(5,:);
        F_23y = mp.lp(6,:);
        F_34y = mp.lp(7,:);
        
        for i=1:length(mp.lp)
            F_34x(i) = mp.mu(1)*(-sign(mp.svaj_curve(2,i)))*abs(F_34y(i));
        end
        T1 = mp.lp(8,:);
        T2 = mp.lp(9,:);
    case('t')
        F_14x = mp.lp(1,:);
        F_14y = mp.lp(2,:);
        F_12x = mp.lp(3,:);
        F_12y = mp.lp(4,:);
        F_23x = mp.lp(5,:);
        F_23y = mp.lp(6,:);
        F_34x = mp.lp(7,:);
        F_34y = mp.lp(8,:);
        T1 = mp.lp(9,:);
        T2 = mp.lp(10,:);
end
d_pos = [0, mp.d_pos];
T1_cl = [];
T2_cl = [];

for i = 1:size(mp.cl_torques,3)
    T1_cl = [T1_cl ; mp.cl_torques(1,:,i)];
    T2_cl =[T2_cl ; mp.cl_torques(2,:,i)];
end
T1_cl = [zeros(1,size(mp.cl_torques,2)); T1_cl];
T2_cl =[zeros(1,size(mp.cl_torques,2)); T2_cl];
for i = 1:length(T1_cl)
    if T1_cl(i) == 0
        c(i) = 0;
    else
    c(i) = abs(T2_cl(i))/abs(T1_cl(i));
    end
end
q_x = mp.svaj_curve(1,:);
q_x_s = [0,mp.q(3,:)];

v_x = mp.obj_apprx(1,:);
v_x_s = [0,mp.z(3,:)];
v_y = mp.obj_apprx(2,:);
v_y_s = [0,mp.z(4,:)];
a_x = mp.obj_apprx(3,:);
a_x_s = 0;
a_y = mp.obj_apprx(4,:);
a_y_s = 0;

for i = 2:length(v_x_s)
    a_x_s(i) = (v_x_s(i)- v_x_s(i-1))/mp.dt;
    a_y_s(i) = (v_y_s(i)- v_y_s(i-1))/mp.dt;
end
w1 = mp.w(1,:);
w2 = mp.w(2,:);
w1_s = [0,mp.z(1,:)];
w2_s = [0,mp.z(2,:)];
wo_s = [0,mp.z(5,:)];
a1 = mp.alpha(1,:);
a2 = mp.alpha(2,:);
a1_s = 0;
a2_s = 0;
ao_s = 0;
for i = 2:length(w1_s)
    a1_s(i) = (w1_s(i) - w1_s(i-1))/mp.dt;
    a2_s(i) = (w2_s(i) - w2_s(i-1))/mp.dt;
    ao_s(i) = (wo_s(i) - wo_s(i-1))/mp.dt;
end

F_23y_s = [0 mp.z(22,:)/mp.dt]; %pRB_n
F_23x_s = [0 mp.z(6,:)/mp.dt]; %pRB_t
F_34y_s = [0 mp.z(23,:)/mp.dt]; %pBG_n
F_34x_s = [0 mp.z(7,:)/mp.dt]; %pBG_t

sim_T = 0:mp.dt:mp.total_time;
mp_T = mp.tp;
error(1:size(mp.z,2)+1) = mp.error;
figure
subplot(2,1,1)
plot(mp_T,T1,sim_T,T1_cl);
xlabel('Time s')
ylabel('T_1 Nm')
legend('T_1','T_{1s}')
grid on
subplot(2,1,2)
plot(mp_T,T2,sim_T,T2_cl)
xlabel('Time s')
ylabel('T_2 Nm')
legend('T_2','T_{2s}')
grid on

figure
plot(sim_T,c)
xlabel('Time s')
ylabel('T_2s/T_1s')
grid on

figure
subplot(2,1,1)
plot(mp_T,q_x,sim_T,q_x_s)
xlabel('Time s')
ylabel('Position')
legend('q_x','q_{xs}')
grid on
subplot(2,1,2)
plot(sim_T,d_pos,sim_T,error)
xlabel('Time s')
ylabel('Position Error')
legend('\delta q','Error_{criteria}')
grid on
%{\
figure
subplot(2,1,1)
plot(mp_T,v_x,sim_T,v_x_s)
xlabel('Time s')
ylabel('Velocity m/s')
legend('v_x','v_{x_s}')
grid on
subplot(2,1,2)
plot(mp_T,v_y,sim_T,v_y_s)
xlabel('Time s')
ylabel('Velocity m/s')
legend('v_y','v_{ys}')
grid on
figure
subplot(2,1,1)
plot(mp_T,a_x,sim_T,a_x_s)
xlabel('Time s')
ylabel('Acceleration m/s^2')
legend('a_x','a_{xs}')
grid on
subplot(2,1,2)
plot(mp_T,a_y,sim_T,a_y_s)
xlabel('Time s')
ylabel('Acceleration m/s^2')
legend('a_y','a_{ys}')
grid on

figure
subplot(3,1,1)
plot(mp_T,w1,sim_T,w1_s)
xlabel('Time s')
ylabel('\omega_1 rad/s')
legend('\omega_1', '\omega_1s')
grid on
subplot(3,1,2)
plot(mp_T,w2,sim_T,w2_s)
xlabel('Time s')
ylabel('\omega_2 rad/s')
legend('\omega_2', '\omega_2s')
grid on
subplot(3,1,3)
plot(sim_T,wo_s)
xlabel('Time s')
ylabel('\omega_o rad/s')
grid on

figure
subplot(3,1,1)
plot(mp_T,a1,sim_T,a1_s)
xlabel('Time s')
ylabel('\alpha_1 rad/s^2')
legend('\alpha_1', '\alpha_1s')
grid on
subplot(3,1,2)
plot(mp_T,a2,sim_T,a2_s)
xlabel('Time s')
ylabel('\alpha_2 rad/s^2')
legend('\alpha_2', '\alpha_2s')
grid on
subplot(3,1,3)
plot(sim_T,ao_s)
xlabel('Time s')
ylabel('\alpha_o rad/s^2')
grid on

figure
subplot(2,1,1)
plot(mp_T,F_23x,sim_T,F_23x_s)
xlabel('Time s')
ylabel('F_{23x} N')
legend('F_{23x}','F_{23xs}')
grid on
subplot(2,1,2)
plot(mp_T,F_23y,sim_T,F_23y_s)
xlabel('Time s')
ylabel('F_{23y} N')
legend('F_{23y}','F_{23ys}')
grid on
figure
subplot(2,1,1)
plot(mp_T,F_34x,sim_T,F_34x_s)
xlabel('Time s')
ylabel('F_{34x} N')
legend('F_{34x}','F_{34xs}')
grid on
subplot(2,1,2)
plot(mp_T,F_34y,sim_T,F_34y_s)
xlabel('Time s')
ylabel('F_{34y} N')
legend('F_{34y}','F_{34ys}')
grid on
%}
end