function mp = torque_plot_rd(mp)
%x = [F14x F14y F12x F12y F23y F34x F34y T12] 1x9
lp_sol = mp.lp;
F_14x = lp_sol(1,:);
F_14y = lp_sol(2,:);
F_12x = lp_sol(3,:);
F_12y = lp_sol(4,:);
F_23x = lp_sol(5,:);
F_23y = lp_sol(6,:);
F_34x = lp_sol(7,:);
F_34y = lp_sol(8,:);
T1 = lp_sol(9,:);
mp.FC=zeros(1,length(lp_sol(5,:)));
for i=1:length(lp_sol)
    if (round(abs(F_23x(i)),8) <= round(abs(mp.mu(2)*F_23y(i)),8)) == 1 %friction cone constraints fx leq mu fy
        mp.FC(i) = 1;
    else
        mp.FC(i) = 0;
    end
end

figure
plot(mp.tp,T1)
xlabel('Time s')
ylabel('Torque N m')
legend('T_1')
grid on
figure
subplot(2,1,1)
plot(mp.tp,F_14x,mp.tp,F_14y)
xlabel('Time s')
ylabel('F_{14} N')
legend('F_{14x}','F_{14y}')
grid on
subplot(2,1,2)
plot(mp.tp,F_12x,mp.tp,F_12y)
xlabel('Time s')
ylabel('F_{12} N')
legend('F_{12x}','F_{12y}')
grid on

figure
subplot(2,1,1)
plot(mp.tp,F_23x,mp.tp,F_23y,mp.tp,mp.mu(2)*F_23y,'--',mp.tp,-mp.mu(2)*F_23y,'--')
xlabel('Time s')
ylabel('F_{23} N')
legend('F_{23x}','F_{23y}','\mu_2 F_{23y}','-\mu_2 F_{23y}')
grid on
subplot(2,1,2)
plot(mp.tp,-F_23x,mp.tp,-F_23y,mp.tp,mp.mu(2)*F_23y,'--',mp.tp,-mp.mu(2)*F_23y,'--')
xlabel('Time s')
ylabel('F_{32} N')
legend('F_{32x}','F_{32y}','\mu_2 F_{32y}','-\mu_2 F_{32y}')
grid on 
subplot(2,1,2)
plot(mp.tp,F_34x,mp.tp,F_34y,mp.tp,mp.mu(1)*F_34y,'--',mp.tp,-mp.mu(1)*F_34y,'--')
xlabel('Time s')
ylabel('F_{34} N')
legend('F_{34x}', 'F_{34y}', '\mu_1 F_{34y}', '-\mu_1 F_{34y}')
grid on

figure
plot(mp.tp,mp.FC,'o')
xlabel('Time s')
ylabel('Friction Cone Constraint')
grid on

%{
figure
subplot(3,1,1)
feather(lp_sol(1,:),lp_sol(2,:))
xlabel('Time s')
ylabel('F_{14} N')
grid on
subplot(3,1,2)
feather(lp_sol(3,:),lp_sol(4,:))
xlabel('Time s')
ylabel('F_{12} N')
grid on
subplot(3,1,3)
feather(lp_sol(5,:),lp_sol(6,:))
xlabel('Time s')
ylabel('F_{23} N')
grid on

figure
subplot(1,3,1)
compass(lp_sol(1,:),lp_sol(2,:))
grid on
subplot(1,3,2)
compass(lp_sol(3,:),lp_sol(4,:))
grid on
subplot(1,3,3)
compass(lp_sol(5,:),lp_sol(6,:))
grid on
%}

figure
subplot(4,1,1)
plot(mp.tp,mp.v_links(1,:),mp.tp,mp.v_links(3,:))
xlabel('Time s')
ylabel('v_1 m/s')
legend('v_{x1}', 'v_{y1}')
grid on
subplot(4,1,2)
plot(mp.tp,mp.v_links(2,:),mp.tp,mp.v_links(4,:))
xlabel('Time s')
ylabel('v_2 m/s')
legend('v_{x2}', 'v_{y2}')
grid on
subplot(4,1,3)
plot(mp.tp,mp.a_links(1,:),mp.tp,mp.a_links(3,:))
xlabel('Time s')
ylabel('a_1 m/s^2')
legend('a_{x1}', 'a_{y1}')
grid on
subplot(4,1,4)
plot(mp.tp,mp.a_links(2,:),mp.tp,mp.a_links(4,:))
xlabel('Time s')
ylabel('a_2 m/s^2')
legend('a_{x2}', 'a_{y2}')
grid on
figure
subplot(3,1,1)
plot(mp.tp,mp.theta)
xlabel('Time s')
ylabel('\theta rad')
grid on
subplot(3,1,2)
plot(mp.tp,mp.w(1,:),mp.tp,mp.w(2,:),mp.tp,mp.w(3,:))
xlabel('Time s')
ylabel('\omega rad/s')
legend('\omega_1', '\omega_2', '\omega_3')
grid on
subplot(3,1,3)
plot(mp.tp,mp.alpha(1,:),mp.tp,mp.alpha(2,:),mp.tp,mp.alpha(3,:))
xlabel('Time s')
ylabel('\alpha rad/s^2')
legend('\alpha_1' , '\alpha_2', '\alpha_3')
grid on
end