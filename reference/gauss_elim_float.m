% Pre FPGA Version
function [x]=gauss_elim_float(A,b)
aug=[A b];N=size(aug,1);x=zeros(N,1);
% Forward Pass
for i=1:(N-1) % Pivot iter
    inv_pivot=1/aug(i,i);
    pivot_row0=inv_pivot*aug(i,:);
    for j=(i+1):N
        pivot_row1=aug(j,i)*pivot_row0;
        aug(j,:)=pivot_row1-aug(j,:);
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
        row_mult=aug(i,2:N).*x(2:N)'; % Element 1 is always zero
        row_mult_sum=sum(row_mult);
        diff_ab=aug(i,N+1)-row_mult_sum;
    else
        diff_ab=aug(i,N+1);
    end
    x(i)=diff_ab/aug(i,i);
end