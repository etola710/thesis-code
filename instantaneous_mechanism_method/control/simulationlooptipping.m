function mp = simulationlooptipping(mp)
h=figure;
ax=axes(h,'XLim',[-.1,.2],'YLim',[-.1,.2]);
hold on
finger=line(ax);
finger.Parent=ax;
finger.LineWidth=2;
finger.Color='b';
finger.Marker='o';
obj=line(ax);
obj.Parent=ax;
obj.LineWidth=2;
obj.Color='g';
obj_cg = plot(ax,0,0,'o');
obj_cg.Color='g';
obj_cg.LineWidth=2;
desired_pos = plot(ax,0,0,'o');
desired_pos.Color='r';
desired_pos.LineWidth=2;
f1 = quiver(ax,0,0,0,0);
f2 = quiver(ax,0,0,0,0);
f3 = quiver(ax,0,0,0,0);
f4 = quiver(ax,0,0,0,0);
f5 = quiver(ax,0,0,0,0);
f6 = quiver(ax,0,0,0,0);
f7 = quiver(ax,0,0,0,0);
f8 = quiver(ax,0,0,0,0);
f9 = quiver(ax,0,0,0,0);
f10 = quiver(ax,0,0,0,0);
f11= quiver(ax,0,0,0,0);
f12 = quiver(ax,0,0,0,0);
f13= quiver(ax,0,0,0,0);
f14 = quiver(ax,0,0,0,0);
f15 = quiver(ax,0,0,0,0);
f16 = quiver(ax,0,0,0,0);
f17 = quiver(ax,0,0,0,0);
vectors = [f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16 f17];
for i =1:length(vectors)
    vectors(i).LineWidth = 2;
    vectors(i).AlignVertexCenters='on';
    vectors(i).Marker = '.';
    vectors(i).AutoScale='off';
    vectors(i).MaxHeadSize = .01;
end
forces = [f1 f2 f3 f15];
for i = 1:length(forces)
    forces(i).Color='r';
    forces(i).MarkerFaceColor='r';
end

f4.Color='b';
f4.MarkerFaceColor='b';

vels = [f5 f7 f9];
accels = [f6 f8 f10];
for i=1:length(vels)
    vels(i).Color='c';
    vels(i).MarkerFaceColor='c';
    accels(i).Color='m';
    accels(i).MarkerFaceColor='m';
end

