% This returns the A,b matrices where sum(Ai,i)*x=sum(bi,i), so if these
% are input for each pixel 
function [A,b]=fp_make_Ab_matrices(x,fx,fy,ft)
% Original form
X=[1 x(1) x(2) 0 0 0; 0 0 0 1 x(1) x(2)];
DelI=[fx;fy];
A=X'*DelI*DelI'*X;
b=-X'*DelI*ft;

% Condensed form
A= [fx^2,    x*fx^2,    y*fx^2,       fx*fy,   x*fx*fy,   y*fx*fy;
    x*fx^2,  x^2*fx^2,  x*fx^2*y,     x*fx*fy, x^2*fx*fy, x*fx*fy*y;
    y*fx^2,  x*fx^2*y,  y^2*fx^2,     y*fx*fy, x*fx*fy*y, y^2*fx*fy;
    fx*fy,   x*fx*fy,   y*fx*fy,      fy^2,    x*fy^2,    y*fy^2;
    x*fx*fy, x^2*fx*fy, x*fx*fy*y,    x*fy^2,  x^2*fy^2,  x*fy^2*y;
    y*fx*fy, x*fx*fy*y, y^2*fx*fy,    y*fy^2,  x*fy^2*y,  y^2*fy^2];
b=[-ft*fx;
   -ft*x*fx;
   -ft*y*fx;
   -ft*fy;
   -ft*x*fy;
   -ft*y*fy];

% Reduced form, neg means '-', _sqr means immediately previous term squared, ?_t_? means "? * ?"

% These are required by the A/b matrix computations - 1st Tier of
% multiplications
neg_ft=-ft;
fx_sqr=fx^2;
fy_sqr=fy^2;
x_sqr=x^2;
y_sqr=y^2;
fx_t_fy=fx*fy;
x_t_fx=x*fx;
y_t_fy=y*fy;
x_t_y=x*y;

% These use the previous multiplications - 2nd Tier of multiplications
x_t_fx_sqr=x*fx_sqr;
y_t_fy_sqr=y*fy_sqr;

% 3rd Tier
y_t_fx_sqr=y*fx_sqr;
x_t_fy_sqr=x*fy_sqr;
y_t_fx_t_fy=y*fx_t_fy;
x_t_fx_t_fy=x*fx_t_fy;
% Condensed form
A= [fx_sqr,      x_t_fx_sqr,      y_t_fx_sqr,       fx_t_fy,     x_t_fx_t_fy,     y_t_fx_t_fy;
    x_t_fx_sqr,  x_sqr*fx_sqr,    x_t_y*fx_sqr,   x_t_fx_t_fy,   x_sqr*fx_t_fy, x_t_fx*y_t_fy;
    y_t_fx_sqr,    x_t_y*fx_sqr,    y_sqr*fx_sqr,   y_t_fx_t_fy,   x_t_fx*y_t_fy, y_sqr*fx_t_fy;
    fx_t_fy,     x_t_fx_t_fy,       y_t_fx_t_fy,      fy_sqr,      x_t_fy_sqr,      y_t_fy_sqr;
    x_t_fx_t_fy,   x_sqr*fx_t_fy,   x_t_fx*y_t_fy,  x_t_fy_sqr,    x_sqr*fy_sqr,  x_t_fy_sqr*y;
    y_t_fx_t_fy,   x_t_fx*y_t_fy,   y_sqr*fx_t_fy,  y_t_fy_sqr,  x_t_y*fy_sqr,  y_sqr*fy_sqr];
b=[neg_ft*fx;
   neg_ft*x_t_fx;
   neg_ft*y*fx;
   neg_ft*fy;
   neg_ft*x*fy;
   neg_ft*y_t_fy];


%% Reduced 2
% Condensed form - 31 mult pipelined, 21 mult if done in 2 passes
% Tier 1 - 10 Mul
fx_sqr=fx*fx;
fx_t_fy=fx*fy;
fy_sqr=fy*fy;
x_sqr=x*x;
y_sqr=y*y;
x_t_y=x*y;
x_t_fx=x*fx;
y_t_fx=y*fx;
x_t_fy=x*fy;
y_t_fy=y*fy;


% Tier 2 - 21 Mul
x_t_fx_sqr=x*fx_sqr;
y_t_fy_sqr=y*fy_sqr;
x_t_fx_t_fy=x*fx_t_fy;
y_t_fx_t_fy=y*fx_t_fy;
y_t_fx_sqr=y*fx_sqr;
x_t_fy_sqr=x*fy_sqr;
x_sqr_t_fx_sqr=x_sqr*fx_sqr;
x_t_y_t_fx_sqr=x_t_y*fx_sqr;
y_sqr_t_fx_sqr=y_sqr*fx_sqr;
x_sqr_t_fx_t_fy=x_sqr*fx_t_fy;
x_t_y_t_fx_t_fy=x_t_y*fx_t_fy;
x_t_y_t_fy_sqr=x_t_y*fy_sqr;
y_sqr_t_fx_t_fy=y_sqr*fx_t_fy;
y_sqr_t_fy_sqr=y_sqr*fy_sqr;
x_sqr_t_fy_sqr=x_sqr*fy_sqr;

neg_ft_t_fx=-ft*fx;
neg_ft_t_fy=-ft*fy;
neg_ft_x_t_fx=-ft*x_t_fx;
neg_ft_t_y_t_fx=-ft*y_t_fx;
neg_ft_t_x_t_fy=-ft*x_t_fy;
neg_ft_t_y_t_fy=-ft*y_t_fy;

A=[fx_sqr,      x_t_fx_sqr,      y_t_fx_sqr,       fx_t_fy,     x_t_fx_t_fy,     y_t_fx_t_fy;
   x_t_fx_sqr,  x_sqr_t_fx_sqr,  x_t_y_t_fx_sqr,   x_t_fx_t_fy, x_sqr_t_fx_t_fy, x_t_y_t_fx_t_fy;
   y_t_fx_sqr,  x_t_y_t_fx_sqr,  y_sqr_t_fx_sqr,   y_t_fx_t_fy, x_t_y_t_fx_t_fy, y_sqr_t_fx_t_fy;
   fx_t_fy,     x_t_fx_t_fy,     y_t_fx_t_fy,      fy_sqr,      x_t_fy_sqr,      y_t_fy_sqr;
   x_t_fx_t_fy, x_sqr_t_fx_t_fy, x_t_y_t_fx_t_fy,  x_t_fy_sqr,  x_sqr_t_fy_sqr,  x_t_y_t_fy_sqr;
   y_t_fx_t_fy, x_t_y_t_fx_t_fy, y_sqr_t_fx_t_fy,  y_t_fy_sqr,  x_t_y_t_fy_sqr,  y_sqr_t_fy_sqr];
b=[neg_ft_t_fx;
   neg_ft_x_t_fx;
   neg_ft_t_y_t_fx;
   neg_ft_t_fy;
   neg_ft_t_x_t_fy;
   neg_ft_t_y_t_fy];