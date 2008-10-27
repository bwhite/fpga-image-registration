function M = estAffine2(im1,im2,T,sx,sy,method)
% im1 and im2 are images
% M is 3x3 affine transform matrix: IM2COORD = M * IM1COORD
% where X=(x,y,1) is starting position in homogeneous coords
% and X'=(x',y',1) is ending position
%
% Solves fs^t theta + ft = 0
% where theta = B p is image velocity at each pixel
%       B is 2x6 matrix that depends on image positions
%       p is vector of affine motion parameters
%       fs is vector of spatial derivatives at each pixel
%       ft is temporal derivative at each pixel
% Mulitplying fs^t B gives a 1x6 vector for each pixel.  Piling
% these on top of one another gives A, an Nx6 matrix, where N is
% the number of pixels.  Solve M p = ft where ft is now an Nx1
% vector of the the temporal derivatives at every pixel.

% Compute the derivatives of the image
if method==0
	[fx,fy,ft]=computeDerivatives2bra(im1,im2);
else
	[fx,fy,ft]=fp_derivative_computation_3x3_test(im1,im2);
end

% Create a mesh for the x and y values
[xgrid,ygrid]=meshgrid(1:size(fx,2),1:size(fx,1));
pts=find(~isnan(fx));
ptsy=find(~isnan(fy));
ptst=find(~isnan(ft));
pts=intersect(ptst,intersect(pts,ptsy));


fx = fx(pts);
fy = fy(pts);
ft = ft(pts);
sfx=2^5;
sfy=2^5;
xgrid = xgrid(pts);
ygrid = ygrid(pts);

% Transform coordinates to scaled form
x=[xgrid';ygrid';ones([1,length(xgrid)])];
x_wave=T*x;
xgrid=x_wave(1,:)';
ygrid=x_wave(2,:)';
A=0;
b=0;

if method==0
    for i=1:length(xgrid)
        X=[1 xgrid(i) ygrid(i) 0 0 0; 0 0 0 1 xgrid(i) ygrid(i)];
        DelI=[fx(i);fy(i)];
        A=A+X'*DelI*DelI'*X;
        b=b-X'*DelI*ft(i);
    end
else
		[A,b]=fp_make_Ab_matrices(xgrid,ygrid,fx,fy,ft,sx,sy,sfx,sfy);
end

% Solve overconstrained least squares solution
p = A\b;

M=[p(2) p(3) p(1);p(5) p(6) p(4); 0 0 1];
temp_eye=eye(3);
temp_eye(9)=0;
M=M+temp_eye;
% Transform homography from scaled form

M=inv(T)*M*T;
%disp(sprintf('SX: 2^%d',log2(sx)));
%disp(sprintf('RCOND(A):%d',rcond(A)));