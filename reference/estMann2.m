function M = estMann2(im1,im2,option)
%
% function M = estAffine2(im1,im2)
%
% im1 and im2 are images
%
% M is 3x3 affine transform matrix: X' = M X
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
[fx,fy,ft]=computeDerivatives2bra(im1,im2);

% Create a mesh for the x and y values
[xgrid,ygrid]=meshgrid(1:size(fx,2),1:size(fx,1));
pts=find(~isnan(fx));
ptsy=find(~isnan(fy));
ptst=find(~isnan(ft));
pts=intersect(ptst,intersect(pts,ptsy));

fx = fx(pts);
fy = fy(pts);
ft = ft(pts);

xgrid = xgrid(pts);
ygrid = ygrid(pts);
A=0;
b=0;
A_prime=[];
b_prime=[];
for i=1:length(xgrid)
    X=[xgrid(i)*ygrid(i),xgrid(i),ygrid(i),1,0,0,0,0;
        0,0,0,0,xgrid(i)*ygrid(i),xgrid(i),ygrid(i),1];
    DelI=[fx(i);fy(i)];

    A=A+X'*DelI*DelI'*X;
    b=b+X'*DelI*(DelI'*[xgrid(i);ygrid(i)]-ft(i));
end

% Solve overconstrained least squares solution
q = A\b;
assert(size(q,1)==8);
height=size(im1,1);
width=size(im1,2);
x_orig=[1 1 width width;1 height 1 height]; % these are arbitrary coordinates and they DO effect the output result
x_new=zeros(size(x_orig));
R=[];
S=[];
for i=1:size(x_orig,2)
    %q(2)=q(2)+1; % These additions convert from flow to position
    %q(7)=q(7)+1;
    x_new(:,i)=[x_orig(1,i).*x_orig(2,i),x_orig(1,i),x_orig(2,i),1,0,0,0,0;0,0,0,0,x_orig(1,i).*x_orig(2,i),x_orig(1,i),x_orig(2,i),1]*q;
    r=[x_orig(1,i),x_orig(2,i),1,0,0,0,-x_orig(1,i)*x_new(1,i),-x_orig(2,i)*x_new(1,i);
        0,0,0,x_orig(1,i),x_orig(2,i),1,-x_orig(1,i)*x_new(2,i),-x_orig(2,i)*x_new(2,i)];
    R=[R;r];
    S=[S;[x_new(1,i);x_new(2,i)]];
end

% Pad with ones
x_orig=[x_orig;ones(1,4)];
x_new=[x_new;ones(1,4)];

M=homography2d(x_orig,x_new);
p_mann=R\S;

return;