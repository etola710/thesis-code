c_ = sparse(11,1);
c_(1) = -1;
b_ = sparse(8,1);
b_(2:2) = a;
b_(4:4) = b;
A_ = sparse(8, 11);
A_(1:1, 9:9) = 1.0; A_(1:1, 2:2) = 1.0; A_(1:1, 10:10) = -1.0;
A_(2:2, 9:9) = 1.0;
A_(3:3, 10:10) = 1.0; A_(3:3, 3:3) = 1.0; A_(3:3, 11:11) = -1.0;
A_(4:4, 11:11) = 1.0;
A_(5:5, 8:8) = 1.0; A_(5:5, 4:4) = 1.0; A_(5:5, 10:10) = -1.0;
A_(6:6, 10:10) = 1.0; A_(6:6, 7:7) = 1.0; A_(6:6, 1:1) = -1.0;
A_(7:7, 10:10) = 0.5; A_(7:7, 8:8) = 0.5; A_(7:7, 5:5) = -1.0;
A_(8:8, 10:10) = -0.5; A_(8:8, 8:8) = 0.5; A_(8:8, 6:6) = -1.0;
G_ = sparse(7, 11);
G_(1:1:1, 2:2) = -speye(1, 1);
G_(2:1:2, 3:3) = -speye(1, 1);
G_(3:1:3, 4:4) = -speye(1, 1);
G_(4:1:4, 8:8) = -speye(1, 1);
G_(5:1:5, 5:5) = -speye(1, 1);
G_(6:1:6, 6:6) = -speye(1, 1);
G_(7:1:7, 7:7) = -speye(1, 1);
h_ = zeros(7, 1);
dims.q = [3];
dims.l = 4;
[x_codegen, y_, info_] = conelp(full(c_), G_, h_, dims, A_, full(b_));
t0 = x_codegen(1:1);
t2 = x_codegen(2:2);
t3 = x_codegen(3:3);
t4 = x_codegen(4:4);
t1z0 = x_codegen(5:5);
t1z1 = x_codegen(6:6);
t1 = x_codegen(7:7);
x2 = x_codegen(8:8);
pa = x_codegen(9:9);
x1 = x_codegen(10:10);
pb = x_codegen(11:11);
ecos_optval = -1*info_.pcost;
