function [F, J, domerr] = mcp_funjac_2R_manipulator_block_simplified(z, jacflag)
%% initialize
z = z(:);
F = [];
J = [];
domerr = 0;

%% obtain value of global variables
global h;

global q_old ;
theta_1o = q_old(1);
theta_2o = q_old(2);
q_xo = q_old(3); 
q_yo = q_old(4);
theta_o = q_old(5);


global nu_old;
w_1o =nu_old(1);
w_2o =nu_old(2);
v_xo =nu_old(3); 
v_yo =nu_old(4); 
w_o = nu_old(5); 
 
global I_z1 I_z2 m1 m2 L1 L2 r1 r2 m I_z H L g muRB muBG eRB_t eBG_t ;


global tau_1 tau_2 p_x p_y p_z ;


%% unknown variables

w_1 = z(1);
w_2 = z(2); 
v_x = z(3);
v_y = z(4); 
w  = z(5);

pRB_t = z(6);
pBG_t = z(7);

a1RB_x = z(8); 
a1RB_y = z(9); 
a1BG_x = z(10); 
a1BG_y = z(11); 
a2BG_x = z(12); 
a2BG_y = z(13); 

sigRB = z(14);  
sigBG = z(15);  

lRB_k = z(16); 
lRB_1 = z(17);  

lBG_k = z(18);  
lBG_1 = z(19);  
lBG_2 = z(20);  
lBG_3 = z(21);  
lBG_4 = z(22); 

pRB_n = z(23);
pBG_n = z(24);



%% configuration  (chain rules)

q_x = q_xo +h*v_x;
q_y = q_yo +h*v_y;
theta1 = theta_1o + h*w_1;
theta2 = theta_2o + h*w_2;
theta = theta_o +h*w;


%% intermediate variables for simplifying the equations
alpha = I_z1 + I_z2 + m1*r1^2 +m2*(L1^2 +r2^2);
beta = m2*L1*r2;
delta = I_z2+m2*r2^2;


c1 = cos(theta1);
c2 = cos(theta2);
s1 = sin(theta1);
s2 = sin(theta2);
c12 = cos(theta1 + theta2);
s12 = sin(theta1 + theta2); 
c = cos(theta);
s = sin(theta);


%% intermediate variables (chain rules)


% inertia matrix for 2R 
A11 = alpha+2*beta*c2;
A12 = delta+beta*c2; 
A21 = delta + beta*c2;
A22 = delta;

% centripetal matrix
B11 = -beta*s2*w_2;
B12 = - beta*c2*(w_1 + w_2);
B21 = beta*s2*w_1;

% jacobian matrix for end effector
J11 = -(L1*s1 + L2*s12);
J12 = L1*c1 + L2*c12;
J21 = -L2*s12;
J22 =  L2*c12;
 
a2RB_x = J12;
a2RB_y = - J11;
%jacobian matrix for gravity force
Jg11 = -r1*c1;
Jg12 = L1*c1+r2*c12;
Jg22 = -r2*c12;

tau_g1 = Jg11*g*m1 - Jg12*g*m2;
tau_g2 = Jg22*g*m2;

%contact frame for 2R manuplator and block
gRB_x = (-lRB_1*s);
gRB_y = (lRB_1*c);

gBG_x = c*lBG_2 - c*lBG_4 - lBG_1*s + lBG_3*s;
gBG_y = c*lBG_1 - c*lBG_3 + lBG_2*s - lBG_4*s;

gtRB_x = gRB_y ;
gtRB_y = -gRB_x;

nor = lRB_1;

tRB_x = gtRB_x/nor;
tRB_y = gtRB_y/nor;
nRB_x = gRB_x/nor;
nRB_y = gRB_y/nor;

tauRB_1 = (J11*(nRB_x*pRB_n + pRB_t*tRB_x) + J12*(nRB_y*pRB_n + pRB_t*tRB_y))/h;
tauRB_2 = (J21*(nRB_x*pRB_n + pRB_t*tRB_x) + J22*(nRB_y*pRB_n + pRB_t*tRB_y))/h; 

pBR_x = -(nRB_x*pRB_n + pRB_t*tRB_x);
pBR_y = -(nRB_y*pRB_n + pRB_t*tRB_y);

tauBG = (pBG_n*(a2BG_x - q_x)-pBG_t*(a2BG_y - q_y))/h;
tauBR = (pBR_x*(a2RB_x - q_x)-pBR_y*(a2RB_y - q_y))/h;

