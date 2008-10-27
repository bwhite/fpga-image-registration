syms fx fy x y ft a real

A= [fx^2,    x*a*fx^2,    y*fx^2,       fx*fy,   x*a*fx*fy,   y*a*fx*fy;
     x*a*fx^2,  (x*a)^2*fx^2,  x*a*fx^2*y*a,     x*a*fx*fy, (x*a)^2*fx*fy, x*a*fx*fy*y*a;
     y*a*fx^2,  x*a*fx^2*y,  (y*a)^2*fx^2,     y*a*fx*fy, x*a*fx*fy*y*a, (y*a)^2*fx*fy;
     fx*fy,   x*a*fx*fy,   y*a*fx*fy,      fy^2,    x*a*fy^2,    y*a*fy^2;
     x*a*fx*fy, (x*a)^2*fx*fy, x*a*fx*fy*y*a,    x*a*fy^2,  (x*a)^2*fy^2,  x*a*fy^2*y*a;
     y*a*fx*fy, x*a*fx*fy*y, (y*a)^2*fx*fy,    y*a*fy^2,  x*a*fy^2*y*a,  (y*a)^2*fy^2];
 b=[-ft*fx;
    -ft*x*a*fx;
    -ft*y*a*fx;
    -ft*fy;
    -ft*x*a*fy;
    -ft*y*a*fy];