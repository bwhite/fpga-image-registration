% FPGA Version
function x=gauss_elim_fixed(A,b)
input_frac=19;
input_whole=7;
div_frac=input_frac;
div_whole=input_whole;

A=fp(A,input_whole,input_frac);
b=fp(b,input_whole,input_frac);
if ~exist('aug') || isempty(aug)
    aug=[A b];
end
N=size(aug,1);x=fp(zeros(N,1),div_whole,div_frac);
% Forward Pass
for i=1:(N-1) % Pivot iter
    pivot_row0=zeros(1,size(aug,2));
    for col_iter=1:size(aug,2)
        % TODO Force to 1 when necessary
        pivot_row0(col_iter)=fp_gauss_elim_divider(aug(i,col_iter),aug(i,i));
    end
    for j=(i+1):N
        pivot_row1=fp(aug(j,i)*pivot_row0,input_whole,input_frac);
        aug(j,:)=fp(pivot_row1-aug(j,:),input_whole,input_frac);
        % Zero the row up until i to remove numerical innacuracy
        %aug(j,1:i)=0;
    end
end

% Back Substitution
for i=N:-1:1
    % Multiply the current A row by the current values for X
    % The current X value will be zero in the X vector
    % Can be skipped for the first run
    if i~=N
        row_mult=fp(aug(i,2:N).*x(2:N)',input_whole,input_frac); % Element 1 is always zero
        row_mult_sum=fp(sum(row_mult),input_whole,input_frac);
        diff_ab=fp(aug(i,N+1)-row_mult_sum,input_whole,input_frac);
    else
        diff_ab=aug(i,N+1);
    end
    x(i)=fp_gauss_elim_divider(diff_ab,aug(i,i));
end

function out=fp(val,whole,frac)
out=fi(val,1,1+whole+frac,frac,'MaxProductWordLength',(1+whole+frac)*2,'MaxSumWordLength',(1+whole+frac)+3,'RoundMode','Floor');

function out=fpt(whole,frac)
out=numerictype('Signed',true,'WordLength',whole+frac+1,'FractionLength',frac);