vRB_x = J11*w_1 + J21*w_2 - v_x;
vRB_y = J12*w_1 + J22*w_2 -v_y;
vRB_t = tRB_x*vRB_x + tRB_y*vRB_y;
vBG_t = (v_x - w*(a2BG_y - q_y));



%% Dynamic equations
F(1) = A11*(w_1 - w_1o) + A12*(w_2 - w_2o) + B11*h*w_1 + B12*h*w_2 - tauRB_1*h  - tau_g1*h - tau_1*h ;
F(2) = A21*(w_1 - w_1o) + A22*(w_2 - w_2o) + B21*h*w_1 - tauRB_2*h - tau_g2*h - tau_2*h;

F(3) = m*(v_x - v_xo) - p_x - pBG_t - pBR_x;
F(4) = m*(v_y - v_yo) - p_y - pBG_n - pBR_y + m*g*h;
F(5) = I_z*(w - w_o) - p_z - tauBG*h - tauBR*h;

%% Friction model without complementarity equation
F(6) = muRB*pRB_n*vRB_t*eRB_t^2 + pRB_t*sigRB;
F(7) = muBG*pBG_n*vBG_t*eBG_t^2 + pBG_t*sigBG;

%% contact point
F(8) = a1RB_x - a2RB_x + lRB_k*gRB_x;
F(9) = a1RB_y - a2RB_y + lRB_k*gRB_y;

F(10) = a1BG_x - a2BG_x;
F(11) = a1BG_y - a2BG_y + lBG_k;

F(12) =  gBG_x;
F(13) =  gBG_y + 1;

%% Friction model's complementarity equation
F(14) = muRB^2*pRB_n^2 - pRB_t^2/eRB_t^2;
F(15) = muBG^2*pBG_n^2 - pBG_t^2/eBG_t^2;

%% lanrange equations
F(16) = H/2 - c*(a1RB_y - q_y) + s*(a1RB_x - q_x);
F(17) = 0;

F(18) = -a1BG_y;
F(19) = H/2 - c*(a2BG_y - q_y) + s*(a2BG_x - q_x);
F(20) = L/2 - c*(a2BG_x - q_x) - s*(a2BG_y - q_y);
F(21) = H/2 + c*(a2BG_y - q_y) - s*(a2BG_x - q_x);
F(22) = L/2 + c*(a2BG_x - q_x) + s*(a2BG_y - q_y);

%% contact impulse equation
F(23) = -H/2 + c*(a2RB_y - q_y) - s*(a2RB_x - q_x);
F(24) = a2BG_y;


 