%{\
%radii
radii_g = [f11 f13 f16];
radii_y = [f12 f14 f17];
for i = 1:length(radii_g)
    radii_g(i).Color='g';
    radii_g(i).LineStyle = '--';
    radii_g(i).MarkerFaceColor='g';
    radii_y(i).Color='y';
    radii_y(i).LineStyle = '--';
    radii_y(i).MarkerFaceColor='y';
end


str = '';
an=annotation(h,'textbox',[.6 .75 .1 .1],'String',str,'FitBoxToText','on');

scaling = .1;
%s_fun = @(a,b) a/max(abs(b));
%F_34y = lp_sol(6,:) + mp.mass(3)*mp.g_force(2);

tic
initial_N = 1; % initial time to simulate
N = 1; %number of steps to simulate
cl_struct = mp; %initialize structure
cl_struct.lp_steps = 2; %planning predict horizon
total_time = 0;
mp.error = .0005;
counter = 1;
for i = 1:length(mp.pos)
    itr = 1;
    d_pos = 1000; %arbitrary
    while d_pos >=  mp.error
        %simulation
        %perform simulation
        [z_d,q_d,~] = simulation_2R_block(cl_struct,initial_N,N);
        %update structure
        q(:,:,counter) = q_d(:,initial_N); %use the initial N step
        z(:,counter) = z_d(:,initial_N); %use the initial N step
        current_pos = q(5,1,counter);
        d_pos = abs(mp.pos(i) - current_pos);
        mp.d_pos(counter) = d_pos;
        %planner
        %select proper time interval
        %time scaling - currently constant
        if i == 1
            dist = abs(mp.pos(i) - q(5,1,1));
            if dist > 0
                time_scale = (d_pos/dist)*mp.timescale;
            else
                time_scale = mp.timescale;
            end
        else
            time_scale = (d_pos/abs(mp.pos(i) - mp.pos(i-1)))*mp.timescale;
        end
        if time_scale <= mp.dt
            time_scale = 1.2*mp.dt;
        else
            cl_struct.time(:) = time_scale;
        end
        cl_struct.time
        %compute LP for each instance
        %torques_1 = zeros(1,round(time/mp.dt)+1,N);
        %torques_2 = zeros(1,round(time/mp.dt)+1,N);
        cl_struct.pos = [current_pos mp.pos(i)]; %current state to goal state
        %planner
        cl_struct.obj_cg = [q(3,1,counter) q(4,1,counter)];
        cl_struct.obj_cg
        cl_struct = tipping_fun(cl_struct);
        %sum torques
        current_pos
        mp.pos(i)
        %cl_struct.lp
        %cl_struct.lp(8,:);
        %cl_struct.lp(9,:);
        T1 = (sum(cl_struct.lp(8,:)))/cl_struct.lp_steps;
        T2 = (sum(cl_struct.lp(9,:)))/cl_struct.lp_steps;
        %update structure with new torque values
        mp.cl_torques(:,:,counter)= [T1 ; T2];
        %{\
        %visualization
        [joint_pos , cg_pos]=DK_2R(mp.links,[q(1,1,counter) q(2,1,counter)]);
        lp_sol = cell2mat(cl_struct.x);
        F23x_s = z(6,counter)/mp.dt;
        F23y_s = z(22,counter)/mp.dt;
        F34x_s = z(7,counter)/mp.dt;
        F34y_s = z(23,counter)/mp.dt;
        x_j = joint_pos(1,:);
        y_j = joint_pos(2,:);
        x_cg = cg_pos(1,:);
        y_cg = cg_pos(2,:);
        po_cg = [q(3,1,counter) q(4,1,counter)];
        v_cg = cl_struct.v_cg;
        a_cg = cl_struct.a_cg;
        vo_x = z(3,counter)/mp.dt;
        vo_y = z(4,counter)/mp.dt;
        if counter == 1
            v_x(:,counter) = [0;0];
            v_y(:,counter) = [0;0];
            a_x = [0;0];
            a_y = [0;0];
            ao_x = 0;
            ao_y = 0;
        else
            [~ , cg_pos_old]=DK_2R(mp.links,[q(1,1,counter-1) q(2,1,counter-1)]);
            x_cg_old = cg_pos_old(1,:);
            y_cg_old = cg_pos_old(2,:);
            %links
            v_x(:,counter) = [(x_cg(1) - x_cg_old(1))/mp.dt ; (x_cg(2) - x_cg_old(2))/mp.dt];
            v_y(:,counter) = [(y_cg(1) - y_cg_old(1))/mp.dt ; (y_cg(2) - y_cg_old(2))/mp.dt];
            a_x = [(v_x(1,counter)-v_x(1,counter-1))/mp.dt ; (v_x(2,counter)-v_x(2,counter-1))/mp.dt];
            a_y = [(v_y(1,counter)-v_y(1,counter-1))/mp.dt ; (v_y(2,counter)-v_y(2,counter-1))/mp.dt];
            %object
            ao_x = (vo_x-z(3,(counter-1))/mp.dt)/mp.dt;
            ao_y = (vo_y-z(4,(counter-1))/mp.dt)/mp.dt;
        end
        xgph = [0, x_j(1) x_j(2)];
        ygph = [0, y_j(1) y_j(2)];
        finger.XData=xgph;
        finger.YData=ygph;
        obj.XData=[cl_struct.xbox(1,1),cl_struct.xbox(2,1),cl_struct.xbox(3,1),cl_struct.xbox(4,1),cl_struct.xbox(1,1)];
        obj.YData=[cl_struct.ybox(1,1),cl_struct.ybox(2,1),cl_struct.ybox(3,1),cl_struct.ybox(4,1),cl_struct.ybox(1,1)];
        obj_cg.XData = po_cg(1);
        obj_cg.YData = po_cg(2);
        desired_pos.XData = mp.pos(i);
        desired_pos.YData = mp.dim(1)/2;
        f1.XData = 0;
        f1.YData = 0;
        f1.UData = scaling*lp_sol(1,1); %F_14x
        f1.VData = scaling*lp_sol(2,1); %F_14y
        f2.XData = x_j(1);
        f2.YData = y_j(1);
        f2.UData = scaling*lp_sol(3,1); %F_12x
        f2.VData = scaling*lp_sol(4,1); %F_12y
        f3.XData = x_j(2);
        f3.YData = y_j(2);
        f3.UData = scaling*F23x_s; %F_23x
        f3.VData = scaling*F23y_s; %F_23y
        f4.XData = x_j(2);
        f4.YData = y_j(2);
        f4.UData = -scaling*F23x_s; %F_32x = -F_23x
        f4.VData = -scaling*F23y_s; %F_32y = -F_23y
        f15.XData = cl_struct.tip_pnt(1);
        f15.YData = cl_struct.tip_pnt(2);
        f15.UData = scaling*F34x_s; %F_34x
        f15.VData = scaling*F34y_s; %F_34y
        
        f5.XData = x_cg(1);
        f5.YData = y_cg(1);
        f5.UData = scaling*v_x(1,counter); %v_x1
        f5.VData = scaling*v_y(1,counter); %v_y1
        f6.XData = x_cg(1);
        f6.YData = y_cg(1);
        f6.UData = scaling*a_x(1); %a_x1
        f6.VData =scaling*a_y(1);  %a_y1
        f7.XData = x_cg(2);
        f7.YData = y_cg(2);
        f7.UData = scaling*v_x(2,counter); %v_x2
        f7.VData = scaling*v_y(2,counter);  %v_y2
        f8.XData = x_cg(2);
        f8.YData = y_cg(2);
        f8.UData = scaling*a_x(2); %a_x2
        f8.VData = scaling*a_y(2);  %a_y2
        f9.XData = po_cg(1);
        f9.YData = po_cg(2);
        f9.UData = scaling*vo_x; %v_ox
        f9.VData = scaling*vo_y;  %v_oy
        f10.XData = po_cg(1);
        f10.YData = po_cg(2);
        f10.UData = scaling*ao_x; %a_ox
        f10.VData = scaling*ao_y;  %a_oy
        
        dir1 = vec2ang([0;0],[x_cg(1);y_cg(1)]);
        dir2 = vec2ang([x_j(1);y_j(1)],[x_cg(1);y_cg(1)]);
        dir3 = vec2ang([x_j(1);y_j(1)],[x_cg(2);y_cg(2)]);
        dir4 = vec2ang([x_j(2);y_j(2)],[x_cg(2);y_cg(2)]);
        dir5 = vec2ang(cl_struct.tip_pnt,po_cg);
        dir6 = vec2ang(cl_struct.p_cw(:,1),po_cg);
        [r_14x,r_14y] = vector_lncs(mp.r1_mag,dir1);
        [r_12x,r_12y] = vector_lncs(mp.r1_mag,dir2);
        %link 2
        [r_21x,r_21y] = vector_lncs(mp.r2_mag,dir3);
        [r_23x,r_23y] = vector_lncs(mp.r2_mag,dir4);
        %link 3
        [r_32x,r_32y] = vector_lncs(mp.r3_mag,dir5);
        [r_34x,r_34y] = vector_lncs(mp.r3_mag,dir6);
        
        f11.XData = x_cg(1);
        f11.YData = y_cg(1);
        f11.UData = r_14x; %r_14x
        f11.VData = r_14y;  %r_14y
        f12.XData = x_cg(1);
        f12.YData = y_cg(1);
        f12.UData = r_12x; %r_12x
        f12.VData = r_12y;  %r_12y
        f13.XData = x_cg(2);
        f13.YData = y_cg(2);
        f13.UData = r_21x; %r_21x
        f13.VData = r_21y;  %r_21y
        f14.XData = x_cg(2);
        f14.YData = y_cg(2);
        f14.UData = r_23x; %r_23x
        f14.VData = r_23y;  %r_23y
        f16.XData = po_cg(1);
        f16.YData = po_cg(2);
        f16.UData = r_32x; %r_32x
        f16.VData = r_32y;  %r_32y
        f17.XData = po_cg(1);
        f17.YData = po_cg(2);
        f17.UData = r_34x; %r_34x
        f17.VData = r_34y;  %r_34y
        
        str = sprintf('t = %f seconds',total_time);
        an.String = str;
        
        drawnow
        pause(.1)
        frame = getframe(h);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if i == 1
            imwrite(imind,cm,mp.filename1,'gif','Loopcount',inf);
        else
            imwrite(imind,cm,mp.filename1,'gif','WriteMode','append','DelayTime',1/mp.gif_fps);
        end
        %}
        %iteration limit
        if itr >=  500
            warning('Maximum Number of Iterations Reached');
            return;
        else
            itr = itr + 1;
        end
        counter = counter + 1;
        total_time = total_time + mp.dt;
        sprintf('count = %d\n itr = %d\n',counter,itr);
    end
end
toc
mp.q=q;
mp.z=z;
sprintf('Simulation Complete')
end