% Takes in a homography with the last row as 0 0 1, and finds x_prime
% (where x_prime=H*x) in fixed point math
function x_prime=fp_affine_homography(A,t,x)
% 4 Mult
x_prime=[A(1,1)*x(1)+A(1,2)*x(2)+t(1),A(2,1)*x(1)+A(2,2)*x(2)+t(2)];