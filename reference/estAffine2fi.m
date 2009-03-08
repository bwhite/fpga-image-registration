function M = estAffine2fi()
im1=make_test_img(0);
im2=make_test_img(1);

width = 640;
sx = 10;%ceil(log2(width/2)); % == 9

x_bar=[320,240];

T=[1 0 -x_bar(1);0 1 -x_bar(2); 0 0 1];

% im1 and im2 are images
% M is 3x3 affine transform matrix: IM2COORD = M * IM1COORD
[fx,fy,ft]=fp_derivative_computation_3x3_test(im1,im2);
%[fx,fy,ft]=computeDerivatives2bra(im1,im2);

% Create a mesh for the x and y values
% This looks wrong
[xgrid,ygrid]=meshgrid(2:(size(im1,2)-3),2:(size(im1,1)-3));

% Transform coordinates to scaled form
xgrid=xgrid';
ygrid=ygrid';
fx=fx';
fy=fy';
ft=ft';
x=[xgrid(:)';ygrid(:)';ones([1,length(xgrid(:))])];
x_wave=T*x;
xgrid=x_wave(1,:)';
ygrid=x_wave(2,:)';

[A,b]=fp_make_Ab_matrices(xgrid,ygrid,fx,fy,ft,sx);

% Solve overconstrained least squares solution
p = A\b;

% Make homography
M=[p(2) p(3) p(1);p(5) p(6) p(4); 0 0 1];
temp_eye=eye(3);
temp_eye(9)=0;
M=M+temp_eye;

% Transform homography from scaled form
M=inv(T)*M*T;