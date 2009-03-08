% This returns the A,b matrices where sum(Ai,i)*x=sum(bi,i), so if these
% are input for each pixel 
function [A,b]=fp_make_Ab_matrices(x,y,fx,fy,ft,sx)
A=ns(zeros(6));
b=ns(zeros(6,1));

% Overall FP format for each A matrix 1:11:20 (the summation will have to
% be larger)
lx=length(x);
target=700;
for i=1:lx
    disp(sprintf('%d/%d',i,lx))
    [tA,tb]=fp_make_Ab_matrix(x(i),y(i),fx(i),fy(i),ft(i),sx);
    A=ns(A)+ns(tA);
    b=ns(b)-ns(tb);
    if mod(i,300) == 0
        disp(bin(A))
        disp(bin(b))
    end
%     if i>=target-10
%         disp(bin(A))
%         disp(bin(b))
%         disp(sprintf('i=%d',i))
%     end
%    if i>=target+10
%         disp(bin(A))
%         disp(bin(b))
%         disp(sprintf('i=%d',i))
%     end
end
%b=-b;
disp(bin(A))
disp(bin(b))
save make_absumtest_fixed
disp(1)

function val=ns(x)
% Overall FP format for each A matrix 1:11:20 (the summation will have to
% be larger)
coord_word=47;%38;
coord_whole=15;%6;
val=fi(x,1,coord_word,coord_word-coord_whole-1,'MaxProductWordLength',1024,'MaxSumWordLength',1024,'RoundMode','Round','SumMode','KeepLSB','SumWordLength',coord_word);

function absnormal(x)
assert(sum(abs(x)>= 1)==0)