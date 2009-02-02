% This returns the A,b matrices where sum(Ai,i)*x=sum(bi,i), so if these
% are input for each pixel 
function [tA,tb]=fp_make_Ab_matrix(x,y,fx,fy,ft,sx,verbose)
if ~exist('verbose')
    verbose=0;
end
coord_word=12;
coord_whole=10;
img_word=10;
img_whole=0;


fx=fi(fx,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
fy=fi(fy,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
ft=fi(ft,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
x=fi(x,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
y=fi(y,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
sc_fi=fi(sx,0,4,0);
if verbose
    disp(sprintf('TI:{16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,16#%s#,1,0}',hex(sc_fi),hex(x),hex(y),hex(fx),hex(fy),hex(ft)))
end

new_coord_word=27+coord_word;
new_coord_whole=coord_whole;
x=fi(x,1,new_coord_word,new_coord_word-new_coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
y=fi(y,1,new_coord_word,new_coord_word-new_coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');


% Normalize the coordinates by the nearest power of 2
x=sc(x,sx);
y=sc(y,sx);

% Throw errors if anything is abs(x)>=1
absnormal(x);
absnormal(y);
absnormal(fx);
absnormal(fy);
absnormal(ft);

% Make coefficients, never perform more than a 32x32 multiply
% Pass 1
fx2=fp_signed_norm_mult(fx,fx);
fxft=fp_signed_norm_mult(fx,ft);
fxfy=fp_signed_norm_mult(fx,fy);
fy2=fp_signed_norm_mult(fy,fy);
fyft=fp_signed_norm_mult(fy,ft);
x2=fp_signed_norm_mult(x,x);
y2=fp_signed_norm_mult(y,y);
xy=fp_signed_norm_mult(x,y);

% Pass 2
fx2_t_x=fp_signed_norm_mult(fx2,x);
fx2_t_y=fp_signed_norm_mult(fx2,y);
fx2_t_x2=fp_signed_norm_mult(fx2,x2);
fx2_t_y2=fp_signed_norm_mult(fx2,y2);
fx2_t_xy=fp_signed_norm_mult(fx2,xy);

fy2_t_x=fp_signed_norm_mult(fy2,x);
fy2_t_y=fp_signed_norm_mult(fy2,y);
fy2_t_x2=fp_signed_norm_mult(fy2,x2);
fy2_t_y2=fp_signed_norm_mult(fy2,y2);
fy2_t_xy=fp_signed_norm_mult(fy2,xy);

fxfy_t_x=fp_signed_norm_mult(fxfy,x);
fxfy_t_y=fp_signed_norm_mult(fxfy,y);
fxfy_t_x2=fp_signed_norm_mult(fxfy,x2);
fxfy_t_y2=fp_signed_norm_mult(fxfy,y2);
fxfy_t_xy=fp_signed_norm_mult(fxfy,xy);

fxft_t_x=fp_signed_norm_mult(fxft,x);
fyft_t_x=fp_signed_norm_mult(fyft,x);
fxft_t_y=fp_signed_norm_mult(fxft,y);
fyft_t_y=fp_signed_norm_mult(fyft,y);

% Overall FP format for each A matrix 1:11:20 (the summation will have to be larger)

tA=[sc(fx2,sx), fx2_t_x, fx2_t_y, sc(fxfy,sx), fxfy_t_x, fxfy_t_y;
    sc(fx2_t_x,sx), fx2_t_x2, fx2_t_xy, sc(fxfy_t_x,sx), fxfy_t_x2, fxfy_t_xy;
    sc(fx2_t_y,sx), fx2_t_xy, fx2_t_y2, sc(fxfy_t_y,sx), fxfy_t_xy, fxfy_t_y2;
    sc(fxfy,sx), fxfy_t_x, fxfy_t_y, sc(fy2,sx), fy2_t_x, fy2_t_y;
    sc(fxfy_t_x,sx), fxfy_t_x2, fxfy_t_xy, sc(fy2_t_x,sx), fy2_t_x2, fy2_t_xy;
    sc(fxfy_t_y,sx), fxfy_t_xy, fxfy_t_y2, sc(fy2_t_y,sx), fy2_t_xy, fy2_t_y2];
tb=[sc(fxft,sx);
    sc(fxft_t_x,sx);
    sc(fxft_t_y,sx);
    sc(fyft,sx);
    sc(fyft_t_x,sx);
    sc(fyft_t_y,sx)];

if verbose
    outstr=sprintf('TO:{1,0');
    ap=tA';
    for i=1:36
        outstr=strcat(outstr,sprintf(',16#%s#',hex(ap(i))));
    end
    disp(strcat(outstr,'}'))
end

function val=sc(x,sx)
val=bitsra(x,sx);

function absnormal(x)
assert(sum(abs(x)>= 1)==0)