if (jacflag)
    %% J1
    J1 = zeros(24,46);
    
    J1(1:2,1:2) = [ A11 + B11*h, A12 + B12*h
                    A21 + B21*h,         A22]; %w_1 w_2
                
    J1(1:2,25:28) = [ w_1 - w_1o, w_2 - w_2o,          0,          0 
                               0,          0, w_1 - w_1o, w_2 - w_2o]; % A11 to A22
    J1(1:2,29:31) = [ h*w_1, h*w_2,     0 
                          0,     0, h*w_1];  % B11 to B21
    J1(1:2,32:35) = [ -h,  0, -h,  0 
                       0, -h,  0, -h]; % tauRB_1 tauRB_2 tau_g1 tau_g2
                   
    J1(3:5,3:5) = [ m, 0,   0 
                    0, m,   0 
                    0, 0, I_z]; 
    J1(3,7) = -1;
    J1(4,24) = -1;
    J1(3:5,36:39) = [ -1,  0,  0,  0
                       0, -1,  0,  0
                       0,  0, -h, -h];
                   
    J1(6:7,6:7) = [ sigRB,     0 
                        0, sigBG];             
    J1(6:7,14:15) = [ pRB_t,     0  
                          0, pBG_t]; 
    J1(6:7,23:24) = [ eRB_t^2*muRB*vRB_t,                  0
                                       0, eBG_t^2*muBG*vBG_t];
    J1(6:7,40:41) = [ eRB_t^2*muRB*pRB_n,                  0
                                       0, eBG_t^2*muBG*pBG_n];
                                   
     J1(8:9,8:9) = [ 1,  0
                     0,  1] ;  
     J1(8:9,16:17) = [ gRB_x, -lRB_k*s
                       gRB_y,  c*lRB_k];
     J1(8:9,42:43) = [-1, 0
                      0, -1]; 
     J1(8:9,46) = [ -gRB_y*lRB_k
                     gRB_x*lRB_k];
                 
     J1(10:11,10:13) = [ 1, 0, -1,  0
                        0, 1,  0, -1];
    J1(11,18) = 1;
    
    J1(12:13,19:22) = [ -s, c,  s, -c
                         c, s, -c, -s];
    J1(12:13,46) = [-gBG_y
                     gBG_x];
    J1(14:15,6:7) = [ -(2*pRB_t)/eRB_t^2,                  0
                                       0, -(2*pBG_t)/eBG_t^2];
    J1(14:15,23:24) = [ 2*muRB^2*pRB_n,              0
                                     0, 2*muBG^2*pBG_n];
    J1(16,[8,9,44,45,46]) = [ s, -c, -s, c, c*(a1RB_x - q_x) + s*(a1RB_y - q_y)];
    
    J1(18,11) = -1;
    

    J1(19:22,12:13) =   [s, -c
                        -c, -s
                        -s,  c
                         c,  s];
                        
    J1(19:22,44:46) =  [ -s,  c,   c*(a2BG_x - q_x) + s*(a2BG_y - q_y)
                         c,  s,   s*(a2BG_x - q_x) - c*(a2BG_y - q_y)
                         s, -c, - c*(a2BG_x - q_x) - s*(a2BG_y - q_y)
                        -c, -s,   c*(a2BG_y - q_y) - s*(a2BG_x - q_x)];
                    
    J1(23,42:46) = [ -s, c, s, -c, - c*(a2RB_x - q_x) - s*(a2RB_y - q_y)];
    J1(24,13) = 1;
    
    %% J2  
    J2 = zeros(46,36);
    J2(1:24,1:24) = eye(24);
    J2(25:27,26) = [-2*beta*s2
                      -beta*s2
                      -beta*s2];
    J2(28:30,1:2) = [        0,        0
                             0, -beta*s2
                      -beta*c2, -beta*c2];
    J2(28:30,26) = [ 0;-beta*c2*w_2;beta*s2*(w_1 + w_2)];
    J2(31:32,[1,6,23,26]) = [ beta*s2,                 0,                 0, beta*c2*w_1
                                    0, (J11*c + J12*s)/h, (J12*c - J11*s)/h,           0];
    J2(32,29:31) = [ -(J11*(c*pRB_n + pRB_t*s) - J12*(c*pRB_t - pRB_n*s))/h, (c*pRB_t - pRB_n*s)/h, (c*pRB_n + pRB_t*s)/h];
    J2(33,[6,23,29,32,33]) = [ (J21*c + J22*s)/h, (J22*c - J21*s)/h, -(J21*(c*pRB_n + pRB_t*s) - J22*(c*pRB_t - pRB_n*s))/h, (c*pRB_t - pRB_n*s)/h, (c*pRB_n + pRB_t*s)/h];
    J2(34:35,34:36) = [ g*m1, -g*m2,    0
                            0,     0, g*m2];
    J2(36:37,[6,23,29]) = [ -c,  s, c*pRB_n + pRB_t*s
                            -s, -c, pRB_n*s - c*pRB_t];
    J2(38:39,[7:11,24,27,28]) = [ -(a1BG_y - q_y)/h,       0,        0, pBG_n/h, -pBG_t/h, (a1BG_x - q_x)/h, -pBG_n/h, pBG_t/h
                                                  0, pBR_x/h, -pBR_y/h,       0,        0,                0, -pBR_x/h, pBR_y/h];
    J2(40,[1:4,29:33]) = [ J11*c + J12*s, J21*c + J22*s, -c, -s, c*vRB_y - s*vRB_x, c*w_1, s*w_1, c*w_2, s*w_2];
    J2(41,[3,5,13,28]) = [ 1, q_y - a2BG_y, -w, w];
    J2(42:43,[30,31]) = [0,1;-1,0];
    J2(44:46,27:29) = eye(3);
    
    %% J3
    J3 = zeros(36,29);
    J3(1:29,1:29) = eye(29);
    J3(30:36,25:26) = [ - L1*c1 - L2*c12, -L2*c12
                        - L1*s1 - L2*s12, -L2*s12
                                 -L2*c12, -L2*c12
                                 -L2*s12, -L2*s12
                                   r1*s1,       0
                        - L1*s1 - r2*s12, -r2*s12
                                  r2*s12,  r2*s12];
     %% J4
     J4 = zeros(29,24);
     J4(1:24,1:24) = eye(24);
     J4(25:29,1:5) = h*eye(5);
     J = J1*J2*J3*J4;
     J = sparse(J);
end








end