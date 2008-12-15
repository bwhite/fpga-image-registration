% This returns the A,b matrices where sum(Ai,i)*x=sum(bi,i), so if these
% are input for each pixel 
function [tA,tb]=fp_make_Ab_matrix(x,y,fx,fy,ft,sx)
img_word=10;
img_whole=0;
coord_word=12;
coord_whole=2;

% Normalize the coordinates by the nearest power of 2
x=nc(x*2^(-sx));
y=nc(y*2^(-sx));

fx=fi(fx,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
fy=fi(fy,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
ft=fi(ft,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
x=fi(x,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
y=fi(y,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
% Throw errors if anything is abs(x)>=1
absnormal(x);
absnormal(y);
absnormal(fx);
absnormal(fy);
absnormal(ft);

% Make coefficients, never perform more than a 32x32 multiply
% Pass 1
fx2=nc(fx.*fx);
fxft=nc(fx.*ft);
fxfy=nc(fx.*fy);
fy2=nc(fy.*fy);
fyft=nc(fy.*ft);
x2=nc(x.*x);
y2=nc(y.*y);
xy=nc(x.*y);

% Pass 2
fx2_t_x=nc(fx2.*x);
fx2_t_y=nc(fx2.*y);
fx2_t_x2=nc(fx2.*x2);
fx2_t_y2=nc(fx2.*y2);
fx2_t_xy=nc(fx2.*xy);

fy2_t_x=nc(fy2.*x);
fy2_t_y=nc(fy2.*y);
fy2_t_x2=nc(fy2.*x2);
fy2_t_y2=nc(fy2.*y2);
fy2_t_xy=nc(fy2.*xy);

fxfy_t_x=nc(fxfy.*x);
fxfy_t_y=nc(fxfy.*y);
fxfy_t_x2=nc(fxfy.*x2);
fxfy_t_y2=nc(fxfy.*y2);
fxfy_t_xy=nc(fxfy.*xy);

fxft_t_x=nc(fxft.*x);
fyft_t_x=nc(fyft.*x);
fxft_t_y=nc(fxft.*y);
fyft_t_y=nc(fyft.*y);

% Overall FP format for each A matrix 1:11:20 (the summation will have to be larger)

tA=[sc(fx2,sx), nc(fx2_t_x), nc(fx2_t_y), sc(fxfy,sx), nc(fxfy_t_x), nc(fxfy_t_y);
    sc(fx2_t_x,sx), nc(fx2_t_x2), nc(fx2_t_xy), sc(fxfy_t_x,sx), nc(fxfy_t_x2), nc(fxfy_t_xy);
    sc(fx2_t_y,sx), nc(fx2_t_xy), nc(fx2_t_y2), sc(fxfy_t_y,sx), nc(fxfy_t_xy), nc(fxfy_t_y2);
    sc(fxfy,sx), nc(fxfy_t_x), nc(fxfy_t_y), sc(fy2,sx), nc(fy2_t_x), nc(fy2_t_y);
    sc(fxfy_t_x,sx), nc(fxfy_t_x2), nc(fxfy_t_xy), sc(fy2_t_x,sx), nc(fy2_t_x2), nc(fy2_t_xy);
    sc(fxfy_t_y,sx), nc(fxfy_t_xy), nc(fxfy_t_y2), sc(fy2_t_y,sx), nc(fy2_t_xy), nc(fy2_t_y2)];
tb=[sc(fxft,sx);
    sc(fxft_t_x,sx);
    sc(fxft_t_y,sx);
    sc(fyft,sx);
    sc(fyft_t_x,sx);
    sc(fyft_t_y,sx)];

function val=sc(x,sx)
% Overall FP format for each A matrix 1:11:20 (the summation will have to
% be larger)
coord_word=24;
coord_whole=0;
val=fi(bitsra(x,sx),1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round','SumMode','KeepLSB');

function val=nc(x)
% Overall FP format for each A matrix 1:11:20 (the summation will have to
% be larger)
coord_word=24;
coord_whole=0;
val=fi(x,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round','SumMode','KeepLSB');

function absnormal(x)
assert(sum(abs(x)>= 1)==0)