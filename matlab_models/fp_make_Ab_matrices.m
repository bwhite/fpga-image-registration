% This returns the A,b matrices where sum(Ai,i)*x=sum(bi,i), so if these
% are input for each pixel 
function [A,b]=fp_make_Ab_matrices(x,y,fx,fy,ft,sx)
A=ns(zeros(6));
b=ns(zeros(6,1));

% Overall FP format for each A matrix 1:11:20 (the summation will have to
% be larger)
lx=length(x);
for i=1:lx
    disp(sprintf('%d/%d',i,lx))
    [tA,tb]=fp_make_Ab_matrix(x(i),y(i),fx(i),fy(i),ft(i),sx);
    A=ns(A)+ns(tA);
    b=ns(b)+ns(tb);
end
b=-b;

function val=ns(x)
% Overall FP format for each A matrix 1:11:20 (the summation will have to
% be larger)
coord_word=38;
coord_whole=6;
val=fi(x,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round','SumMode','KeepLSB','SumWordLength',38);

function absnormal(x)
assert(sum(abs(x)>= 1)==0)