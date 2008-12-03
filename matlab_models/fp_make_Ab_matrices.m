% This returns the A,b matrices where sum(Ai,i)*x=sum(bi,i), so if these
% are input for each pixel 
function [A,b]=fp_make_Ab_matrices(x,y,fx,fy,ft,sx)
img_word=10;
img_whole=0;
coord_word=12;
coord_whole=10;
fixed=1;
if fixed==1
    fx=fi(fx,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
    fy=fi(fy,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
    ft=fi(ft,1,img_word,img_word-img_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
    x=fi(x,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
    y=fi(y,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round');
end
% Pass 1
fx2=fx.*fx;
fxft=fx.*ft;
fxfy=fx.*fy;
fy2=fy.*fy;
fyft=fy.*ft;
x2=x.*x;
y2=y.*y;
xy=x.*y;

% Pass 2
fx2_t_x=fx2.*x;
fx2_t_y=fx2.*y;
fx2_t_x2=fx2.*x2;
fx2_t_y2=fx2.*y2;
fx2_t_xy=fx2.*xy;

fy2_t_x=fy2.*x;
fy2_t_y=fy2.*y;
fy2_t_x2=fy2.*x2;
fy2_t_y2=fy2.*y2;
fy2_t_xy=fy2.*xy;

fxfy_t_x=fxfy.*x;
fxfy_t_y=fxfy.*y;
fxfy_t_x2=fxfy.*x2;
fxfy_t_y2=fxfy.*y2;
fxfy_t_xy=fxfy.*xy;

fxft_t_x=fxft.*x;
fyft_t_x=fyft.*x;
fxft_t_y=fxft.*y;
fyft_t_y=fyft.*y;
if fixed==1
   A=ns(zeros(6));
   b=ns(zeros(6,1));
else
   A=zeros(6);
   b=zeros(6,1);
end
% Overall FP format for each A matrix 1:11:20 (the summation will have to be larger)
maxa=0;
for i=1:length(fx2)
    if fixed==1 
        tA=[nc(fx2(i)), nc(fx2_t_x(i)), nc(fx2_t_y(i)), nc(fxfy(i)), nc(fxfy_t_x(i)), nc(fxfy_t_y(i));
            sc(fx2_t_x(i),sx), sc(fx2_t_x2(i),sx), sc(fx2_t_xy(i),sx), sc(fxfy_t_x(i),sx), sc(fxfy_t_x2(i),sx), sc(fxfy_t_xy(i),sx);
            sc(fx2_t_y(i),sx), sc(fx2_t_xy(i),sx), sc(fx2_t_y2(i),sx), sc(fxfy_t_y(i),sx), sc(fxfy_t_xy(i),sx), sc(fxfy_t_y2(i),sx);
            nc(fxfy(i)), nc(fxfy_t_x(i)), nc(fxfy_t_y(i)), nc(fy2(i)), nc(fy2_t_x(i)), nc(fy2_t_y(i));
            sc(fxfy_t_x(i),sx), sc(fxfy_t_x2(i),sx), sc(fxfy_t_xy(i),sx), sc(fy2_t_x(i),sx), sc(fy2_t_x2(i),sx), sc(fy2_t_xy(i),sx);
            sc(fxfy_t_y(i),sx), sc(fxfy_t_xy(i),sx), sc(fxfy_t_y2(i),sx), sc(fy2_t_y(i),sx), sc(fy2_t_xy(i),sx), sc(fy2_t_y2(i),sx)];
        tb=[nc(fxft(i));
            sc(fxft_t_x(i),sx);
            sc(fxft_t_y(i),sx);
            nc(fyft(i));
            sc(fyft_t_x(i),sx);
            sc(fyft_t_y(i),sx)];
        A=ns(A)+ns(tA);
        b=ns(b)+ns(tb);
    else
        tA=[fx2(i), fx2_t_x(i), fx2_t_y(i), fxfy(i), fxfy_t_x(i), fxfy_t_y(i);
            fx2_t_x(i), fx2_t_x2(i), fx2_t_xy(i), fxfy_t_x(i), fxfy_t_x2(i), fxfy_t_xy(i);
            fx2_t_y(i), fx2_t_xy(i), fx2_t_y2(i), fxfy_t_y(i), fxfy_t_xy(i), fxfy_t_y2(i);
            fxfy(i), fxfy_t_x(i), fxfy_t_y(i), fy2(i), fy2_t_x(i), fy2_t_y(i);
            fxfy_t_x(i), fxfy_t_x2(i), fxfy_t_xy(i), fy2_t_x(i), fy2_t_x2(i), fy2_t_xy(i);
            fxfy_t_y(i), fxfy_t_xy(i), fxfy_t_y2(i), fy2_t_y(i), fy2_t_xy(i), fy2_t_y2(i)];
        tb=[fxft(i);
            fxft_t_x(i);
            fxft_t_y(i);
            fyft(i);
            fyft_t_x(i);
            fyft_t_y(i)];
        A=A+tA;
        b=b+tb;
    end
   if fixed==0
       maxa=max(abs([maxa;tA(:);tb(:)]));
   end
end
if fixed==1
    b=double(-b);
    A=double(A);
else
    disp(sprintf('MAXta:%f',maxa))
    disp(sprintf('MAXA:%f',max([A(:);b(:)])))
    b=-b;
end

function val=sc(x,sx)
% Overall FP format for each A matrix 1:11:20 (the summation will have to
% be larger)
coord_word=32;
coord_whole=11;
val=fi(bitsra(x,sx),1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round','SumMode','KeepLSB');

function val=nc(x)
% Overall FP format for each A matrix 1:11:20 (the summation will have to
% be larger)
coord_word=32;
coord_whole=11;
val=fi(x,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round','SumMode','KeepLSB');

function val=ns(x)
% Overall FP format for each A matrix 1:11:20 (the summation will have to
% be larger)
coord_word=48;
coord_whole=27;
val=fi(x,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round','SumMode','KeepLSB','SumWordLength',48);
